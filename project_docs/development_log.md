## 2025-05-09: 학교 선택기 버그 수정

### 수정 사항
- 학교 선택기 위젯에서 학교를 선택했을 때 텍스트 필드에 학교 이름이 제대로 표시되지 않는 문제 해결
- 학교 선택 시 TextField 컨트롤러 업데이트 방식 개선
  - 컨트롤러의 리스너를 일시적으로 제거하고 값 설정 후 리스너 다시 추가
  - WidgetsBinding.instance.addPostFrameCallback 사용하여 UI 업데이트 타이밍 개선
- 회원가입 페이지의 중복 코드 제거

### 버그 원인
- 학교 선택 후 컨트롤러 값 업데이트 과정에서 포커스 해제와 동시에 발생하는 타이밍 문제
- TextField의 리스너가 값 변경 시 검색 기능을 다시 호출하여 발생하는 상태 불일치

### 해결 방안
- 리스너 로직을 별도 메서드로 분리하여 필요할 때 일시적으로 비활성화
- 프레임 완료 후 텍스트 필드 값을 설정하도록 하여 UI 업데이트 타이밍 개선
# 개발 로그

## 2025-05-09: 교사 회원가입 화면에 학교 선택 기능 추가

### 구현 개요
교사 회원가입 화면에 지역별 학교 선택 기능을 추가했습니다. 학교코드 데이터는 교육부에서 제공하는 JSON 파일을 활용하여 지역 선택 후 학교명 검색 및 자동완성 기능을 제공합니다.

### 주요 구현 내용

1. **모델 계층:**
   - `School` 엔티티: 학교 정보를 표현하는 도메인 모델 (코드, 이름, 설립연도, 성별구분, 학교종류 등)
   - `SchoolModel`: JSON 파일 데이터를 처리하는 모델 클래스

2. **데이터 계층:**
   - `SchoolLocalDataSource`: 에셋 폴더의 지역별 학교 JSON 파일을 로드하는 데이터 소스
   - `SchoolRepository`: 학교 데이터 관리 인터페이스 및 구현체

3. **도메인 계층:**
   - `GetRegions`: 지역 목록 조회 유스케이스
   - `GetSchoolsByRegion`: 특정 지역의 학교 목록 조회 유스케이스
   - `SearchSchools`: 학교 이름으로 검색 유스케이스

4. **프레젠테이션 계층:**
   - `SchoolCubit` & `SchoolState`: 학교 데이터 상태 관리
   - `SchoolSelector`: 지역 선택 및 학교 검색 위젯 (자동완성 기능 포함)
   - `RegisterPage` 수정: 학교 선택 기능 통합

5. **의존성 주입 및 설정:**
   - 의존성 주입 설정 업데이트 (`injection_container.dart`)
   - MultiBlocProvider에 SchoolCubit 추가 (`main.dart`)

### 폴더 구조
새로운 기능을 위해 추가된 폴더 구조:
```
lib/
└── features/
    └── common/
        ├── data/
        │   ├── datasources/
        │   │   └── school_local_data_source.dart
        │   ├── models/
        │   │   └── school_model.dart
        │   └── repositories/
        │       └── school_repository_impl.dart
        ├── domain/
        │   ├── entities/
        │   │   └── school.dart
        │   ├── repositories/
        │   │   └── school_repository.dart
        │   └── usecases/
        │       ├── get_regions.dart
        │       ├── get_schools_by_region.dart
        │       └── search_schools.dart
        └── presentation/
            ├── cubit/
            │   ├── school_cubit.dart
            │   └── school_state.dart
            └── widgets/
                └── school_selector.dart
```

### UI 기능 흐름
1. 교사 회원가입 화면에서 사용자는 먼저 지역을 선택합니다.
2. 학교명 입력 필드에 학교 이름을 입력하면 자동으로 검색 결과가 표시됩니다.
3. 검색 결과에서 학교를 선택하거나, 검색되지 않는 경우 직접 입력할 수 있습니다.
4. 학교 선택 시 학교 코드가 저장되고, 직접 입력 시 입력한 학교명이 저장됩니다.

### 학교 데이터 구조
학교 데이터는 다음과 같은 형식의 JSON 파일로 저장되어 있습니다:
```json
[
  {
    "﻿학교코드": "A000003507",
    "학교명": "서울교육대학교부설초등학교",
    "설립년도": "1953",
    "남녀공학구분명": "남여공학",
    "주야구분명": "주간",
    "우편번호시도명": "서울특별시",
    "학교종류구분명": "초등학교",
    "설립구분명": "국립"
  },
  ...
]
```

### 향후 개선 사항
- 학교 데이터 업데이트 메커니즘 추가
- 학교 검색 성능 최적화
- 학교 상세 정보 표시 기능 보강
