# Cloud Functions 배포 가이드

이 문서는 온라인 팝스(PAPS) 교육 플랫폼에서 사용하는 Firebase Cloud Functions의 배포 방법을 설명합니다.

## 배포 전 준비사항

1. Firebase CLI가 설치되어 있는지 확인합니다.
   ```bash
   firebase --version
   ```
   
   만약 설치되어 있지 않다면 다음 명령어로 설치합니다:
   ```bash
   npm install -g firebase-tools
   ```

2. Firebase에 로그인합니다.
   ```bash
   firebase login
   ```

3. 프로젝트가 올바르게 설정되어 있는지 확인합니다.
   ```bash
   firebase projects:list
   ```
   
   현재 작업 중인 프로젝트가 목록에 있는지 확인하세요.

## Cloud Functions 배포

1. Firebase Functions 디렉토리로 이동합니다.
   ```bash
   cd /Users/smartchoi/Desktop/jumpto/firebase/functions
   ```

2. 의존성 패키지를 설치합니다.
   ```bash
   npm install
   ```

3. 작성한 Cloud Functions를 배포합니다.
   ```bash
   firebase deploy --only functions
   ```
   
   특정 함수만 배포하려면 다음과 같이 함수명을 지정할 수 있습니다:
   ```bash
   firebase deploy --only functions:createStudentAuthAccount,functions:resetStudentPassword,functions:updateStudentGender,functions:studentLogin,functions:createBulkStudentAccounts
   ```

4. 배포 완료 후 Firebase 콘솔에서 함수가 정상적으로 작동하는지 확인합니다.
   - Firebase 콘솔 > Functions 메뉴에서 배포된 함수 목록 확인
   - 로그를 확인하여 오류가 있는지 검사

## 배포 후 로컬 App 테스트

Cloud Functions가 성공적으로 배포된 후에는 다음 단계를 통해 앱에서 테스트할 수 있습니다:

1. Flutter 앱 실행
   ```bash
   cd /Users/smartchoi/Desktop/jumpto
   flutter run -d chrome
   ```

2. 학생 로그인 테스트
   - 학교명과 학번으로 로그인 시도
   - 성공적으로 로그인되는지 확인

3. 교사 계정으로 학생 계정 일괄 생성 테스트
   - 교사 계정으로 로그인
   - 학생 관리 화면에서 학생 명단 업로드
   - Cloud Functions 로그에서 계정 생성 성공 여부 확인

## 문제 해결

로그 확인:
```bash
firebase functions:log
```

이 명령어를 통해 함수 실행 중 발생하는 오류와 디버그 메시지를 확인할 수 있습니다.

## 추가 주의사항

1. Cloud Functions는 Firebase의 유료 요금제에 따라 비용이 발생할 수 있습니다. 사용량을 모니터링하세요.

2. 학생 비밀번호는 항상 안전하게 관리해야 합니다. 데이터베이스에 평문으로 저장하지 마세요.

3. 실제 운영 환경에서는 `.env` 파일이나 Firebase 환경 변수를 사용하여 민감한 정보를 관리하는 것이 좋습니다.

4. 에러 처리와 로깅을 충분히 하여 문제 발생 시 빠르게 대응할 수 있도록 하세요.