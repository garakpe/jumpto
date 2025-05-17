# 온라인 팝스(PAPS) 교육 플랫폼 개발 계획

## 프로젝트 개요

- **프로젝트명**: 온라인 팝스(PAPS) 교육 플랫폼
- **개발 목표**: 학교 현장의 팝스(PAPS) 단원 운영을 내실화하고, 학생들의 자기 주도 학습 및 교사의 효율적인 수업 운영/평가를 지원하는 웹 기반 교육 플랫폼 개발
- **아키텍처**: Flutter + Firebase 기반, 클린 아키텍처 적용

## 개발 현황

### 완료된 작업

- 콘텐츠 선택 화면 구현

  - ContentSelectionPage 생성
  - ContentCard 위젯 구현
  - 라우팅 수정 (로그인 후 콘텐츠 선택 화면으로 이동)

- 프로젝트 초기 설정
- project_plan.md 파일 생성
- papsData.js 및 paps-converter.js 분석
- 클린 아키텍처 기반 폴더 구조 설정
- 팝스 기준표 데이터 모델(엔티티) 구현
  - 체력요인(FitnessFactor) 모델 구현
  - 평가종목(Event) 모델 구현
  - 학교급(SchoolLevel) 모델 구현
  - 성별(Gender) 모델 구현
  - 학년(Grade) 모델 구현
  - 등급범위(GradeRange) 모델 구현
  - 팝스기준표(PapsStandard) 모델 구현
  - 팝스기준표컬렉션(PapsStandardsCollection) 모델 구현
  - 팝스측정기록(PapsRecord) 모델 구현
- 팝스 기준표 유스케이스 구현
  - LoadPapsStandards 유스케이스 구현
  - CalculatePapsGrade 유스케이스 구현
  - GetPapsStandards 유스케이스 구현
  - GetStudentPapsRecords 유스케이스 구현
  - SavePapsRecord 유스케이스 구현
- 팝스 레포지토리 인터페이스 및 구현체 개발
  - PapsRepository 인터페이스 구현
  - PapsLocalDataSource 구현 (에셋에서 팝스 기준표 로드)
  - PapsRemoteDataSource 구현 (Firestore에서 측정 기록 관리)
  - PapsRepositoryImpl 구현체 개발
- 인증 기능 구현 (Auth)
  - User 엔티티 구현
  - AuthRepository 인터페이스 구현
  - AuthRemoteDataSource 구현 (Firebase Authentication 연동)
  - AuthLocalDataSource 구현 (SharedPreferences 활용) ✅
  - AuthRepositoryImpl 구현체 개발
  - SignInWithEmailPassword 유스케이스 구현
  - GetCurrentUser 유스케이스 구현
  - RegisterTeacher 유스케이스 구현
  - SignOut 유스케이스 구현 ✅
- Firebase 연동 설정
  - FirebaseInitializer 구현
  - 의존성 주입 설정 (GetIt 이용)
  - FlutterFire CLI를 통한 Firebase 프로젝트 연결
  - Firebase 서비스 구현 (FirebaseAuthService, FirebaseFirestoreService)
- 프레젠테이션 계층 구현
  - 상태 관리 (BLoC/Cubit 패턴)
    - AuthCubit 구현 (인증 상태 관리)
    - PapsCubit 구현 (팝스 관련 상태 관리)
  - 화면 구현
    - 스플래시 화면 (SplashPage)
    - 로그인 화면 (LoginPage)
    - 회원가입 화면 (RegisterPage)
    - 홈 화면 (HomePage)
    - 팝스 기준표 조회 화면 (PapsStandardsPage)
    - 팝스 측정 화면 (PapsMeasurementPage)
    - 교사용 측정 종목 선택 화면 (TeacherEventSelectionPage)
  - 공통 위젯 구현
    - 앱 버튼 (AppButton)
    - 앱 텍스트 필드 (AppTextField)
    - 로딩 화면 (LoadingView)
    - 오류 화면 (ErrorView)
    - 메뉴 카드 (MenuCard)
    - 측정 결과 카드 (MeasurementResultCard)
    - 등급 범위 테이블 (GradeRangeTable)
