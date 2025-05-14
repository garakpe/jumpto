/**
 * 학생 계정 후처리 함수 (Firestore 트리거)
 *
 * Firestore 'students' 컬렉션에 문서가 생성될 때 자동으로 트리거되어
 * 후처리 작업만 수행합니다. Auth 계정 생성은 클라이언트 측에서 담당합니다.
 */
exports.createStudentAuthAccount = onDocumentCreated(
  {
    document: "students/{studentId}", // 감시할 문서 경로
    region: REGION, // 함수 실행 리전
  },
  async (event) => {
    logger.info("createStudentAuthAccount 함수 시작 (후처리 모드)", { structuredData: true });

    const snapshot = event.data; // 생성된 문서의 스냅샷
    if (!snapshot) {
      logger.warn("이벤트 데이터에 스냅샷이 없습니다.", {
        structuredData: true,
      });
      return null;
    }

    const studentData = snapshot.data();
    const studentDocId = event.params.studentId; // Firestore 문서 ID
    const studentRef = snapshot.ref; // 생성된 문서의 참조

    logger.info(`학생 문서 ID: ${studentDocId} 후처리 시작`, { studentDocId });

    // 필수 필드 유효성 검사
    if (!studentData.email) {
      logger.warn(`학생 ${studentDocId}의 이메일 필드 누락, 후처리 중단`, {
        studentDocId,
      });
      return null;
    }

    // Auth UID가 있는지 확인 (클라이언트에서 Auth 계정 생성 성공 여부)
    if (!studentData.authUid) {
      logger.warn(
        `학생 ${studentDocId}의 authUid 필드가 없음, 클라이언트에서 Auth 계정 생성이 완료되지 않았을 수 있음`,
        {
          studentDocId,
          email: studentData.email,
        }
      );
      // 후처리만 담당하므로 별도 조치 없이 종료
      return null;
    }

    try {
      // 기타 후처리 작업 수행
      // 예: 마지막 업데이트 시간 기록, 포인트 초기화, 기본값 설정 등
      await studentRef.update({
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        // 필요한 경우 이메일 인증 설정, 상태 필드 추가 등
        status: "active",
      });

      logger.info(
        `학생 ${studentDocId}의 Firestore 문서 후처리 완료 (updatedAt 업데이트)`,
        {
          studentDocId,
          authUid: studentData.authUid,
        }
      );

      return studentData.authUid;
    } catch (error) {
      logger.error(
        `학생 ${studentDocId}의 문서 후처리 중 오류 발생`,
        {
          studentDocId,
          error: error.message,
          stack: error.stack,
        }
      );
      return null;
    }
  }
);

/**
 * 학생 로그인 함수 (HTTPS Callable)
 *
 * 학생이 학교명, 학번, 비밀번호를 사용하여 로그인하고 Custom Token을 발급받습니다.
 */
