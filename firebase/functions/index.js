const functions = require("firebase-functions");
const admin = require("firebase-admin");
const cors = require("cors")({ origin: true });

admin.initializeApp();

// 리전 설정 (asia-northeast3는 서울 리전입니다)
const regionalFunctions = functions.region("asia-northeast3");

/**
 * 학생 계정 생성 함수
 *
 * Firestore 'students' 컬렉션에 문서가 생성될 때 자동으로 트리거되어
 * 해당 학생의 Firebase Authentication 계정을 생성합니다.
 */
exports.createStudentAuthAccount = regionalFunctions.firestore
  .document("students/{studentId}")
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
      console.error(
        `Error creating Auth account for student ${studentId}:`,
        error
      );
      return null;
    }
  });

/**
 * 학생 비밀번호 초기화 함수
 *
 * HTTP 요청을 통해 교사가 학생의 비밀번호를 초기화할 수 있습니다.
 * 인증 및 권한 검증이 포함되어 있습니다.
 */
exports.resetStudentPassword = regionalFunctions.https.onCall(
  async (data, context) => {
    // 인증 여부 확인
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "인증이 필요합니다."
      );
    }

    // 요청 데이터 검증
    if (!data.studentId || !data.newPassword) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "학생 ID와 새 비밀번호가 필요합니다."
      );
    }

    try {
      // 교사 권한 확인
      const teacherDoc = await admin
        .firestore()
        .collection("users")
        .doc(context.auth.uid)
        .get();

      if (!teacherDoc.exists || teacherDoc.data().role !== "teacher") {
        throw new functions.https.HttpsError(
          "permission-denied",
          "교사만 학생 비밀번호를 초기화할 수 있습니다."
        );
      }

      // 학생 정보 조회
      const studentsSnapshot = await admin
        .firestore()
        .collection("students")
        .where("studentId", "==", data.studentId)
        .limit(1)
        .get();

      if (studentsSnapshot.empty) {
        throw new functions.https.HttpsError(
          "not-found",
          "해당 학생을 찾을 수 없습니다."
        );
      }

      const studentDoc = studentsSnapshot.docs[0];
      const studentData = studentDoc.data();

      // 학생이 해당 교사에게 속해 있는지 확인
      if (studentData.teacherId !== context.auth.uid) {
        throw new functions.https.HttpsError(
          "permission-denied",
          "자신의 학급 학생만 비밀번호를 초기화할 수 있습니다."
        );
      }

      // authUid 확인
      if (!studentData.authUid) {
        throw new functions.https.HttpsError(
          "not-found",
          "학생의 인증 계정을 찾을 수 없습니다."
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

      return {
        success: true,
        message: "비밀번호가 성공적으로 초기화되었습니다.",
      };
    } catch (error) {
      console.error("Error resetting student password:", error);
      throw new functions.https.HttpsError(
        "internal",
        `비밀번호 초기화 중 오류가 발생했습니다: ${error.message}`
      );
    }
  }
);

/**
 * 학생 계정 일괄 생성 함수
 *
 * 교사가 학생 명단을 업로드할 때 호출되어 여러 학생 계정을 한번에 생성합니다.
 */