- 라우팅 구현
  - GoRouter를 사용한 앱 라우팅 설정
  - 인증 상태에 따른 리디렉션 처리
- 코드 구조 개선 및 경로 수정

  - `models` 폴더에서 `entities` 폴더로 파일 이동 및 경로 수정
  - import 경로 일관성 확보
  - 타입 안전성(type safety) 개선

- Firebase Hosting 설정 및 배포

  - firebase.json 파일 구성
  - 웹 앱 빌드 및 배포

- 교사용 대시보드 개발
  - 교사 설정 엔티티 및 모델 구현
  - 교사 설정 Repository 인터페이스 및 구현체 개발
  - 교사 설정 관련 유스케이스 구현
  - TeacherSettingsCubit 구현
  - 교사용 대시보드 UI 구현 (탭 형식)
    - 종목 선택 탭 구현
    - 출석부, 측정결과조회, 평가, 되돌아보기 탭 기본 구조 구현

### 완료된 작업 (최근 추가)

- 학생 관리 기능 구현
  - Student 엔티티 구현
  - StudentRepository 인터페이스 및 구현체 개발
  - StudentRemoteDataSource 구현
  - 학생 관리 유스케이스 구현
    - GetStudentsByTeacher 유스케이스 구현
    - UploadStudents 유스케이스 구현
  - StudentCubit 구현
  - 학생 업로드 화면 구현
  - 의존성 주입 설정 업데이트
- 학생 마이페이지 구현
  - 학생 비밀번호 변경 유스케이스(ChangeStudentPassword) 구현
  - StudentMyPage 화면 구현
  - 계정 드롭다운 메뉴 구현
  - 라우팅 설정 업데이트
- 학생 모델 개선
  - Student 엔티티와 StudentModel에 gender 필드 추가
  - Firestore 데이터 구조에 gender 필드 추가

### 현재 진행 중인 작업

- Firebase Authentication 설정 (이메일/비밀번호 인증 활성화) ✅
- Firestore 데이터베이스 보안 규칙 설정 ✅
- 학생용 로그인 구현 완성 ✅
- 테스트용 계정 생성 및 디버깅 ✅
- 교사 회원가입 승인 기능 구현 ✅
  - 관리자 역할 추가 ✅
  - 숨겨진 관리자 로그인 URL 구현 ✅
  - 교사 승인 대기 화면 구현 ✅
  - 관리자 대시보드 구현 ✅
- 학생 인증 시스템 완성 ✅
  - 학생 인증 로직 단일화 (Auth 계정 생성 로직 클라이언트 측으로 이동) ✅
  - 비밀번호 보안 강화 (비밀번호 저장 안함) ✅
  - 이메일 형식 일관성 확보 ✅
  - 학교 코드 일관성 확보 ✅
- 인증 흐름 최적화 ✅
  - 불필요한 인증 상태 체크 줄이기 ✅
  - 중복 리디렉션 체크 최적화 ✅
  - 앱 라이프사이클 이벤트 처리 개선 ✅
- 교사용 대시보드 개발 진행 중 ✅
  - 교사용 대시보드 UI 디자인 ✅
  - 콘텐츠 선택 화면에서 교사용 대시보드로 연결 ✅
  - 종목 선택 탭 구현 ✅
  - 나머지 탭 (출석부, 측정결과조회, 평가, 되돌아보기) 상세 기능 구현
- 학생 관리 기능 구현
  - 학생 데이터 모델 통합 및 필드 명 표준화 ✅
    - Student 엔티티와 StudentModel에 gender 필드 추가 ✅
    - 학생 관련 필드 명 통일 (className → classNum, studentNum → studentNum/studentId 등) ✅
  - 학생 마이페이지 비밀번호 재설정 기능 연결

### 최근 완료된 작업 (학생 인증 시스템 개선)

- Student 엔티티 개선
  - authUid 필드 추가 (Firebase Authentication UID 연결)
  - email 필드 추가 (시스템 생성 이메일)
  - updatedAt 필드 추가 (마지막 수정 일시)
