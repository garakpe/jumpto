# 프로젝트 폴더 구조

이 문서는 온라인 팝스(PAPS) 교육 플랫폼의 폴더 구조를 설명합니다. 클린 아키텍처를 기반으로 구성되어 있으며, 코드의 모듈성과 테스트 용이성을 높이기 위해 설계되었습니다.

## 루트 디렉토리

```
/Users/smartchoi/Desktop/jumpto/
├── android/              # 안드로이드 플랫폼 관련 코드 
├── assets/               # 앱에서 사용하는 리소스 파일 
│   └── data/             # JSON 데이터 파일 등
├── build/                # 빌드 결과물
├── ios/                  # iOS 플랫폼 관련 코드
├── lib/                  # 주요 Dart/Flutter 코드 (상세 구조 아래 참조)
├── macos/                # macOS 플랫폼 관련 코드
├── project_docs/         # 프로젝트 문서
├── test/                 # 테스트 코드
└── web/                  # 웹 플랫폼 관련 코드
```

## lib 폴더 구조

lib 폴더는 클린 아키텍처를 따라 다음과 같이 구성되어 있습니다:

```
lib/
├── core/                 # 앱 전체에서 사용되는 공통 기능 
│   ├── config/           # 앱 설정 관련 클래스
│   ├── constants/        # 상수 값 정의
│   ├── error/            # 오류 관련 클래스 (Failure 등)
│   ├── errors/           # 추가 오류 관련 클래스
│   ├── firebase/         # Firebase 서비스 관련 코드
│   ├── network/          # 네트워크 관련 유틸리티
│   ├── presentation/     # 공통 UI 관련 코드
│   │   └── theme/        # 앱 테마 정의
│   ├── routes/           # 라우팅 관련 코드 (GoRouter 등)
│   ├── usecases/         # 기본 UseCase 추상 클래스
│   ├── util/             # 유틸리티 함수들
│   └── widgets/          # 공통 위젯 (AppButton, AppTextField 등)
├── di/                   # 의존성 주입 관련 코드
│   └── injection_container.dart  # GetIt 기반 의존성 주입 설정
├── features/             # 앱의 주요 기능 모듈 (기능별로 분리)
│   ├── auth/             # 인증 관련 기능
│   │   ├── data/         # 데이터 계층 (Repository 구현, DataSource)
│   │   ├── domain/       # 도메인 계층 (Entities, Repository 인터페이스, UseCases)
│   │   └── presentation/ # 프레젠테이션 계층 (Pages, Widgets, Cubits)
│   ├── common/           # 여러 기능에서 공유되는 코드
│   └── paps/             # 팝스(PAPS) 관련 기능
│       ├── data/         # 데이터 계층
│       │   ├── datasources/      # 데이터 소스 (Local, Remote)
│       │   ├── models/           # API 응답 모델 클래스
│       │   └── repositories/     # Repository 구현체
│       ├── domain/       # 도메인 계층
│       │   ├── entities/         # 비즈니스 모델 (엔티티)
│       │   ├── repositories/     # Repository 인터페이스
│       │   └── usecases/         # 유스케이스 (비즈니스 로직)
│       └── presentation/ # 프레젠테이션 계층
│           ├── bloc/             # BLoC 패턴 클래스 (있는 경우)
│           ├── cubit/            # Cubit 패턴 클래스
│           ├── pages/            # 화면 UI
│           └── widgets/          # 화면별 위젯
├── firebase_options.dart # Firebase 구성 옵션
├── injection_container.dart # 의존성 주입 설정(GetIt)
└── main.dart             # 앱 시작점
```

## 주요 모듈 설명

### core/

앱 전체에서 공통으로 사용되는 기능들을 포함합니다. 특정 기능에 종속되지 않는 유틸리티, 위젯, 상수 등이 여기에 위치합니다.

* `error/`: Failure 클래스와 같은 오류 관련 클래스 정의
* `firebase/`: Firebase 서비스 초기화 및 데이터 시드 코드
* `presentation/theme/`: 앱의 색상, 텍스트 스타일 등 테마 설정
* `routes/`: GoRouter를 사용한 라우팅 설정
* `widgets/`: 재사용 가능한 공통 위젯 구현