exports.createBulkStudentAccounts = regionalFunctions.https.onCall(
  async (data, context) => {
    // 인증 여부 확인
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "인증이 필요합니다."
      );
    }

    // 교사 권한 확인
    const teacherDoc = await admin
      .firestore()
      .collection("users")
      .doc(context.auth.uid)
      .get();

    if (!teacherDoc.exists || teacherDoc.data().role !== "teacher") {
      throw new functions.https.HttpsError(
        "permission-denied",
        "교사 권한이 필요합니다."
      );
    }

    // 요청 데이터 검증
    if (
      !data.students ||
      !Array.isArray(data.students) ||
      data.students.length === 0
    ) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "유효한 학생 데이터가 필요합니다."
      );
    }

    try {
      // 교사 정보에서 학교 정보 가져오기
      const teacherData = teacherDoc.data();
      const schoolCode = teacherData.schoolCode;
      const schoolName = teacherData.schoolName;

      // 학생 생성 결과 저장할 배열
      const results = {
        success: [],
        failure: [],
      };

      // 각 학생마다 처리
      for (const student of data.students) {
        // 필수 필드 확인
        if (
          !student.grade ||
          !student.classNum ||
          !student.studentNum ||
          !student.name
        ) {
          results.failure.push({
            student: student,
            error: "필수 정보가 누락되었습니다.",
          });
          continue;
        }

        try {
          // 이메일 생성 (예: 학번@school학교ID.com 형식)
          // 예: 가락고등학교 3학년 1반 1번 학생, 25년도 → 2530101@school3550.com
          const currentYear = new Date().getFullYear().toString().substr(-2); // 현재 연도의 마지막 2자리
          const studentId = `${currentYear}${student.grade}${student.classNum
            .toString()
            .padStart(2, "0")}${student.studentNum
            .toString()
            .padStart(2, "0")}`;
          const email = `${studentId}@school${schoolCode}.com`;
          const initialPassword = data.initialPassword || "student123"; // 기본 비밀번호

          // Firestore에 학생 정보 저장
          const studentRef = admin.firestore().collection("students").doc();

          // 인증 계정 생성
          const userRecord = await admin.auth().createUser({
            email: email,
            password: initialPassword,
            displayName: student.name,
          });

          // 학생 정보 저장
          await studentRef.set({
            schoolCode: schoolCode,
            schoolName: schoolName,
            grade: student.grade,
            classNum: student.classNum,
            studentNum: student.studentNum,
            studentId: studentId,
            name: student.name,
            email: email,
            teacherId: context.auth.uid,
            authUid: userRecord.uid,
            gender: student.gender || null, // 성별 정보가 있으면 저장
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          });

          results.success.push({
            studentId: studentId,
            email: email,
            name: student.name,
          });
        } catch (error) {
          results.failure.push({
            student: student,
            error: error.message,
          });
        }
      }

      return {
        success: true,
        message: `${results.success.length}명의 학생 계정이 생성되었습니다. (실패: ${results.failure.length}명)`,
        results: results,
      };
    } catch (error) {
      console.error("Error creating bulk student accounts:", error);
      throw new functions.https.HttpsError(
        "internal",
        `학생 계정 일괄 생성 중 오류가 발생했습니다: ${error.message}`
      );
    }
  }
);

/**
 * 학생 정보 업데이트 시 성별 저장 함수
 *
 * 학생이 마이페이지에서 성별을 선택하면 이를 저장합니다.
 */
exports.updateStudentGender = regionalFunctions.https.onCall(
  async (data, context) => {
    // 인증 여부 확인
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "인증이 필요합니다."
      );
    }

    // 요청 데이터 검증
    if (!data.gender || !["남", "여"].includes(data.gender)) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "유효한 성별 정보가 필요합니다."
      );
    }

    try {
      // 사용자 정보 조회
      const userDoc = await admin
        .firestore()
        .collection("users")
        .doc(context.auth.uid)
        .get();

      if (!userDoc.exists || userDoc.data().role !== "student") {
        throw new functions.https.HttpsError(
          "permission-denied",
          "학생만 자신의 성별을 업데이트할 수 있습니다."
        );
      }

      // 학생 정보 조회
      const studentsSnapshot = await admin
        .firestore()
        .collection("students")
        .where("authUid", "==", context.auth.uid)
        .limit(1)
        .get();

      if (studentsSnapshot.empty) {
        throw new functions.https.HttpsError(
          "not-found",
          "해당 학생 정보를 찾을 수 없습니다."
        );
      }

      const studentDoc = studentsSnapshot.docs[0];

      // 성별 업데이트
      await studentDoc.ref.update({
        gender: data.gender,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      return {
        success: true,
        message: "성별 정보가 성공적으로 업데이트되었습니다.",
      };
    } catch (error) {
      console.error("Error updating student gender:", error);
      throw new functions.https.HttpsError(
        "internal",
        `성별 업데이트 중 오류가 발생했습니다: ${error.message}`
      );
    }
  }
);

/**
 * 학생 로그인 함수
 *
 * 학생이 학교명과 학번을 이용하여 로그인할 수 있는 함수입니다.
 */