- StudentModel 개선
  - 새로운 필드를 만들고 Firestore에 저장하는 로직 추가
  - 시스템 생성 이메일 시스템 구현 (학번@학교코드.school 형식)
- StudentRemoteDataSource 개선
  - Firebase Authentication 연동 추가
  - 학생 일괄 업로드 시 Firebase Authentication 계정 자동 생성
  - 학생 성별 업데이트 기능 추가
- Cloud Functions 구현
  - createStudentAuthAccount: 학생 Firestore 문서 생성 시 Firebase Authentication 계정 자동 생성
  - resetStudentPassword: 교사가 학생 비밀번호 초기화
  - updateStudentGender: 학생 성별 정보 업데이트
- CloudFunctionsService 구현
  - Cloud Functions를 호출할 수 있는 서비스 클래스 구현
  - 비밀번호 초기화 및 성별 업데이트 기능 구현
- StudentCubit 개선
  - UpdateStudentGender 유스케이스 통합
  - 성별 업데이트 기능 추가
- 학생 마이페이지 성별 선택 기능 구현
  - StudentMyPage UI 화면에 성별 선택 메뉴 추가
  - 성별 선택 및 저장 기능 구현

### 최근 완료된 작업 (교사 회원가입 학교 선택 기능 추가)

- 학교 엔티티 및 모델 구현
  - School 엔티티 생성
  - SchoolModel 클래스 구현 (JSON 파싱 로직 포함)
- 학교 데이터 관리 기능 구현
  - SchoolRepository 인터페이스 및 구현체 개발
  - SchoolLocalDataSource 구현 (지역별 학교 JSON 파일 로드)
  - 지역 및 학교 검색 관련 유스케이스 구현
- 학교 검색 UI 구현
  - SchoolSelector 위젯 개발 (지역 선택 및 학교명 검색 기능)
  - 자동 완성 및 직접 입력 옵션 제공
- 교사 회원가입 화면 개선
  - 학교 선택 UI 추가
  - 기존 학교명 수동 입력 필드 유지 (직접 입력 시 사용)
  - 선택된 학교 정보 저장 및 회원가입 시 전달 로직 구현
- 의존성 주입 설정 업데이트
  - SchoolCubit 및 관련 컴포넌트 등록
  - MultiBlocProvider에 SchoolCubit 추가

### 완료된 작업 (학생 인증 시스템)

- Cloud Functions 구현 완료
  - createStudentAuthAccount: 학생 Firestore 문서 생성 시 Firebase Authentication 계정 자동 생성
  - resetStudentPassword: 교사가 학생 비밀번호를 초기화하기 위한 함수
  - updateStudentGender: 학생이 마이페이지에서 성별 정보 업데이트를 위한 함수
  - studentLogin: 학생이 학교명과 학번으로 로그인할 수 있는 함수
  - createBulkStudentAccounts: 교사가 학생 명단을 일괄 업로드할 때 호출되는 함수
- 클라이언트 측 Cloud Functions 연동 구현
  - CloudFunctionsService 클래스 확장
  - 학생 로그인, 비밀번호 초기화, 성별 업데이트 기능 구현
- 클린 아키텍처에 맞는 연동 구현
  - AuthRemoteDataSource에 Cloud Functions 연동
  - SignInStudent 유스케이스에 학교명 기반 로그인 적용
  - 학생 로그인 UI 수정

### 최근 완료된 작업 (인증 관련 버그 수정)

- CloudFunctionsService 클래스 구조 수정
  - 클래스 외부에 정의된 메서드들을 클래스 내부로 이동시켜 올바른 객체지향 설계 적용
  - studentLogin, createBulkStudentAccounts, updateStudentGender 메서드 위치 수정
- 의존성 주입(DI) 이슈 해결
  - 누락된 CloudFunctionsService 의존성 경로 수정
  - 잘못된 import 경로 수정 (services → cloud_functions_service.dart)
  - 의존성 주입 오류로 인한 회색 화면 문제 해결
- 삭제된 유스케이스 복원
  - LoginWithEmailPassword 유스케이스 파일 복원 및 코드 추가
  - 중복 유스케이스 호환성 유지 (레거시 코드 호환성)
