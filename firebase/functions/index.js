const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

/**
 * 학생 계정 생성 함수
 * 
 * Firestore 'students' 컬렉션에 문서가 생성될 때 자동으로 트리거되어
 * 해당 학생의 Firebase Authentication 계정을 생성합니다.
 */
exports.createStudentAuthAccount = functions.firestore
  .document('students/{studentId}')
  .onCreate(async (snapshot, context) => {
    const studentData = snapshot.data();
    const studentId = context.params.studentId;

    // 필수 필드 검증
    if (!studentData.email || !studentData.password) {
      console.error(`Missing required fields for student ${studentId}`);
      return null;
    }

    // 이미 Auth 계정이 있는 경우 (authUid 필드가 있는 경우) 처리 중단
    if (studentData.authUid) {
      console.log(`Student ${studentId} already has Auth account`);
      return null;
    }

    try {
      // Firebase Auth 계정 생성
      const userRecord = await admin.auth().createUser({
        email: studentData.email,
        password: studentData.password,
        displayName: studentData.name,
      });

      // Firestore에 authUid 필드 업데이트
      await snapshot.ref.update({
        authUid: userRecord.uid,
        // 비밀번호 필드 제거 (보안상 Firestore에 저장하지 않음)
        password: admin.firestore.FieldValue.delete(),
      });

      console.log(`Successfully created Auth account for student ${studentId}`);
      return userRecord.uid;
    } catch (error) {
      console.error(`Error creating Auth account for student ${studentId}:`, error);
      return null;
    }
  });

/**
 * 학생 비밀번호 초기화 함수
 * 
 * HTTP 요청을 통해 교사가 학생의 비밀번호를 초기화할 수 있습니다.
 * 인증 및 권한 검증이 포함되어 있습니다.
 */
exports.resetStudentPassword = functions.https.onCall(async (data, context) => {
  // 인증 여부 확인
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      '인증이 필요합니다.'
    );
  }

  // 요청 데이터 검증
  if (!data.studentId || !data.newPassword) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      '학생 ID와 새 비밀번호가 필요합니다.'
    );
  }

  try {
    // 교사 권한 확인
    const teacherDoc = await admin.firestore()
      .collection('users')
      .doc(context.auth.uid)
      .get();
    
    if (!teacherDoc.exists || teacherDoc.data().role !== 'teacher') {
      throw new functions.https.HttpsError(
        'permission-denied',
        '교사만 학생 비밀번호를 초기화할 수 있습니다.'
      );
    }

    // 학생 정보 조회
    const studentsSnapshot = await admin.firestore()
      .collection('students')
      .where('studentId', '==', data.studentId)
      .limit(1)
      .get();

    if (studentsSnapshot.empty) {
      throw new functions.https.HttpsError(
        'not-found',
        '해당 학생을 찾을 수 없습니다.'
      );
    }

    const studentDoc = studentsSnapshot.docs[0];
    const studentData = studentDoc.data();

    // 학생이 해당 교사에게 속해 있는지 확인
    if (studentData.teacherId !== context.auth.uid) {
      throw new functions.https.HttpsError(
        'permission-denied',
        '자신의 학급 학생만 비밀번호를 초기화할 수 있습니다.'
      );
    }

    // authUid 확인
    if (!studentData.authUid) {
      throw new functions.https.HttpsError(
        'not-found',
        '학생의 인증 계정을 찾을 수 없습니다.'
      );
    }

    // 비밀번호 변경
    await admin.auth().updateUser(studentData.authUid, {
      password: data.newPassword,
    });

    // 업데이트 시간 기록
    await studentDoc.ref.update({
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return { success: true, message: '비밀번호가 성공적으로 초기화되었습니다.' };
  } catch (error) {
    console.error('Error resetting student password:', error);
    throw new functions.https.HttpsError(
      'internal',
      `비밀번호 초기화 중 오류가 발생했습니다: ${error.message}`
    );
  }
});

/**
 * 학생 정보 업데이트 시 성별 저장 함수
 * 
 * 학생이 마이페이지에서 성별을 선택하면 이를 저장합니다.
 */
exports.updateStudentGender = functions.https.onCall(async (data, context) => {
  // 인증 여부 확인
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      '인증이 필요합니다.'
    );
  }

  // 요청 데이터 검증
  if (!data.gender || !['남', '여'].includes(data.gender)) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      '유효한 성별 정보가 필요합니다.'
    );
  }

  try {
    // 사용자 정보 조회
    const userDoc = await admin.firestore()
      .collection('users')
      .doc(context.auth.uid)
      .get();

    if (!userDoc.exists || userDoc.data().role !== 'student') {
      throw new functions.https.HttpsError(
        'permission-denied',
        '학생만 자신의 성별을 업데이트할 수 있습니다.'
      );
    }

    // 학생 정보 조회
    const studentsSnapshot = await admin.firestore()
      .collection('students')
      .where('authUid', '==', context.auth.uid)
      .limit(1)
      .get();

    if (studentsSnapshot.empty) {
      throw new functions.https.HttpsError(
        'not-found',
        '해당 학생 정보를 찾을 수 없습니다.'
      );
    }

    const studentDoc = studentsSnapshot.docs[0];

    // 성별 업데이트
    await studentDoc.ref.update({
      gender: data.gender,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return { success: true, message: '성별 정보가 성공적으로 업데이트되었습니다.' };
  } catch (error) {
    console.error('Error updating student gender:', error);
    throw new functions.https.HttpsError(
      'internal',
      `성별 업데이트 중 오류가 발생했습니다: ${error.message}`
    );
  }
});
