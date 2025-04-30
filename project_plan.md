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
- Firebase 연동 설정
  - FirebaseInitializer 구현
  - 의존성 주입 설정 (GetIt 이용)
  - main.dart 파일 업데이트

### 현재 진행 중인 작업
- 프레젠테이션 계층 구현 (UI 화면 및 상태 관리)

### 다음 예정 작업
1. 팝스 관련 UI 화면 개발
   - 팝스 기준표 조회 화면
   - 측정 종목 선택 화면 (교사용)
   - 측정 기록 저장 및 등급/점수 자동 산출 화면 (학생용)
   - 학생 기록 조회 화면 (교사용)
2. 인증 관련 UI 화면 개발
   - 로그인 화면 (교사/학생)
   - 회원가입 화면 (교사)
   - 학생 계정 생성 화면 (교사용)
3. 상태 관리 구현 (BLoC/Cubit)
   - AuthCubit 구현
   - PapsCubit 구현

## 클린 아키텍처 구현 현황

### 도메인 계층 (Domain Layer)
- **엔티티**: 핵심 비즈니스 모델 구현 완료
  - User, PapsRecord, PapsStandard 등
- **레포지토리 인터페이스**: 데이터 접근 추상화 구현 완료
  - AuthRepository, PapsRepository
- **유스케이스**: 핵심 비즈니스 로직 구현 진행 중
  - LoadPapsStandards, CalculatePapsGrade, SignInWithEmailPassword 구현 완료

### 데이터 계층 (Data Layer)
- **데이터 소스**: 로컬/원격 데이터 접근 구현 완료
  - PapsLocalDataSource, PapsRemoteDataSource, AuthRemoteDataSource
- **레포지토리 구현체**: 레포지토리 인터페이스 구현 완료
  - PapsRepositoryImpl, AuthRepositoryImpl

### 프레젠테이션 계층 (Presentation Layer)
- **UI 화면**: 개발 예정
- **상태 관리**: 개발 예정 (BLoC/Cubit 패턴 적용 예정)

## Firebase 연동 현황
- Firebase 초기화 설정 구현 완료
- Firebase Authentication 연동 구현 완료
- Firestore 연동 구현 완료
- Firebase Storage, Hosting 연동 예정

## 의존성 주입
- GetIt을 이용한 의존성 주입 설정 구현 완료
- 주요 서비스, 레포지토리, 유스케이스 의존성 등록 완료

## 주요 기능 및 우선순위
1. **MVP (최소 기능 제품) - 1단계**
   - 기준표 조회 기능 (학생)
   - 측정 종목 선택 기능 (교사)
   - 측정 기록 저장 및 등급/점수 자동 산출 기능 (학생)

2. **확장 기능 - 2단계**
   - 학생 명단 관리
   - 활동 결과(소감문) 제출 및 관리
   - 데이터 엑셀 다운로드 (NEIS 연계)

3. **추가 기능 - 3단계**
   - 모둠 활동 기능
   - 소감문 채점/피드백 기능

## 사용 기술 스택
- **프론트엔드**: Flutter Web
- **백엔드**: Firebase (Authentication, Firestore, Hosting, Functions)
- **상태 관리**: BLoC/Cubit
- **기타 도구**: 
  - GetIt (의존성 주입)
  - Dartz (함수형 프로그래밍)
  - Equatable (객체 비교)

## 일정 계획
- **초기 설정 및 구조화**: 완료
- **데이터 모델 구현**: 완료
- **레포지토리 및 유스케이스 구현**: 완료
- **UI 개발**: 진행 예정
- **테스트 및 피드백**: 예정
- **확장 기능 개발**: 예정