- StudentRemoteDataSource 클래스 수정
  - CloudFunctionsService 올바른 주입 및 사용
  - import 경로 수정

### 최근 완료된 작업 (학교 선택기 버그 수정) ✅

- SchoolSelector 위젯 수정
  - 학교 선택 후 UI 업데이트 문제 해결
  - 리스너 관리 로직 개선
  - 학교 선택 시 _schoolNameController 업데이트 문제 수정
  - 선택된 학교가 있을 때 중복 검색 방지 로직 추가
  - 초기 학교 설정 기능 추가
- RegisterPage 수정
  - 학교 선택 기능 개선
  - _schoolNameController 직접 참조 제거
  - _selectedSchool 상태에 의존하도록 수정
  - 학교 선택 필수 유효성 검사 추가

### 최근 완료된 작업 (학생 인증 시스템 수정)

- 학생 인증 이메일 형식 개선
  - 학교 코드를 반드시 마지막 4자리만 사용하도록 수정 (2530814@school000003550.com → 2530814@school3550.com)
  - 교사 관리 모델의 학교명을 학생 이메일 생성 시 사용하도록 수정
- 학생 가입 초기 비밀번호 변경
  - 초기 비밀번호를 '123456'으로 설정하여 Firebase 인증 요구사항 충족
  - StudentModel의 초기 비밀번호 값 변경
  - StudentRemoteDataSourceImpl 클래스의 이메일 생성 및 인증 로직 수정
  - CloudFunctionsService의 초기 비밀번호 설정 변경

### 최근 완료된 작업 (CORS 문제 해결 및 Cloud Functions 개선)

- studentLogin 함수 수정
  - 학생 로그인 API를 HTTP 요청에서 Callable 함수로 변경
  - CORS 이슈 해결 (Access-Control-Allow-Origin 헤더 문제)
- CloudFunctionsService 클래스 개선
  - studentLogin 메서드를 직접 HTTP 호출에서 `httpsCallable` 사용으로 변경
  - 클린 아키텍처 원칙에 맞게 인터페이스 일관성 확보
- Firebase 함수 개선
  - Cloud Function 함수의 일관성 확보 (모두 Callable 함수로 통일)
  - 에러 처리 로직 개선

### 최근 완료된 작업 (Cloud Functions 버그 해결)

- FirebaseDataSeed 클래스 개선
  - `_seedSchools` 메서드 추가하여 학교 정보를 Firestore에 저장
  - "가락고등학교" 및 다른 테스트 학교 정보 추가
  - 테스트 교사 및 학생 계정에 학교 정보 연결
- FirebaseInitializer 업데이트
  - 앱 초기화 시 테스트 데이터 시드 실행 로직 추가
  - 디버그 모드에서만 데이터 시드 동작하도록 설정
- main.dart 업데이트
  - Firebase 초기화 방식 수정 (FirebaseInitializer 클래스 사용)
  - 학교 데이터 시드 적용

### 최근 완료된 작업 (인증 시스템 버그 수정) ✅

- 학생 로그인 프로세스 개선 ✅
  - 이메일 형식 불일치 문제 해결 (학교 코드 마지막 4자리만 사용) ✅
  - CloudFunctionsService 클래스 개선 (모든 함수를 httpsCallable로 호출) ✅
  - 적절한 에러 처리 및 메시지 표시 추가 ✅
- 학교 정보 문제 해결 ✅
  - FirebaseDataSeed 클래스에 학교 데이터 시드 기능 개선 ✅
  - 교사 회원가입 시 학교 정보 자동 추가 로직 추가 ✅
  - 짧은 학교 코드(마지막 4자리) 일관성 확보 ✅
- 코드 리팩토링 ✅
  - 디버그 로그 추가 (학생 로그인 과정 추적) ✅
  - 모든 데이터 소스에서 예외 처리 통일 (ServerException 사용) ✅
  - AuthRemoteDataSource의 signInStudent 메서드 개선 ✅
  - StudentRemoteDataSourceImpl의 uploadStudents 메서드 개선 ✅

### 최근 완료된 작업 (로그인 시스템 버그 수정) ✅

