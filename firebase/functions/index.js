/**
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// Firebase Admin SDK 모듈 가져오기
const admin = require("firebase-admin");
// Firebase Functions V2 모듈 가져오기
const { HttpsError, onCall } = require("firebase-functions/v2/https");
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { logger } = require("firebase-functions"); // Firebase 로깅 사용

// Firebase Admin SDK 초기화
admin.initializeApp();

// Firestore 인스턴스 가져오기
const db = admin.firestore();
const auth = admin.auth();

// 상수 정의
const REGION = "asia-northeast3"; // 서울 리전

/**
 * 학생 계정 생성 함수 (Firestore 트리거)
 *
 * Firestore 'students' 컬렉션에 문서가 생성될 때 자동으로 트리거되어
 * 해당 학생의 Firebase Authentication 계정을 생성하고 Firestore 문서를 업데이트합니다.
 */
exports.createStudentAuthAccount = onDocumentCreated(
  {
    document: "students/{studentId}", // 감시할 문서 경로
    region: REGION, // 함수 실행 리전
  },
  async (event) => {
    logger.info("createStudentAuthAccount 함수 시작", { structuredData: true });

    const snapshot = event.data; // 생성된 문서의 스냅샷
    if (!snapshot) {
      logger.warn("이벤트 데이터에 스냅샷이 없습니다.", {
        structuredData: true,
      });
      return null;
    }

    const studentData = snapshot.data();
    const studentDocId = event.params.studentId; // Firestore 문서 ID (studentId와 다를 수 있음)
    const studentRef = snapshot.ref; // 생성된 문서의 참조

    logger.info(`학생 문서 ID: ${studentDocId} 처리 시작`, { studentDocId });

    // 필수 필드 검증 (email, password는 초기 생성 시점에만 사용)
    if (!studentData.email || !studentData.password) {
      logger.error(`학생 ${studentDocId}의 필수 필드(email, password) 누락`, {
        studentDocId,
      });
      // 오류 발생 시 Firestore에 상태 기록 고려 (예: status: 'error', errorMsg: '...')
      return null;
    }

    // 이미 Auth 계정이 있는 경우 (authUid 필드가 있는 경우) 처리 중단
    if (studentData.authUid) {
      logger.info(
        `학생 ${studentDocId}는 이미 Auth 계정(${studentData.authUid})을 가지고 있습니다.`,
        {
          studentDocId,
          authUid: studentData.authUid,
        }
      );
      return null;
    }

    try {
      // Firebase Auth 계정 생성
      logger.info(
        `학생 ${studentDocId}의 Auth 계정 생성 시도 (Email: ${studentData.email})`,
        {
          studentDocId,
          email: studentData.email,
        }
      );
      const userRecord = await auth.createUser({
        email: studentData.email,
        password: studentData.password,
        displayName: studentData.name,
      });
      logger.info(
        `학생 ${studentDocId}의 Auth 계정 생성 성공 (UID: ${userRecord.uid})`,
        {
          studentDocId,
          uid: userRecord.uid,
        }
      );

      // Firestore에 authUid 필드 업데이트 및 비밀번호 필드 제거
      await studentRef.update({
        authUid: userRecord.uid,
        password: admin.firestore.FieldValue.delete(), // 보안상 비밀번호 제거
        updatedAt: admin.firestore.FieldValue.serverTimestamp(), // 업데이트 시간 기록
      });
      logger.info(
        `학생 ${studentDocId}의 Firestore 문서 업데이트 성공 (authUid 추가, password 제거)`,
        {
          studentDocId,
          authUid: userRecord.uid,
        }
      );

      return userRecord.uid;
    } catch (error) {
      logger.error(
        `학생 ${studentDocId}의 Auth 계정 생성 또는 문서 업데이트 중 오류 발생`,
        {
          studentDocId,
          error: error.message,
          stack: error.stack,
        }
      );
      // 실패 시 Firestore에 상태 기록 고려
      return null;
    }
  }
);