### di/

의존성 주입을 위한 코드가 포함됩니다. GetIt 라이브러리를 사용하여 서비스 로케이터 패턴을 구현합니다.

### features/

앱의 주요 기능들을 모듈별로 분리하여 포함합니다. 각 기능은 클린 아키텍처의 3계층으로 구성됩니다:

1. **데이터 계층 (data/)**
   - 외부 데이터 소스(API, 로컬 저장소 등)와의 통신 담당
   - 모델 클래스 및 변환 로직 포함
   - Repository 인터페이스 구현

2. **도메인 계층 (domain/)**
   - 비즈니스 로직을 담당
   - Entity, Repository 인터페이스, UseCase 포함
   - 외부 의존성으로부터 독립적인 코어 비즈니스 로직

3. **프레젠테이션 계층 (presentation/)**
   - UI 및 상태 관리 담당
   - BLoC/Cubit을 통한 상태 관리
   - 화면(Page) 및 UI 컴포넌트(Widget) 포함

#### auth/

사용자 인증 관련 기능을 담당합니다. 로그인, 회원가입, 인증 상태 관리 등의 기능이 포함됩니다.

* `domain/entities/`: User 엔티티 등
* `domain/usecases/`: SignInWithEmailPassword, GetCurrentUser 등
* `presentation/cubit/`: AuthCubit (인증 상태 관리)
* `presentation/pages/`: LoginPage, RegisterPage 등

#### paps/

팝스(PAPS) 관련 핵심 기능을 담당합니다. 팝스 기준표 조회, 측정 기록 관리 등의 기능이 포함됩니다.

* `domain/entities/`: PapsStandard, PapsRecord 등
* `domain/usecases/`: LoadPapsStandards, CalculatePapsGrade 등
* `presentation/cubit/`: PapsCubit (팝스 관련 상태 관리)
* `presentation/pages/`: PapsStandardsPage, PapsMeasurementPage 등

## 아키텍처 다이어그램

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  Presentation   │     │     Domain      │     │      Data       │
│    Layer        │     │     Layer       │     │     Layer       │
│                 │     │                 │     │                 │
│  UI (Pages)     │     │   Use Cases     │     │   Repositories  │
│  State (Cubit)  │◄────┤   Entities      │◄────┤   Data Sources  │
│  Widgets        │     │   Repositories  │     │   Models        │
└─────────────────┘     └─────────────────┘     └─────────────────┘
       ▲                                                 ▲
       │                                                 │
       │                                                 │
       └─────────────────┐               ┌───────────────┘
                         ▼               ▼
                     ┌───────────────────────┐
                     │    Dependency         │
                     │    Injection          │
                     │    (GetIt)            │
                     └───────────────────────┘
```

## 파일 명명 규칙

* 파일명은 소문자와 밑줄을 사용합니다 (snake_case).
* 각 계층별 파일 접미사 규칙:
  - 엔티티: `user.dart`, `paps_record.dart`
  - 레포지토리 인터페이스: `auth_repository.dart`, `paps_repository.dart`
  - 레포지토리 구현체: `auth_repository_impl.dart`, `paps_repository_impl.dart`
  - 유스케이스: `sign_in_with_email_password.dart`, `calculate_paps_grade.dart`
  - 화면: `login_page.dart`, `paps_measurement_page.dart`
  - 큐빗/블록: `auth_cubit.dart`, `paps_cubit.dart`

## 확장성

이 구조는 새로운 기능을 쉽게 추가할 수 있도록 설계되었습니다. 새 기능을 추가하려면:

1. `lib/features/` 아래에 새 기능 모듈 디렉토리 생성 (예: `schedule/`)
2. 해당 디렉토리 내에 `data/`, `domain/`, `presentation/` 계층 디렉토리 생성
3. 각 계층에 필요한 컴포넌트 구현
4. `injection_container.dart`에 의존성 등록