- AppRouter.dart 파일의 `redirect` 함수 수정 ✅
  - null safety 적용 문제 해결 (`_currentUser!.isAdmin`에서 발생하는 null check operator 오류 수정) ✅
  - `isLoggedIn` 변수를 사용하여 안전하게 사용자 객체 속성에 접근하도록 수정 ✅
  - 관리자 경로, 학생 마이페이지, 학생 업로드 페이지 등 모든 권한 체크 부분에 null safety 적용 ✅
  - 실제 코드의 잠재적인 null 참조 오류 가능성 제거 ✅

### 최근 완료된 작업 (인증 흐름 최적화) ✅

- AuthCubit 클래스 최적화 ✅
  - 인증 상태 체크 중복 방지 기능 추가 ✅
  - 최소 체크 간격 설정 적용 (2초) ✅
  - 현재 상태와 동일한 상태일 때 불필요한 상태 변경 방지 ✅
  - 초기 인증 상태 확인 과정 개선 ✅
- AppRouter 수정 ✅
  - 리디렉션 로직 캐싱 기능 추가 ✅
  - 동일한 경로 및 상태에 대한 리디렉션 결과 저장 ✅
  - 사용자 설정 중복 방지 ✅
- 앱 라이프사이클 관리 개선 ✅
  - 앱 활성화 이벤트 중복 처리 방지 ✅
  - 최소 활성화 간격 설정 (5초) ✅

### 다음 예정 작업

- Cloud Functions 배포 및 테스트
  - Firebase CLI를 이용한 함수 배포
  - 학생 계정 자동 생성 및 비밀번호 초기화 테스트
  - 성별 업데이트 기능 테스트
  - 학생 로그인 기능 테스트
- 학번(studentId)과 학생 번호(studentNum) 구분 확실한 적용
  - 전체 프로젝트에서 일관된 용어 사용
  - UI/UX에서 학생에게 표시되는 학번/학생번호 용어 통일
- 학교 관련 필드 통일 완료
  - schoolCode 필드를 학교 코드 뒤 4자리 숫자로 통일
  - schoolName 필드를 학교명으로 통일
  - 학생 인증용 이메일 형식: "(연도 두자리)(학번)@school(학교코드 뒤 4자리).com"
    - 예: 가락고등학교 3학년 1반 1번, 25년도 → 2530101@school3550.com
- 교사 대시보드에 학생 비밀번호 초기화 기능 추가
  - 학생 관리 화면에 비밀번호 초기화 버튼 추가
  - 초기화 확인 모달 구현
- 교사용 대시보드 나머지 탭 상세 기능 구현
  - 출석부 탭 기능 구현
  - 측정결과조회 탭 기능 구현
  - 평가 탭 기능 구현
  - 되돌아보기 탭 기능 구현
- 학생 관리 기능 개선
  - 학생 비밀번호 초기화 기능 구현
  - 학생 마이페이지 UI 개선

### 발생한 문제점

- 학교 선택기에서 학교 선택 후 텍스트 필드에 학교 이름이 표시되지 않는 문제 ✅

- 앱 실행 시 사용자 데이터 시드 설정 필요 ✅
- 자동 코드 생성 대신 직접 변환 로직 구현 필요 (Freezed, JsonSerializable 사용시 오류)
- 타입 불일치 문제 (Failure vs Exception) ✅
- import 경로 불일치 및 모델-엔티티 구조 일관성 부재
- 웹 배포 환경에서 에셋 파일(paps_standards.json) 로드 문제 ✅
- 웹 환경에서 팝스 측정 기능 작동 안 함 ✅
- 로그인 후 라우팅 문제: LoginPage와 RegisterPage에서 인증 성공 후 '/content-selection'으로 이동해야 하는데 '/home'으로 직접 이동하는 문제 ✅
- student_remote_datasource.dart에서 FirebaseFunctions 임포트 누락 문제 ✅
- sign_in_student.dart와 auth_repository.dart 간의 메서드 파라미터 불일치 문제 (studentNum vs studentId) ✅
- 학생 로그인 시 HTTP 직접 호출로 인한 CORS 이슈 발생 ✅
- Cloud Functions에서 "해당 학교 정보를 찾을 수 없습니다." 에러 발생 ✅
- 로그아웃 후 null check operator 에러 발생 문제 ✅

