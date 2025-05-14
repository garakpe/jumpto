# 학생 인증 시스템 리팩토링 가이드

## 핵심 변경 내용

### 1. Auth 계정 생성 로직 단일화

**선택지 1: 클라이언트 측에서만 Auth 계정 생성 (적용됨)**

- **담당 로직**: `StudentRemoteDataSourceImpl.uploadStudents` 메서드에서 Auth 계정 생성
- **역할 명확화**: 
  - **클라이언트**: Auth 계정 생성 및 Firestore에 학생 정보(authUid 포함) 저장
  - **서버(createStudentAuthAccount)**: 간단한 후처리 작업만 수행

### 2. 비밀번호 보안 강화

- Firestore에 비밀번호 저장하지 않음
- `StudentModel.toFirestore()` 메서드에서 password 필드 제거
- 비밀번호는 Auth 계정 생성 시에만 일시적으로 사용

### 3. 이메일 형식 일관성 유지

- 표준 형식: `{연도 두자리}{학번}@school{학교코드 뒤 4자리}.com`
- 적용 범위:
  - `StudentRemoteDataSourceImpl.uploadStudents`
  - `studentLogin` Cloud Function
  - `AuthRemoteDataSourceImpl.createStudentAccount`

### 4. 학교 코드 일관성 유지

- 모든 코드에서 학교 코드의 마지막 4자리만 사용
- 적용 범위:
  - 학생 이메일 생성 시
  - Firestore에 저장되는 schoolCode 필드
  - 학교 정보 조회/필터링 시

## 적용 방법

### 1. Firebase Functions 업데이트

1. `refactored_functions.js` 내용을 `index.js`로 복사 또는 필요한 부분만 갱신
2. 다음 명령으로 Firebase Functions 배포:
   ```bash
   cd firebase/functions
   firebase deploy --only functions
   ```

### 2. 클라이언트 코드 업데이트

1. `student_remote_datasource_refactored.dart` 내용을 `student_remote_datasource.dart`로 갱신
2. 다음 명령으로 앱 리빌드:
   ```bash
   flutter clean
   flutter pub get
   flutter build web
   ```

## 테스트 항목

1. **학생 명단 업로드 테스트**
   - 여러 학생 정보로 테스트 실행
   - Auth 계정 생성 및 Firestore 저장 확인

2. **학생 로그인 테스트**
   - 업로드된 학생 정보로 로그인 시도
   - `studentLogin` 함수 작동 확인 (404 오류 없는지 확인)

3. **오류 케이스 테스트**
   - 잘못된 학교명/학번/비밀번호로 로그인 시도
   - 적절한 오류 메시지 표시 확인

4. **로그 분석**
   - Firebase Functions 로그 검토
   - 클라이언트 콘솔 로그 검토
   - 각 단계 성공/실패 추적

## 추가 고려사항

1. **기존 계정 호환성**
   - 학생 이메일 형식 변경으로 인한 기존 계정 마이그레이션 필요 여부 검토
   - 필요시 데이터 마이그레이션 계획 수립

2. **셀프 로그인 서비스**
   - 클라이언트에서 Firebase SDK의 `signInWithEmailAndPassword` 사용 검토
   - `studentLogin` Cloud Function 대체 가능 여부 검토