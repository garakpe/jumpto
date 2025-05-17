# 인증 시스템 버그 수정 계획

## 발견된 문제점

1. **학생 이메일 형식 불일치**
   - 생성 시: `25XXXXX@school000003550.com` 형식
   - 사용 시: `25XXXXX@school3550.com` 형식
   - `25`는 연도(2025)의 마지막 두 자리

2. **클라우드 함수 호출 실패**
   - `studentLogin` 함수가 404(Not Found) 에러 반환
   - CORS 정책 문제 가능성

3. **학교 정보 없음 에러**
   - "해당 학교 정보를 찾을 수 없습니다" 에러 메시지 
   - Firestore에 학교 정보가 저장되지 않은 상태

4. **로그아웃 시 null 체크 오류**
   - "Null check operator used on a null value" 에러 발생
   - `AppRouter.dart`의 `redirect` 함수에서 로그아웃 후 null 체크 미흡

## 원인 분석

1. **이메일 형식 불일치**
   - `StudentRemoteDataSourceImpl`에서 이메일 생성 시 학교 코드 전체를 사용
   - `CloudFunctionsService`에서 로그인 처리 시 학교 코드의 마지막 4자리만 사용
   - 생성된: `25XXXXX@school000003550.com`
   - 실제 기대하는 형식: `25XXXXX@school3550.com`

2. **클라우드 함수 오류**
   - 함수가 제대로 배포되지 않았거나, 호출 방식이 잘못됨
   - 직접 HTTP 요청 방식으로 호출하면서 CORS 문제 발생
   - `asia-northeast3-jumpto-web.cloudfunctions.net/studentLogin` 경로가 올바르지 않을 수 있음

3. **학교 정보 문제**
   - Firestore `schools` 컬렉션에 학교 정보가 없음
   - 데이터 시드 작업이 필요함

4. **라우터 null 체크 문제**
   - `AppRouter`의 redirect 함수 내에서 로그아웃 후 `_currentUser`를 null 체크 없이 접근
   - `isLoggedIn` 변수를 설정했지만 이후 조건문에서 적절히 사용되지 않음
   - 특히 로그인 조건문에서 `_currentUser!.isTeacher` 등으로 null 객체 속성에 접근하려 함

## 해결 방안

1. **이메일 형식 통일**
   - 모든 학생 관련 코드에서 학교 코드의 마지막 4자리만 사용하도록 변경
   - `StudentRemoteDataSourceImpl` 클래스의 `uploadStudents` 메서드 수정
   - 생성된 모든 이메일을 `<연도><학년><반><번호>@school<학교코드뒤4자리>.com` 형식으로 통일

2. **클라우드 함수 수정**
   - CORS 문제 해결을 위해 `studentLogin` 함수를 HTTP 엔드포인트에서 Callable 함수로 변경
   - `CloudFunctionsService` 클래스에서 `httpsCallable`을 사용하도록 수정
   - 함수 배포 스크립트 실행 및 함수 활성화 확인

3. **학교 정보 추가**
   - Firestore에 학교 정보 추가하는 코드 구현
   - 교사 회원가입 시 학교 정보가 없으면 자동 생성하는 로직 추가
   - `FirebaseDataSeed` 클래스에 학교 데이터 시드 기능 구현

4. **라우터 null 체크 강화**
   - `AppRouter.dart` 파일의 redirect 함수 수정
   - `isLoggedIn` 변수로 _currentUser 접근 전 안전 체크
   - 모든 사용자 속성 접근 시 null-safety 패턴 적용
   - 로그아웃 상태와 로그인 상태 처리 분리

## 구현 방법 (클린 아키텍처)

### 1. 데이터 계층 수정
- `StudentRemoteDataSourceImpl` 클래스의 업로드 로직 수정
- 학생 이메일 생성 형식 통일 (마지막 4자리 학교 코드 사용)
- 모든 학교 코드 관련 로직 일관성 확보

### 2. 도메인 계층 수정
- 학생 엔티티와 모델의 필드 일관성 확보
- 명확한 에러 타입과 실패 케이스 정의
- 유스케이스 로직 검토 및 수정

### 3. 프레젠테이션 계층 수정
- 학생 로그인 UI 개선
- 적절한 오류 메시지 표시
- 사용자 경험 개선
- `AppRouter` 클래스의 `redirect` 메서드 null 체크 강화

### 4. 인프라 계층 수정
- 클라우드 함수 코드 수정 및 재배포
- Firebase 초기화 시 학교 데이터 시드 적용
- CloudFunctionsService 클래스 개선

## 세부 작업 항목

1. `app_router.dart` 수정
   - 사용자 객체 접근 전 안전한 null 체크 추가
   - 로그인 상태와 로그아웃 상태 처리 분리
   - 사용자 속성 접근시 `isLoggedIn` 확인 후 접근
   - 로깅 개선 및 안전한 사용자 정보 출력

2. `cloud_functions_service.dart` 수정
   - `studentLogin` 메서드를 HTTP 요청에서 `httpsCallable` 사용으로 변경
   - 학교 데이터 조회/추가 메서드 구현

3. `auth_remote_data_source.dart` 수정
   - `signInStudent` 메서드를 Cloud Functions 호출로 개선
   - 교사 회원가입 시 학교 정보 저장/확인 로직 추가

4. `student_remote_datasource.dart` 수정
   - 이메일 생성 로직 통일 (학교 코드 후처리)
   - 모든 학생 관련 필드명과 값 형식 통일

5. `firebase_data_seed.dart` 수정
   - 학교 정보 시드 로직 추가
   - 테스트용 학생/교사 계정 생성 로직 개선

6. 클라우드 함수 수정 및 배포
   - `studentLogin` 함수를 Callable 함수로 변경
   - CORS 이슈 해결을 위한 헤더 설정
   - 학교 정보 조회 로직 개선

7. 테스트 및 디버깅
   - 로그인/로그아웃 테스트
   - 라우팅 처리 테스트
   - 학생 계정 생성 테스트
   - 오류 상황 처리 테스트
