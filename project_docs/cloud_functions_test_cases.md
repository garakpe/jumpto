# Cloud Functions 테스트 케이스

이 문서는 온라인 팝스(PAPS) 교육 플랫폼에서 사용하는 Firebase Cloud Functions의 테스트 사례를 설명합니다.

## 학생 로그인 테스트

### 테스트 시나리오 1: 정상 로그인

**테스트 단계:**
1. `studentLogin` 함수 호출 
   ```dart
   await _cloudFunctionsService.studentLogin(
     schoolName: '가락고등학교',
     studentId: '2530101',
     password: '123456',
   );
   ```
2. 반환된 데이터에 `customToken` 속성이 있는지 확인
3. 반환된 사용자 데이터가 정확한지 확인

**예상 결과:**
- 반환 데이터에 `success: true`가 포함됨
- `customToken` 문자열이 반환됨
- 학생 정보가 포함된 `studentData` 객체가 반환됨

### 테스트 시나리오 2: 학교명 오류

**테스트 단계:**
1. 존재하지 않는 학교명으로 `studentLogin` 함수 호출
   ```dart
   await _cloudFunctionsService.studentLogin(
     schoolName: '존재하지않는학교',
     studentId: '2530101',
     password: '123456',
   );
   ```

**예상 결과:**
- 오류 메시지: "해당 학교 정보를 찾을 수 없습니다."

### 테스트 시나리오 3: 학번 오류

**테스트 단계:**
1. 존재하지 않는 학번으로 `studentLogin` 함수 호출
   ```dart
   await _cloudFunctionsService.studentLogin(
     schoolName: '가락고등학교',
     studentId: '9999999',
     password: '123456',
   );
   ```

**예상 결과:**
- 오류 메시지: "학교명, 학번 또는 비밀번호가 일치하지 않습니다."

### 테스트 시나리오 4: 비밀번호 오류

**테스트 단계:**
1. 잘못된 비밀번호로 `studentLogin` 함수 호출
   ```dart
   await _cloudFunctionsService.studentLogin(
     schoolName: '가락고등학교',
     studentId: '2530101',
     password: '잘못된비밀번호',
   );
   ```

**예상 결과:**
- 오류 메시지: "학교명, 학번 또는 비밀번호가 일치하지 않습니다."

## 학생 비밀번호 초기화 테스트

### 테스트 시나리오 1: 정상 초기화

**테스트 단계:**
1. 교사 계정으로 로그인
2. `resetStudentPassword` 함수 호출
   ```dart
   await _cloudFunctionsService.resetStudentPassword(
     studentId: '2530101',
     newPassword: '654321',
   );
   ```

**예상 결과:**
- 반환 데이터에 `success: true`가 포함됨
- 학생이 새 비밀번호로 로그인 가능함

### 테스트 시나리오 2: 권한 오류

**테스트 단계:**
1. 학생 계정으로 로그인
2. `resetStudentPassword` 함수 호출
   ```dart
   await _cloudFunctionsService.resetStudentPassword(
     studentId: '2530101',
     newPassword: '654321',
   );
   ```

**예상 결과:**
- 오류 메시지: "교사만 학생 비밀번호를 초기화할 수 있습니다."

### 테스트 시나리오 3: 존재하지 않는 학생

**테스트 단계:**
1. 교사 계정으로 로그인
2. 존재하지 않는 학번으로 `resetStudentPassword` 함수 호출
   ```dart
   await _cloudFunctionsService.resetStudentPassword(
     studentId: '9999999',
     newPassword: '654321',
   );
   ```

**예상 결과:**
- 오류 메시지: "해당 학생을 찾을 수 없습니다."

## 학생 성별 업데이트 테스트

### 테스트 시나리오 1: 정상 업데이트

**테스트 단계:**
1. 학생 계정으로 로그인
2. `updateStudentGender` 함수 호출
   ```dart
   await _cloudFunctionsService.updateStudentGender(
     gender: '남',
   );
   ```

**예상 결과:**
- 반환 데이터에 `success: true`가 포함됨
- Firestore 문서에 성별 정보가 업데이트됨

### 테스트 시나리오 2: 권한 오류

**테스트 단계:**
1. 교사 계정으로 로그인
2. `updateStudentGender` 함수 호출
   ```dart
   await _cloudFunctionsService.updateStudentGender(
     gender: '남',
   );
   ```

**예상 결과:**
- 오류 메시지: "학생만 자신의 성별을 업데이트할 수 있습니다."

### 테스트 시나리오 3: 잘못된 성별 값

**테스트 단계:**
1. 학생 계정으로 로그인
2. 잘못된 성별 값으로 `updateStudentGender` 함수 호출
   ```dart
   await _cloudFunctionsService.updateStudentGender(
     gender: '잘못된값',
   );
   ```

**예상 결과:**
- 오류 메시지: "유효한 성별 정보가 필요합니다."

## 학생 계정 일괄 생성 테스트

### 테스트 시나리오 1: 정상 일괄 생성

**테스트 단계:**
1. 교사 계정으로 로그인
2. `createBulkStudentAccounts` 함수 호출
   ```dart
   final students = [
     Student(
       grade: '3',
       classNum: '1',
       studentNum: '1',
       name: '학생1',
     ),
     Student(
       grade: '3',
       classNum: '1',
       studentNum: '2',
       name: '학생2',
     ),
   ];
   
   await _cloudFunctionsService.createBulkStudentAccounts(
     students: students,
     schoolCode: '3550',
     schoolName: '가락고등학교',
   );
   ```

**예상 결과:**
- 반환 데이터에 `success: true`가 포함됨
- 학생 계정이 생성되고 Firestore에 저장됨
- Firebase Authentication 계정이 생성됨

### 테스트 시나리오 2: 권한 오류

**테스트 단계:**
1. 학생 계정으로 로그인
2. `createBulkStudentAccounts` 함수 호출

**예상 결과:**
- 오류 메시지: "교사 권한이 필요합니다."

### 테스트 시나리오 3: 중복 이메일 처리

**테스트 단계:**
1. 교사 계정으로 로그인
2. 이미 존재하는 학생과 동일한 정보로 `createBulkStudentAccounts` 함수 호출

**예상 결과:**
- 함수가 완료되고 결과에 실패한 항목이 포함됨
- 새로운 학생은 생성되고 중복된 학생은 생성되지 않음