### 새로 추가된 내용

- 로그인/인증 관련 코드 리팩토링
  - 중복된 LoginWithEmailPassword 유스케이스 제거 (사용하지 않는 파일 정리)
  - 학생 이메일 형식 통일: "(연도 두자리)(학번)@school(학교코드 뒤 4자리).com"
    - 예: 가락고등학교 3학년 1반 1번 학생, 25년도 → 2530101@school3550.com
  - User 및 UserModel 클래스에 schoolName 필드 추가
  - AuthRemoteDataSource 클래스 이메일 생성 로직 수정
  - 학생 여부에 따른 적절한 로그인 처리 개선
- 학생 로그인 유스케이스(SignInStudent) 구현
- 관리자 관련 기능 구현
  - 관리자 역할 추가 (UserRole enum 수정)
  - 관리자 도메인 모델 구현 (AdminRepository 등)
  - 관리자 프레젠테이션 계층 구현 (AdminCubit, AdminLoginPage 등)
  - 숨겨진 관리자 URL 구현 (/admin/login 경로)
- 교사 회원가입 관련 기능 개선
  - 계정 승인 상태 필드 추가 (isApproved)
  - 승인 대기 화면 구현 (WaitingApprovalPage)
  - Firebase Firestore 보안 규칙 개선
- 초기 관리자 계정 자동 생성 기능 구현 (AdminSeed)
- 웹 환경에서 팝스 측정 기능 작동 개선
  - localStorage를 활용한 팝스 기준표 캐싱 기능 구현
  - 다양한 로드 경로 시도 및 폴백 데이터 제공 기능 추가
  - 웹 환경에서 팝스 기준표 미리 로드 기능 구현
- 교사/학생 테스트 계정 자동 생성 기능 구현 (FirebaseDataSeed)
- 이메일/비밀번호 로그인 및 학생 로그인 기능 활성화
- 웹 배포 환경에서 에셋 파일 로드 문제 해결
  - localStorage를 활용한 캐싱 기능 구현
  - 다양한 에셋 로드 전략 구현 (다중 경로 시도)
  - 폴백 데이터 메커니즘 구현
  - 디버깅 로그 추가
- 빌드 및 배포 스크립트(build_and_deploy.sh) 추가
- 교사용 대시보드 추가 ✅
  - TeacherSettings 엔티티 및 모델 구현 ✅
  - TeacherSettingsRepository 인터페이스 및 구현체 개발 ✅
  - GetTeacherSettings, SaveTeacherSettings 유스케이스 구현 ✅
  - TeacherSettingsCubit 구현 ✅
  - 교사용 대시보드 UI 구현 (탭 형식으로 구성) ✅
- 코드 버그 수정 및 구조 개선 작업 ✅
  - AuthFailure 클래스에 code 필드 추가 ✅
  - PapsCubit 클래스에 loadPapsStandards 필드 및 기능 추가 ✅
  - 의존성 주입 구조 개선 (lib/di/injection_container.dart 사용) ✅
  - Firebase 관련 서비스 클래스 개선 및 구현 ✅
  - 오류 처리 개선 (Failure 클래스 구조 통일) ✅
- 교사 회원가입 화면 개선 ✅
  - 핸드폰 번호 필드 추가 ✅
  - 자동 하이픈 포맷 추가 ✅
  - 이메일, 비밀번호 유효성 검사 강화 ✅
  - User 엔티티에 phoneNumber 필드 추가 ✅
- 학생 관리 기능 구현
  - Student 엔티티 구현
  - StudentRepository 구현
  - 학생 업로드 화면 구현
  - 학생 마이페이지 구현
- CORS 문제 해결 ✅
  - 직접 HTTP 호출 대신 Firebase SDK `httpsCallable` 사용 ✅
  - studentLogin 함수 타입 변경 (HTTP 요청 → Callable 함수) ✅
  - 일관된 Cloud Functions 처리 방식 적용 ✅
