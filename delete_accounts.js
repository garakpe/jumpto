const admin = require("firebase-admin");
const serviceAccount = require("./jumpto-web-firebase-adminsdk-fbsvc-bf271d9a43.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

async function deleteAllStudentAccounts() {
  try {
    // 학생 계정 이메일 패턴 (예: *@school*.com)
    const emailPattern = "@school";

    // 모든 사용자 목록 가져오기
    const listUsersResult = await admin.auth().listUsers();

    // 삭제할 UID 목록 생성
    const uidsToDelete = [];

    listUsersResult.users.forEach((userRecord) => {
      const email = userRecord.email || "";
      // 학생 계정 이메일 패턴 확인
      if (email.includes(emailPattern)) {
        console.log(`삭제 예정: ${email} (${userRecord.uid})`);
        uidsToDelete.push(userRecord.uid);
      }
    });

    // 확인 메시지 출력
    console.log(
      `총 ${uidsToDelete.length}개 계정을 삭제합니다. 계속 진행하려면 Enter를 누르세요...`
    );
    await new Promise((resolve) => {
      process.stdin.once("data", () => {
        resolve();
      });
    });

    // 계정 삭제 (한 번에 최대 1000개)
    while (uidsToDelete.length > 0) {
      const batch = uidsToDelete.splice(0, 1000);
      const deleteResult = await admin.auth().deleteUsers(batch);
      console.log(
        `${deleteResult.successCount}개 계정 삭제 성공, ${deleteResult.failureCount}개 실패`
      );
    }

    console.log("계정 삭제 완료");
  } catch (error) {
    console.error("오류 발생:", error);
  }
}

deleteAllStudentAccounts();
