/**
 * 학생 로그인 이메일 조회 함수 (HTTPS Callable)
 * 
 * 학교명과 학번을 기반으로 학생의 Firebase Authentication 이메일 주소를 생성합니다.
 * 이는 보안을 강화하면서도 학생이 학교명/학번으로 로그인하는 경험을 유지하기 위한 방법입니다.
 */
const admin = require("firebase-admin");
const { HttpsError, onCall } = require("firebase-functions/v2/https");
const { logger } = require("firebase-functions"); // Firebase 로깅 사용

// 상수 정의
const REGION = "asia-northeast3"; // 서울 리전

/**
 * 학생 로그인 이메일 조회 함수
 * 
 * 학교명과 학번을 입력받아 Firebase Auth에 로그인할 수 있는 이메일 주소를 반환합니다.
 * 이 함수는 비밀번호를 다루지 않으며, 인증은 클라이언트에서 Firebase SDK를 통해 처리합니다.
 */
exports.getStudentLoginEmail = onCall(
  { region: REGION },
  async (request) => {
    logger.info("getStudentLoginEmail 함수 시작", { structuredData: true });

    // 1. 요청 데이터 검증
    const schoolName = request.data.schoolName;
    const studentId = request.data.studentId; // 학번

    if (!schoolName || !studentId) {
      logger.warn("잘못된 요청 데이터 (schoolName 또는 studentId 누락)", { 
        requestData: request.data 
      });
      throw new HttpsError(
        "invalid-argument",
        "학교명과 학번이 필요합니다."
      );
    }
    
    logger.info(`이메일 조회 요청: 학교=${schoolName}, 학번=${studentId}`, {
      schoolName,
      studentId,
    });

    try {
      // 2. 학교 정보 조회 (학교명으로 schoolCode 찾기)
      const schoolsSnapshot = await admin.firestore()
        .collection("schools")
        .where("schoolName", "==", schoolName.trim())
        .limit(1)
        .get();

      if (schoolsSnapshot.empty) {
        logger.error(`학교 정보 없음 (학교명: ${schoolName})`, { schoolName });
        throw new HttpsError("not-found", "해당 학교 정보를 찾을 수 없습니다.");
      }
      
      const schoolData = schoolsSnapshot.docs[0].data();
      const schoolCode = schoolData.schoolCode;
      logger.info(`학교 코드 찾음: ${schoolCode}`, { schoolName, schoolCode });

      // 3. 학생 이메일 구성
      // 이메일 형식: (연도 두자리)(학번)@school(학교코드 뒤 4자리).com
      const currentYear = new Date().getFullYear().toString().slice(-2); // 연도 마지막 2자리
      // 학교 코드는 뒤 4자리만 사용
      const shortSchoolCode = schoolCode.length > 4 
          ? schoolCode.substring(schoolCode.length - 4) 
          : schoolCode.padLeft(4, '0');
      
      const email = `${currentYear}${studentId}@school${shortSchoolCode}.com`;
      logger.info(`학생 이메일 구성: ${email}`, {
        studentId,
        schoolCode: shortSchoolCode,
        email,
      });

      // 4. 선택적: 이메일이 실제로 Auth 시스템에 존재하는지 확인
      try {
        await admin.auth().getUserByEmail(email);
        logger.info(`유효한 학생 이메일 확인: ${email}`, { email });
      } catch (authError) {
        logger.error(`Auth 시스템에서 이메일을 찾을 수 없음: ${email}`, {
          email,
          error: authError.message,
        });
        
        if (authError.code === "auth/user-not-found") {
          throw new HttpsError(
            "not-found",
            "해당 정보로 가입된 학생을 찾을 수 없습니다. 학교명과 학번을 확인해주세요."
          );
        }
        // 다른 Auth 오류 (예: 네트워크 오류)
        throw new HttpsError(
          "internal", 
          "학생 정보 확인 중 오류가 발생했습니다."
        );
      }

      // 5. 성공 응답 반환 (이메일만 포함)
      return {
        success: true,
        email: email,
        message: "로그인용 이메일 주소를 생성했습니다."
      };
    } catch (error) {
      logger.error(`학생 이메일 조회 중 오류 발생`, {
        schoolName,
        studentId,
        error: error.message,
        stack: error.stack,
      });
      
      if (error instanceof HttpsError) {
        throw error; // HttpsError는 그대로 다시 던짐
      } else {
        throw new HttpsError(
          "internal", 
          "로그인 정보 처리 중 오류가 발생했습니다."
        );
      }
    }
  }
);

// index.js 파일에 아래 코드 추가하기 위한 주석
// exports.getStudentLoginEmail = require('./improved_login').getStudentLoginEmail;