- Firestore 학교 데이터 추가 기능 구현 ✅
  - FirebaseDataSeed 클래스에 학교 데이터 시드 기능 추가 ✅
  - 앱 초기화 시 학교 데이터 자동 추가 기능 구현 ✅
- 인증 시스템 버그 수정 ✅
  - 학생 이메일 형식 통일 (학교 코드 마지막 4자리만 사용) ✅
  - 모든 Cloud Functions 호출을 httpsCallable로 통일 ✅
  - 적절한 에러 처리 및 로깅 추가 ✅
- 라우터 null safety 적용 ✅
  - AppRouter의 redirect 함수에서 null 체크 강화 ✅
  - _currentUser 객체 접근 전 isLoggedIn 확인 추가 ✅
  - 모든 사용자 속성 접근 시 null 체크 로직 적용 ✅

### 테스트 계정 정보

**교사 계정:**

- 이메일: teacher@test.com
- 비밀번호: teacher123

**학생 계정:**

- 이메일: student1@school.com (직접 사용할 필요 없음)
- 학교 코드: school1
- 학번: 1
- 비밀번호: student123

**관리자 계정:**

- 아이디: admin
- 비밀번호: admin123
- 접근 URL: /admin/login

1. **Firebase Console 추가 설정**

   - Firebase Authentication에서 이메일/비밀번호 로그인 활성화 ✅
   - Firestore 데이터베이스 보안 규칙 작성 및 적용 ✅
   - 초기 관리자 계정 생성 기능 구현 ✅
   - Firebase 호스팅 구성 및 웹 앱 배포 ✅

2. **추가 기능 구현**

   - 학생용 로그인 기능 완성 ✅
   - 관리자 기능 구현 ✅
   - 교사 계정 승인 기능 구현 ✅
   - 학생 기록 관리 화면 구현 (교사용)
   - 내 기록 조회 화면 구현 (학생용)
   - 보고서 생성 기능 구현
   - 데이터 모델 간 일관성 확보
   - 학생 비밀번호 초기화 기능 개선
   - 학생 마이페이지 UI 개선
   - 교사 회원가입 화면 개선 (핸드폰 번호 추가, 유효성 검사 기능 강화) ✅
   - 학생 업로드 기능 구현 ✅
   - 학생 마이페이지 구현 ✅

3. **테스트 및 배포**
   - 단위 테스트 작성
   - 통합 테스트 작성
   - 실 사용자 대상 베타 테스트 진행

## 클린 아키텍처 구현 현황

### 도메인 계층 (Domain Layer)

- **엔티티**: 핵심 비즈니스 모델 구현 완료 및 구조 개선
  - User, PapsRecord, PapsStandard, TeacherSettings, Student, School 등
  - 구조 일관성을 위해 entities 폴더로 통합 관리
- **레포지토리 인터페이스**: 데이터 접근 추상화 구현 완료
  - AuthRepository, PapsRepository, TeacherSettingsRepository, AdminRepository, StudentRepository, SchoolRepository 등
  - API 일관성을 위해 모든 실패 반환 타입을 Failure로 통일
- **유스케이스**: 핵심 비즈니스 로직 구현 완료
  - LoadPapsStandards, CalculatePapsGrade, SignInWithEmailPassword, GetTeacherSettings, SaveTeacherSettings, SignInAdmin, ApproveTeacher, UploadStudents, GetStudentsByTeacher, ChangeStudentPassword, GetRegions, GetSchoolsByRegion, SearchSchools 등

### 프레젠테이션 계층 (Presentation Layer)

- **UI 화면**: 주요 화면 구현 완료
  - 인증 화면, 홈 화면, 팝스 기준표 화면, 팝스 측정 화면, 교사용 대시보드, 관리자 화면, 학생 업로드 화면, 학생 마이페이지 등
- **상태 관리**: BLoC/Cubit 패턴 적용 완료
  - AuthCubit, PapsCubit, TeacherSettingsCubit, AdminCubit, StudentCubit, SchoolCubit 등

### 데이터 계층 (Data Layer)