/**
 * 학생 비밀번호 초기화 함수 (HTTPS Callable)
 *
 * 교사가 학생의 비밀번호를 초기화합니다.
 * 요청자 인증 및 교사 권한, 학생 소속 확인 후 비밀번호를 변경합니다.
 */
exports.resetStudentPassword = onCall(
  { region: REGION }, // 함수 실행 리전
  async (request) => {
    logger.info("resetStudentPassword 함수 시작", { structuredData: true });

    // 1. 인증 확인
    if (!request.auth) {
      logger.warn("인증되지 않은 사용자 접근 시도");
      throw new HttpsError("unauthenticated", "인증이 필요합니다.");
    }
    const teacherUid = request.auth.uid;
    logger.info(`요청자 UID: ${teacherUid}`, { teacherUid });

    // 2. 요청 데이터 검증
    const studentId = request.data.studentId; // Firestore studentId 필드 값
    const newPassword = request.data.newPassword;
    if (!studentId || !newPassword) {
      logger.warn("잘못된 요청 데이터 (studentId 또는 newPassword 누락)", {
        requestData: request.data,
      });
      throw new HttpsError(
        "invalid-argument",
        "학생 ID와 새 비밀번호가 필요합니다."
      );
    }
    // 비밀번호 정책 검사 (예: 최소 길이) 추가 가능
    if (newPassword.length < 6) {
      logger.warn("새 비밀번호 길이가 너무 짧습니다.", { studentId });
      throw new HttpsError(
        "invalid-argument",
        "비밀번호는 6자 이상이어야 합니다."
      );
    }

    logger.info(`학생 ID ${studentId}의 비밀번호 초기화 요청`, {
      teacherUid,
      studentId,
    });

    try {
      // 3. 교사 권한 확인
      const teacherDoc = await db.collection("users").doc(teacherUid).get();
      if (!teacherDoc.exists || teacherDoc.data().role !== "teacher") {
        logger.error(`권한 없음: UID ${teacherUid} 사용자는 교사가 아님`, {
          teacherUid,
        });
        throw new HttpsError(
          "permission-denied",
          "교사만 학생 비밀번호를 초기화할 수 있습니다."
        );
      }
      logger.info(`교사 권한 확인 완료 (UID: ${teacherUid})`, { teacherUid });

      // 4. 학생 정보 조회 (Firestore studentId 필드로 조회)
      const studentsSnapshot = await db
        .collection("students")
        .where("studentId", "==", studentId)
        .limit(1)
        .get();

      if (studentsSnapshot.empty) {
        logger.error(`학생 정보 없음 (studentId: ${studentId})`, { studentId });
        throw new HttpsError("not-found", "해당 학생을 찾을 수 없습니다.");
      }

      const studentDoc = studentsSnapshot.docs[0];
      const studentData = studentDoc.data();
      const studentDocId = studentDoc.id; // Firestore 문서 ID
      logger.info(
        `학생 문서 찾음 (Doc ID: ${studentDocId}, studentId: ${studentId})`,
        { studentDocId, studentId }
      );

      // 5. 학생 소속 확인 (선택적이지만 권장)
      if (studentData.teacherId !== teacherUid) {
        logger.error(
          `권한 없음: 학생 ${studentId}(Doc ID: ${studentDocId})는 교사 ${teacherUid} 소속이 아님`,
          {
            teacherUid,
            studentId,
            studentDocId,
            actualTeacherId: studentData.teacherId,
          }
        );
        throw new HttpsError(
          "permission-denied",
          "자신의 학급 학생만 비밀번호를 초기화할 수 있습니다."
        );
      }
      logger.info(
        `학생 소속 확인 완료 (교사: ${teacherUid}, 학생: ${studentId})`,
        { teacherUid, studentId }
      );

      // 6. 학생 Auth UID 확인
      if (!studentData.authUid) {
        logger.error(`학생 ${studentId}의 Auth UID 없음`, {
          studentId,
          studentDocId,
        });
        throw new HttpsError(
          "not-found",
          "학생의 인증 계정 정보를 찾을 수 없습니다."
        );
      }
      const studentAuthUid = studentData.authUid;
      logger.info(`학생 Auth UID 확인: ${studentAuthUid}`, { studentAuthUid });

      // 7. 비밀번호 변경
      await auth.updateUser(studentAuthUid, {
        password: newPassword,
      });
      logger.info(`Auth 비밀번호 변경 성공 (Auth UID: ${studentAuthUid})`, {
        studentAuthUid,
      });

      // 8. Firestore 업데이트 시간 기록
      await studentDoc.ref.update({
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      logger.info(
        `Firestore 문서 updatedAt 필드 업데이트 성공 (Doc ID: ${studentDocId})`,
        { studentDocId }
      );

      // 9. 성공 응답 반환
      logger.info(`학생 ${studentId} 비밀번호 초기화 성공`, { studentId });
      return {
        success: true,
        message: "비밀번호가 성공적으로 초기화되었습니다.",
      };
    } catch (error) {
      logger.error(`학생 ${studentId} 비밀번호 초기화 중 오류 발생`, {
        studentId,
        teacherUid,
        error: error.message,
        stack: error.stack,
      });
      if (error instanceof HttpsError) {
        throw error; // HttpsError는 그대로 다시 던짐
      } else {
        // 그 외 오류는 일반적인 내부 오류로 처리
        throw new HttpsError(
          "internal",
          `비밀번호 초기화 중 오류가 발생했습니다.` // 사용자에게 상세 오류 메시지 노출 최소화
        );
      }
    }
  }
);

/**
 * 학생 계정 일괄 생성 함수 (HTTPS Callable)
 *
 * 교사가 학생 명단을 받아 여러 학생 계정을 Firestore 및 Auth에 한번에 생성합니다.
 */
exports.createBulkStudentAccounts = onCall(
  { region: REGION }, // 함수 실행 리전
  async (request) => {
    logger.info("createBulkStudentAccounts 함수 시작", {
      structuredData: true,
    });

    // 1. 인증 확인
    if (!request.auth) {
      logger.warn("인증되지 않은 사용자 접근 시도");
      throw new HttpsError("unauthenticated", "인증이 필요합니다.");
    }
    const teacherUid = request.auth.uid;
    logger.info(`요청자 UID: ${teacherUid}`, { teacherUid });

    // 2. 교사 권한 확인
    const teacherDoc = await db.collection("users").doc(teacherUid).get();
    if (!teacherDoc.exists || teacherDoc.data().role !== "teacher") {
      logger.error(`권한 없음: UID ${teacherUid} 사용자는 교사가 아님`, {
        teacherUid,
      });
      throw new HttpsError("permission-denied", "교사 권한이 필요합니다.");
    }
    const teacherData = teacherDoc.data();
    logger.info(`교사 권한 확인 완료 (UID: ${teacherUid})`, { teacherUid });

    // 3. 요청 데이터 검증
    const students = request.data.students;
    const initialPassword = request.data.initialPassword || "student123"; // 기본값 설정

    if (!students || !Array.isArray(students) || students.length === 0) {
      logger.warn("잘못된 요청 데이터 (students 배열 누락 또는 비어 있음)", {
        requestData: request.data,
      });
      throw new HttpsError(
        "invalid-argument",
        "유효한 학생 데이터 배열이 필요합니다."
      );
    }
    // 비밀번호 정책 검사 (예: 최소 길이) 추가 가능
    if (initialPassword.length < 6) {
      logger.warn("초기 비밀번호 길이가 너무 짧습니다.");
      throw new HttpsError(
        "invalid-argument",
        "초기 비밀번호는 6자 이상이어야 합니다."
      );
    }

    logger.info(`${students.length}명의 학생 계정 일괄 생성 요청`, {
      teacherUid,
      studentCount: students.length,
    });

    // 4. 교사 정보에서 학교 정보 가져오기 (Firestore 'users' 컬렉션 기준)
    const schoolCode = teacherData.schoolCode;
    const schoolName = teacherData.schoolName;
    if (!schoolCode || !schoolName) {
      logger.error(`교사 ${teacherUid} 정보에 학교 코드 또는 학교명 누락`, {
        teacherUid,
        teacherData,
      });
      throw new HttpsError(
        "failed-precondition",
        "교사 정보에 학교 정보가 설정되어 있지 않습니다."
      );
    }
    logger.info(`교사 학교 정보: ${schoolName}(${schoolCode})`, {
      schoolName,
      schoolCode,
    });

    // 5. 학생 생성 결과 저장 배열
    const results = {
      success: [],
      failure: [],
    };

    // 6. 각 학생마다 처리 (순차 처리, 병렬 처리 필요 시 Promise.all 사용 고려)
    for (const student of students) {
      // 필수 필드 확인 (학년, 반, 번호, 이름)
      if (
        !student.grade ||
        !student.classNum ||
        !student.studentNum ||
        !student.name
      ) {
        logger.warn("학생 정보 누락", { studentData: student });
        results.failure.push({
          student: student,
          error: "필수 정보(학년, 반, 번호, 이름)가 누락되었습니다.",
        });
        continue; // 다음 학생으로 넘어감
      }

      const studentLogInfo = {
        // 로그용 학생 정보
        grade: student.grade,
        classNum: student.classNum,
        studentNum: student.studentNum,
        name: student.name,
      };
      logger.info(`학생 처리 시작`, studentLogInfo);

      try {
        // 이메일 및 학번(studentId) 생성 로직
        const currentYear = new Date().getFullYear().toString().slice(-2); // 연도 마지막 2자리
        const gradeStr = student.grade.toString();
        const classNumStr = student.classNum.toString().padStart(2, "0");
        const studentNumStr = student.studentNum.toString().padStart(2, "0");
        const studentId = `${currentYear}${gradeStr}${classNumStr}${studentNumStr}`;
        const email = `${studentId}@school${schoolCode}.com`; // 고유 이메일 형식

        logger.info(
          `학생 정보 생성: studentId=${studentId}, email=${email}`,
          studentLogInfo
        );

        // TODO: 계정 생성 전 중복 확인 (동일 학번 또는 이메일 존재 여부) - 선택 사항
        // const existingStudent = await db.collection('students').where('studentId', '==', studentId).limit(1).get();
        // if (!existingStudent.empty) {
        //   throw new Error(`이미 존재하는 학번입니다: ${studentId}`);
        // }
        // const existingEmail = await auth.getUserByEmail(email).catch(e => null);
        // if (existingEmail) {
        //    throw new Error(`이미 존재하는 이메일입니다: ${email}`);
        // }

        // Firestore에 저장할 데이터 준비
        const studentDocData = {
          schoolCode: schoolCode,
          schoolName: schoolName,
          grade: student.grade,
          classNum: student.classNum,
          studentNum: student.studentNum,
          studentId: studentId, // 생성된 학번
          name: student.name,
          email: email, // 생성된 이메일
          teacherId: teacherUid, // 담당 교사 UID
          gender: student.gender || null, // 성별 (선택)
          authUid: null, // Auth 계정 생성 후 채워짐
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          // password는 저장하지 않음
        };

        // Firebase Auth 계정 생성
        let userRecord;
        try {
          userRecord = await auth.createUser({
            email: email,
            password: initialPassword,
            displayName: student.name,
          });
          logger.info(`Auth 계정 생성 성공 (UID: ${userRecord.uid})`, {
            studentId,
            email,
            uid: userRecord.uid,
          });
          studentDocData.authUid = userRecord.uid; // authUid 추가
        } catch (authError) {
          logger.error(`Auth 계정 생성 실패 (Email: ${email})`, {
            email,
            error: authError.message,
          });
          // Auth 생성 실패 시 Firestore 저장도 중단하고 실패 처리
          throw new Error(`Auth 계정 생성 실패: ${authError.message}`);
        }

        // Firestore에 학생 정보 저장 (문서 ID 자동 생성)
        const studentRef = await db.collection("students").add(studentDocData);
        logger.info(`Firestore 문서 생성 성공 (Doc ID: ${studentRef.id})`, {
          studentId,
          docId: studentRef.id,
        });

        results.success.push({
          studentId: studentId,
          email: email,
          name: student.name,
          docId: studentRef.id, // 생성된 문서 ID 포함
          authUid: userRecord.uid,
        });
      } catch (error) {
        logger.error(`학생 처리 중 오류 발생`, {
          studentData: student,
          error: error.message,
        });
        results.failure.push({
          student: student,
          error: error.message, // 오류 메시지 포함
        });
      }
    } // end of for loop

    // 7. 최종 결과 반환
    const successCount = results.success.length;
    const failureCount = results.failure.length;
    const message = `${successCount}명의 학생 계정이 생성되었습니다. (실패: ${failureCount}명)`;
    logger.info(message, { successCount, failureCount, teacherUid });

    return {
      success: true, // 함수 자체는 성공적으로 완료됨 (개별 실패는 results에 포함)
      message: message,
      results: results,
    };
  }
);

/**
 * 학생 성별 업데이트 함수 (HTTPS Callable)
 *
 * 학생이 자신의 성별 정보를 업데이트합니다.
 */
exports.updateStudentGender = onCall(
  { region: REGION }, // 함수 실행 리전
  async (request) => {
    logger.info("updateStudentGender 함수 시작", { structuredData: true });

    // 1. 인증 확인
    if (!request.auth) {
      logger.warn("인증되지 않은 사용자 접근 시도");
      throw new HttpsError("unauthenticated", "인증이 필요합니다.");
    }
    const studentAuthUid = request.auth.uid;
    logger.info(`요청자 UID: ${studentAuthUid}`, { studentAuthUid });

    // 2. 요청 데이터 검증
    const gender = request.data.gender;
    if (!gender || !["남", "여"].includes(gender)) {
      logger.warn("잘못된 요청 데이터 (gender 누락 또는 유효하지 않음)", {
        requestData: request.data,
      });
      throw new HttpsError(
        "invalid-argument",
        "유효한 성별 정보('남' 또는 '여')가 필요합니다."
      );
    }
    logger.info(`성별 업데이트 요청: ${gender}`, { studentAuthUid, gender });

    try {
      // 3. 사용자 역할 확인 (선택 사항 - 학생만 호출 가능하도록 제한하려면)
      // const userRecord = await auth.getUser(studentAuthUid);
      // if (!userRecord.customClaims || userRecord.customClaims.role !== 'student') {
      //    logger.error(`권한 없음: UID ${studentAuthUid}는 학생이 아님`, { studentAuthUid });
      //    throw new HttpsError("permission-denied", "학생만 자신의 성별을 업데이트할 수 있습니다.");
      // }

      // 4. 학생 정보 조회 (Auth UID로 조회)
      const studentsSnapshot = await db
        .collection("students")
        .where("authUid", "==", studentAuthUid)
        .limit(1)
        .get();

      if (studentsSnapshot.empty) {
        logger.error(`학생 정보 없음 (Auth UID: ${studentAuthUid})`, {
          studentAuthUid,
        });
        throw new HttpsError("not-found", "해당 학생 정보를 찾을 수 없습니다.");
      }

      const studentDoc = studentsSnapshot.docs[0];
      const studentDocId = studentDoc.id;
      logger.info(`학생 문서 찾음 (Doc ID: ${studentDocId})`, {
        studentAuthUid,
        studentDocId,
      });

      // 5. 성별 업데이트 및 시간 기록
      await studentDoc.ref.update({
        gender: gender,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      logger.info(
        `Firestore 문서 업데이트 성공 (Doc ID: ${studentDocId}, Gender: ${gender})`,
        { studentDocId, gender }
      );

      // 6. 성공 응답 반환
      return {
        success: true,
        message: "성별 정보가 성공적으로 업데이트되었습니다.",
      };
    } catch (error) {
      logger.error(
        `학생 성별 업데이트 중 오류 발생 (Auth UID: ${studentAuthUid})`,
        {
          studentAuthUid,
          gender,
          error: error.message,
          stack: error.stack,
        }
      );
      if (error instanceof HttpsError) {
        throw error;
      } else {
        throw new HttpsError(
          "internal",
          "성별 업데이트 중 오류가 발생했습니다."
        );
      }
    }
  }
);

/**
 * 학생 로그인 함수 (HTTPS Callable)
 *
 * 학생이 학교명, 학번, 비밀번호를 사용하여 로그인하고 Custom Token을 발급받습니다.
 * 중요: 이 함수는 서버에서 비밀번호를 직접 확인하지 않습니다.
 * 클라이언트에서 Firebase Auth SDK(signInWithEmailAndPassword)를 사용하는 것이 일반적입니다.
 * 이 함수는 email 존재 여부만 확인하고 Custom Token을 발급하므로,
 * 클라이언트에서 이미 인증을 거쳤거나 특별한 사유가 있는 경우에만 사용해야 합니다.
 */
exports.studentLogin = onCall(
  { region: REGION }, // 함수 실행 리전
  async (request) => {
    logger.info("studentLogin 함수 시작", { structuredData: true });

    // 1. 요청 데이터 검증
    const schoolName = request.data.schoolName;
    const studentId = request.data.studentId; // 학번
    const password = request.data.password; // 비밀번호 (현재 로직에서는 직접 사용 안 함)

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
      const schoolCode = schoolData.schoolCode;
      logger.info(`학교 코드 찾음: ${schoolCode}`, { schoolName, schoolCode });

      // 3. 학생 이메일 구성
      const email = `${studentId}@school${schoolCode}.com`;
      logger.info(`학생 이메일 구성: ${email}`, {
        studentId,
        schoolCode,
        email,
      });

      // 4. Firebase Auth에서 이메일로 사용자 조회 (비밀번호 검증 안 함!)
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
            "해당 정보로 가입된 학생이 없습니다. 학교명과 학번을 확인해주세요." // 사용자 친화적 메시지
          );
        }
        // 다른 Auth 오류 (예: 네트워크 오류)
        throw new HttpsError(
          "internal",
          "인증 정보 확인 중 오류가 발생했습니다."
        );
      }

      // 5. Firestore에서 학생 정보 조회 (Auth UID 사용)
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
          "학생 정보를 찾을 수 없습니다. 관리자에게 문의하세요." // 데이터 불일치 가능성 알림
        );
      }
      const studentDoc = studentsSnapshot.docs[0];
      const studentData = studentDoc.data();
      const studentDocId = studentDoc.id;
      logger.info(`Firestore 학생 정보 조회 성공 (Doc ID: ${studentDocId})`, {
        docId: studentDocId,
        authUid: userRecord.uid,
      });

      // 6. Custom Token 생성 (클라이언트에서 signInWithCustomToken으로 사용)
      // 추가 클레임에 필요한 정보 포함
      const additionalClaims = {
        role: "student", // 사용자 역할
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

      // 7. 마지막 로그인 시간 업데이트 (선택 사항)
      await studentDoc.ref.update({
        lastLoginAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      logger.info(`마지막 로그인 시간 업데이트 (Doc ID: ${studentDocId})`, {
        studentDocId,
      });

      // 8. 성공 응답 반환 (Custom Token 및 필요한 학생 정보)
      return {
        success: true,
        customToken: customToken,
        studentData: {
          // 클라이언트에서 바로 사용할 수 있는 정보
          id: studentDocId, // Firestore 문서 ID
          authUid: userRecord.uid,
          name: studentData.name,
          grade: studentData.grade,
          classNum: studentData.classNum,
          studentNum: studentData.studentNum,
          gender: studentData.gender,
          schoolName: studentData.schoolName,
          schoolCode: studentData.schoolCode,
          studentId: studentData.studentId, // 학번
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