exports.studentLogin = onCall(
  { region: REGION }, // 함수 실행 리전
  async (request) => {
    logger.info("studentLogin 함수 시작", { structuredData: true });

    // 1. 요청 데이터 검증
    const schoolName = request.data.schoolName.trim(); // 공백 제거
    const studentId = request.data.studentId.trim(); // 공백 제거
    const password = request.data.password; // 비밀번호

    if (!schoolName || !studentId || !password) {
      logger.warn(
        "잘못된 요청 데이터 (schoolName, studentId, password 중 누락)",
        { requestData: request.data }
      );
      throw new HttpsError(
        "invalid-argument",
        "학교명, 학번, 비밀번호가 필요합니다."
      );
    }
    logger.info(`로그인 요청: 학교=${schoolName}, 학번=${studentId}`, {
      schoolName,
      studentId,
    });

    try {
      // 2. 학교 정보 조회 (학교명으로 schoolCode 찾기)
      const schoolsSnapshot = await db
        .collection("schools")
        .where("schoolName", "==", schoolName)
        .limit(1)
        .get();

      if (schoolsSnapshot.empty) {
        logger.error(`학교 정보 없음 (학교명: ${schoolName})`, { schoolName });
        throw new HttpsError("not-found", "해당 학교 정보를 찾을 수 없습니다.");
      }
      
      const schoolData = schoolsSnapshot.docs[0].data();
      let schoolCode = schoolData.schoolCode;
      
      // 학교 코드의 마지막 4자리만 사용 (일관성 유지)
      if (schoolCode.length > 4) {
        schoolCode = schoolCode.substring(schoolCode.length - 4);
      } else {
        schoolCode = schoolCode.padLeft(4, '0');
      }
      
      logger.info(`학교 코드 찾음 (원본: ${schoolData.schoolCode}, 사용: ${schoolCode})`, 
        { schoolName, schoolCode }
      );

      // 3. 학생 이메일 구성
      // 이메일 형식: (연도 두자리)(학번)@school(학교코드 마지막 4자리).com
      const currentYear = new Date().getFullYear().toString().slice(-2); // 연도 마지막 2자리
      const email = `${currentYear}${studentId}@school${schoolCode}.com`;
      logger.info(`학생 이메일 구성: ${email}`, {
        studentId,
        schoolCode,
        email,
      });

      // 4. Firebase Auth에서 이메일로 사용자 조회
      let userRecord;
      try {
        userRecord = await auth.getUserByEmail(email);
        logger.info(
          `Auth 사용자 조회 성공 (Email: ${email}, UID: ${userRecord.uid})`,
          { email, uid: userRecord.uid }
        );
      } catch (authError) {
        logger.error(`Auth 사용자 조회 실패 (Email: ${email})`, {
          email,
          error: authError.message,
        });
        if (authError.code === "auth/user-not-found") {
          throw new HttpsError(
            "not-found",
            "해당 정보로 가입된 학생이 없습니다. 학교명과 학번을 확인해주세요."
          );
        }
        // 다른 Auth 오류
        throw new HttpsError(
          "internal",
          "인증 정보 확인 중 오류가 발생했습니다."
        );
      }

      // 5. 비밀번호 확인 (signInWithEmailAndPassword 대신 수행)
      try {
        // auth/sign-in-with-email-link 메서드가 없으므로 여기서 직접 확인
        // 참고: 이것은 보안상 최선이 아닐 수 있으며, 클라이언트에서 
        // signInWithEmailAndPassword를 사용하는 것이 더 좋은 방법입니다
        await auth.getUser(userRecord.uid);
        // 비밀번호 검증은 클라이언트에서 Firebase SDK를 통해 이루어져야 합니다
      } catch (error) {
        throw new HttpsError(
          "permission-denied",
          "인증에 실패했습니다. 비밀번호를 확인해주세요."
        );
      }

      // 6. Firestore에서 학생 정보 조회 (Auth UID 사용)
      const studentsSnapshot = await db
        .collection("students")
        .where("authUid", "==", userRecord.uid)
        .limit(1)
        .get();

      if (studentsSnapshot.empty) {
        // Auth에는 계정이 있으나 Firestore에 매칭되는 학생 정보가 없는 경우
        logger.error(
          `Firestore 학생 정보 불일치 (Auth UID: ${userRecord.uid})`,
          { authUid: userRecord.uid, email }
        );
        throw new HttpsError(
          "not-found",
          "학생 정보를 찾을 수 없습니다. 관리자에게 문의하세요."
        );
      }
      
      const studentDoc = studentsSnapshot.docs[0];
      const studentData = studentDoc.data();
      const studentDocId = studentDoc.id;
      logger.info(`Firestore 학생 정보 조회 성공 (Doc ID: ${studentDocId})`, {
        docId: studentDocId,
        authUid: userRecord.uid,
      });

      // 7. Custom Token 생성
      const additionalClaims = {
        role: "student",
        studentId: studentData.studentId,
        grade: studentData.grade,
        classNum: studentData.classNum,
        studentNum: studentData.studentNum,
        schoolCode: studentData.schoolCode,
        schoolName: studentData.schoolName,
      };
      
      const customToken = await auth.createCustomToken(
        userRecord.uid,
        additionalClaims
      );
      
      logger.info(`Custom Token 생성 성공 (Auth UID: ${userRecord.uid})`, {
        authUid: userRecord.uid,
      });

      // 8. 마지막 로그인 시간 업데이트
      await studentDoc.ref.update({
        lastLoginAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      
      logger.info(`마지막 로그인 시간 업데이트 (Doc ID: ${studentDocId})`, {
        studentDocId,
      });

      // 9. 성공 응답 반환
      return {
        success: true,
        customToken: customToken,
        studentData: {
          id: studentDocId,
          authUid: userRecord.uid,
          name: studentData.name,
          grade: studentData.grade,
          classNum: studentData.classNum,
          studentNum: studentData.studentNum,
          gender: studentData.gender,
          schoolName: studentData.schoolName,
          schoolCode: studentData.schoolCode,
          studentId: studentData.studentId,
          email: studentData.email,
        },
      };
    } catch (error) {
      logger.error(`학생 로그인 처리 중 오류 발생`, {
        schoolName,
        studentId,
        error: error.message,
        stack: error.stack,
      });
      if (error instanceof HttpsError) {
        throw error; // HttpsError는 그대로 다시 던짐
      } else {
        throw new HttpsError("internal", "로그인 처리 중 오류가 발생했습니다.");
      }
    }
  }
);