- **데이터 소스**: 로컬/원격 데이터 접근 구현 완료
  - PapsLocalDataSource, PapsRemoteDataSource, AuthRemoteDataSource, AuthLocalDataSource, TeacherSettingsRemoteDataSource, AdminRemoteDataSource, StudentRemoteDataSource, SchoolLocalDataSource 등
- **레포지토리 구현체**: 레포지토리 인터페이스 구현 완료 및 개선
  - PapsRepositoryImpl, AuthRepositoryImpl, TeacherSettingsRepositoryImpl, AdminRepositoryImpl, StudentRepositoryImpl, SchoolRepositoryImpl 등
  - 코드 생성 의존성 제거 및 수동 직렬화 로직 구현

## 의존성 주입

- GetIt을 이용한 의존성 주입 설정 구현 완료
- 주요 서비스, 레포지토리, 유스케이스 의존성 등록 완료
- 의존성 주입 구조 개선 (lib/di/injection_container.dart 사용)
- 관리자 기능 관련 의존성 등록 완료
- 학생 관리 기능 관련 의존성 등록 완료
- 학교 선택 기능 관련 의존성 등록 완료

## 오류 처리 개선

- Failure 클래스 구조 개선
  - 모든 Failure 클래스에 message 필드 추가
  - AuthFailure에 code 필드 추가
  - ServerFailure, NetworkFailure, CacheFailure에 기본 오류 메시지 설정
  - UnknownFailure 클래스 추가

## 주요 기능 및 우선순위

1. **MVP (최소 기능 제품) - 1단계 (완료)**

   - 기준표 조회 기능 (학생)
   - 측정 종목 선택 기능 (교사)
   - 측정 기록 저장 및 등급/점수 자동 산출 기능 (학생)

2. **확장 기능 - 2단계 (진행 중)**

   - 교사 계정 승인 기능 (관리자) ✅
   - 학생 명단 관리 ✅
   - 활동 결과(소감문) 제출 및 관리
   - 데이터 엑셀 다운로드

3. **추가 기능 - 3단계 (진행 예정)**
   - 모둠 활동 기능
   - 소감문 채점/피드백 기능
   - 교사/학생 대시보드 개선

## 일정 계획

- **초기 설정 및 구조화**: 완료
- **데이터 모델 구현**: 완료
- **레포지토리 및 유스케이스 구현**: 완료
- **UI 개발**: 완료
- **Firebase 연결**: 완료
- **관리자 기능 개발**: 완료
- **학생 관리 기능 개발**: 진행 중
- **추가 기능 개발**: 진행 중
- **테스트 및 배포**: 진행 예정

## Firebase 연동 현황

- Firebase 초기화 설정 구현 완료
- Firebase Authentication 연동 구현 완료
- Firestore 연동 구현 완료
- FlutterFire CLI를 통한 Firebase 프로젝트 연결 완료
- Firebase 서비스 클래스 구현 완료 (FirebaseAuthService, FirebaseFirestoreService, FirebaseDataSeed)
- Firebase Hosting 설정 및 웹앱 배포 완료
- Firestore 보안 규칙 구현 완료
- 초기 관리자 계정 자동 생성 기능 구현 완료
- 학교 데이터 시드 기능 구현 완료
- Cloud Functions 개선 및 문제 해결 ✅
  - studentLogin 함수를 Callable 함수로 변경 ✅
  - 모든 함수 호출 방식을 일관되게 httpsCallable로 통일 ✅
  - 에러 처리 및 로깅 개선 ✅

## 향후 개선 사항

- **오프라인 지원**: 네트워크 연결이 없는 환경에서도 기본 기능을 사용할 수 있도록 오프라인 모드 지원
- **데이터 동기화**: 로컬에 저장된 데이터와 서버 데이터의 효율적인 동기화 메커니즘 구현
- **사용성 개선**: 사용자 피드백을 반영한 UI/UX 개선
- **코드 최적화**: 빌드 크기 감소 및 성능 최적화
- **테스트 자동화**: CI/CD 파이프라인 구축
- **라우팅 안정성 개선**: 로그인/로그아웃 시 예외 처리 강화 및 사용자 경험 개선