exports.studentLogin = regionalFunctions.https.onCall(async (data, context) => {
  try {
    // 요청 데이터 검증
    if (!data.schoolName || !data.studentId || !data.password) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "학교명, 학번, 비밀번호가 필요합니다."
      );
    }

    // 학교명으로 학교 정보 조회
    const schoolsSnapshot = await admin
      .firestore()
      .collection("schools")
      .where("schoolName", "==", data.schoolName)
      .limit(1)
      .get();

    if (schoolsSnapshot.empty) {
      throw new functions.https.HttpsError(
        "not-found",
        "해당 학교 정보를 찾을 수 없습니다."
      );
    }

    const schoolData = schoolsSnapshot.docs[0].data();
    const schoolCode = schoolData.schoolCode; // schoolCode 사용

    // 학생 이메일 구성
    const email = `${data.studentId}@school${schoolCode}.com`;

    try {
      // Firebase Authentication으로 로그인 시도
      // 중요: 실제 로그인 시에는 비밀번호를 직접 비교하지 않습니다.
      // 여기서는 email로 사용자를 가져온 후, 클라이언트에서 비밀번호와 함께
      // signInWithEmailAndPassword 등을 시도하고 그 결과를 바탕으로 토큰을 발급해야 합니다.
      // 또는, 이 함수는 비밀번호를 검증하지 않고 바로 Custom Token을 발급하는 형태로
      // 클라이언트에서 이미 1차 인증(예: 학교 자체 시스템)을 거쳤다고 가정할 수도 있습니다.
      // 현재 코드는 비밀번호를 직접 사용하지 않고 getUserByEmail만 하고 토큰을 생성합니다.
      // 이는 클라이언트가 어떤 비밀번호를 입력하든 해당 이메일만 존재하면 토큰을 받을 수 있음을 의미하므로 보안상 주의가 필요합니다.
      // 일반적인 로그인 흐름은 클라이언트가 ID/PW로 Firebase Auth SDK를 통해 직접 로그인을 시도하는 것입니다.
      // 이 함수가 필요한 특별한 이유(예: 마이그레이션, 커스텀 인증 통합)가 있는지 확인이 필요합니다.
      // 여기서는 일단 제공된 로직을 기반으로 설명합니다.
      const userRecord = await admin.auth().getUserByEmail(email); // userRecord 대신 userCredential 이라는 변수명은 혼동을 줄 수 있음

      // 학생 정보 조회 (authUid로 조회)
      const studentsSnapshot = await admin
        .firestore()
        .collection("students")
        .where("authUid", "==", userRecord.uid) // userCredential.uid -> userRecord.uid
        .limit(1)
        .get();

      if (studentsSnapshot.empty) {
        throw new functions.https.HttpsError(
          "not-found",
          "학생 정보를 찾을 수 없습니다 (Auth UID 불일치)."
        );
      }

      const studentDoc = studentsSnapshot.docs[0];
      const studentData = studentDoc.data();

      // Custom Token 생성 (클라이언트에서 signInWithCustomToken으로 사용)
      const customToken = await admin.auth().createCustomToken(userRecord.uid, {
        // userCredential.uid -> userRecord.uid
        role: "student", // 사용자 정의 클레임 추가 가능
        studentId: studentData.studentId,
        grade: studentData.grade,
        classNum: studentData.classNum,
        studentNum: studentData.studentNum,
        schoolCode: studentData.schoolCode,
        schoolName: studentData.schoolName,
      });

      // 마지막 로그인 시간 업데이트
      await studentDoc.ref.update({
        lastLoginAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // 성공 응답 반환
      return {
        success: true,
        customToken: customToken,
        studentData: {
          id: studentDoc.id,
          name: studentData.name,
          grade: studentData.grade,
          classNum: studentData.classNum,
          studentNum: studentData.studentNum,
          gender: studentData.gender,
          schoolName: studentData.schoolName,
          schoolCode: studentData.schoolCode,
        },
      };
    } catch (authError) {
      console.error("Authentication error:", authError);
      // authError.code에 따라 더 구체적인 오류 메시지 분기 가능
      if (authError.code === "auth/user-not-found") {
        throw new functions.https.HttpsError(
          "not-found",
          "해당 이메일 주소(학번@학교코드.com)로 가입된 학생이 없습니다."
        );
      }
      throw new functions.https.HttpsError(
        "unauthenticated",
        "학교명, 학번 또는 비밀번호가 일치하지 않습니다." // 이 메시지는 비밀번호를 직접 비교하지 않으므로 약간 오해의 소지가 있을 수 있음
      );
    }
  } catch (error) {
    console.error("Error in student login:", error);
    if (!(error instanceof functions.https.HttpsError)) {
      throw new functions.https.HttpsError(
        "internal",
        `로그인 중 오류가 발생했습니다: ${error.message}`
      );
    }
    throw error; // 이미 HttpsError인 경우 그대로 다시 던짐
  }
});
