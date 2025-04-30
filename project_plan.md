# 온라인 팝스(PAPS) 교육 플랫폼 개발 계획

## 프로젝트 개요

- **프로젝트명**: 온라인 팝스(PAPS) 교육 플랫폼
- **개발 목표**: 학교 현장의 팝스(PAPS) 단원 운영을 내실화하고, 학생들의 자기 주도 학습 및 교사의 효율적인 수업 운영/평가를 지원하는 웹 기반 교육 플랫폼 개발
- **아키텍처**: Flutter + Firebase 기반, 클린 아키텍처 적용

## 개발 현황

### 완료된 작업

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
  - AuthRepositoryImpl 구현체 개발
  - SignInWithEmailPassword 유스케이스 구현
  - GetCurrentUser 유스케이스 구현
  - RegisterTeacher 유스케이스 구현
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
- 테마 구현
  - 앱 전체 테마 설정 (색상, 타이포그래피, 컴포넌트 스타일)

### 현재 진행 중인 작업

- Firebase Authentication 설정 (이메일/비밀번호 인증 활성화)
- Firestore 데이터베이스 보안 규칙 설정
- 학생용 로그인 구현 완성

### 발생한 문제점

- 앱 실행 시 사용자 데이터 시드 설정 필요

### 다음 예정 작업

1. **Firebase Console 추가 설정**

   - Firebase Authentication에서 이메일/비밀번호 로그인 활성화
   - Firestore 데이터베이스 보안 규칙 작성 및 적용
   - 초기 관리자 계정 생성

2. **추가 기능 구현**

   - 학생용 로그인 기능 완성
   - 학생 기록 관리 화면 구현 (교사용)
   - 내 기록 조회 화면 구현 (학생용)
   - 보고서 생성 기능 구현

3. **테스트 및 배포**
   - 단위 테스트 작성
   - 통합 테스트 작성
   - Firebase Hosting을 통한 웹앱 배포

## 클린 아키텍처 구현 현황

### 도메인 계층 (Domain Layer)

- **엔티티**: 핵심 비즈니스 모델 구현 완료
  - User, PapsRecord, PapsStandard 등
- **레포지토리 인터페이스**: 데이터 접근 추상화 구현 완료
  - AuthRepository, PapsRepository
- **유스케이스**: 핵심 비즈니스 로직 구현 완료
  - LoadPapsStandards, CalculatePapsGrade, SignInWithEmailPassword 등

### 데이터 계층 (Data Layer)

- **데이터 소스**: 로컬/원격 데이터 접근 구현 완료
  - PapsLocalDataSource, PapsRemoteDataSource, AuthRemoteDataSource
- **레포지토리 구현체**: 레포지토리 인터페이스 구현 완료
  - PapsRepositoryImpl, AuthRepositoryImpl

### 프레젠테이션 계층 (Presentation Layer)

- **UI 화면**: 주요 화면 구현 완료
  - 인증 화면, 홈 화면, 팝스 기준표 화면, 팝스 측정 화면 등
- **상태 관리**: BLoC/Cubit 패턴 적용 완료
  - AuthCubit, PapsCubit

## Firebase 연동 현황

- Firebase 초기화 설정 구현 완료
- Firebase Authentication 연동 구현 완료
- Firestore 연동 구현 완료
- FlutterFire CLI를 통한 Firebase 프로젝트 연결 완료
- Firebase 서비스 클래스 구현 완료 (FirebaseAuthService, FirebaseFirestoreService)

## 의존성 주입

- GetIt을 이용한 의존성 주입 설정 구현 완료
- 주요 서비스, 레포지토리, 유스케이스 의존성 등록 완료

## 주요 기능 및 우선순위

1. **MVP (최소 기능 제품) - 1단계 (완료)**

   - 기준표 조회 기능 (학생)
   - 측정 종목 선택 기능 (교사)
   - 측정 기록 저장 및 등급/점수 자동 산출 기능 (학생)

2. **확장 기능 - 2단계 (진행 예정)**

   - 학생 명단 관리
   - 활동 결과(소감문) 제출 및 관리
   - 데이터 엑셀 다운로드

3. **추가 기능 - 3단계 (진행 예정)**
   - 모둠 활동 기능
   - 소감문 채점/피드백 기능

## 일정 계획

- **초기 설정 및 구조화**: 완료
- **데이터 모델 구현**: 완료
- **레포지토리 및 유스케이스 구현**: 완료
- **UI 개발**: 완료
- **Firebase 연결**: 완료
- **추가 기능 개발**: 진행 예정
- **테스트 및 배포**: 진행 예정

## 향후 개선 사항

- **오프라인 지원**: 네트워크 연결이 없는 환경에서도 기본 기능을 사용할 수 있도록 오프라인 모드 지원
- **데이터 동기화**: 로컬에 저장된 데이터와 서버 데이터의 효율적인 동기화 메커니즘 구현
- **사용성 개선**: 사용자 피드백을 반영한 UI/UX 개선
