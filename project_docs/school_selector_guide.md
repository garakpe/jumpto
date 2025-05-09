# 학교 선택 위젯 사용 가이드

## 개요
`SchoolSelector` 위젯은 지역을 선택하고 학교를 검색하여 선택할 수 있는 UI 컴포넌트입니다. 교사 회원가입 화면이나 학생 정보 입력 등 학교 정보가 필요한 다양한 화면에서 재사용할 수 있습니다.

## 특징

- **지역 기반 학교 검색**: 먼저 지역을 선택한 후 해당 지역의 학교만 검색하여 사용자 경험 개선
- **자동 완성**: 학교명 입력 시 실시간으로 검색 결과 표시
- **학교 상세 정보**: 학교명과 함께 학교 유형, 설립 구분 등 추가 정보 표시
- **직접 입력 옵션**: 검색 결과가 없는 경우 사용자가 직접 학교명 입력 가능
- **클린 아키텍처**: 데이터 로드와 UI 표시를 분리하여 유지보수성 향상

## 사용 방법

### 1. SchoolCubit 제공

먼저 상위 위젯에서 `SchoolCubit`을 제공해야 합니다. 일반적으로 `main.dart`의 `MultiBlocProvider`에 추가합니다:

```dart
MultiBlocProvider(
  providers: [
    // 다른 Cubit들...
    BlocProvider<SchoolCubit>(
      create: (context) => sl<SchoolCubit>(),
    ),
  ],
  child: MaterialApp(/* ... */),
)
```

### 2. 위젯 사용

위젯 사용 시 필요한 속성:

```dart
SchoolSelector(
  // 필수: 학교 선택 시 호출될 콜백 함수
  onSchoolSelected: (School? school) {
    // 선택된 학교 처리
    setState(() {
      _selectedSchool = school;
      if (school != null) {
        _schoolNameController.text = school.name;
      } else {
        _schoolNameController.text = '';
      }
    });
  },
  
  // 선택사항: 힌트 텍스트 (기본값: '학교를 선택하세요')
  hintText: '근무 중인 학교를 선택하세요',
  
  // 선택사항: 직접 입력 옵션 제공 여부 (기본값: true)
  allowCustomInput: true,
)
```

### 3. 선택된 학교 정보 활용

선택된 학교 정보는 `onSchoolSelected` 콜백을 통해 전달됩니다. School 객체에 포함된 정보:

- `code`: 학교 코드
- `name`: 학교명
- `establishmentYear`: 설립년도
- `genderType`: 남녀공학 구분
- `dayNightType`: 주야구분
- `region`: 지역명
- `schoolType`: 학교 종류
- `foundationType`: 설립 구분

### 4. 직접 입력 처리

사용자가 직접 입력한 경우 `School` 객체의 `code`가 'custom'으로 설정됩니다. 이를 통해 직접 입력인지 선택된 학교인지 구분할 수 있습니다:

```dart
if (_selectedSchool?.code == 'custom') {
  // 직접 입력된 학교명 사용
  final schoolName = _schoolNameController.text;
  // ...
} else {
  // 선택된 학교 코드 사용
  final schoolCode = _selectedSchool!.code;
  // ...
}
```

## 비동기 데이터 로드 및 상태 처리

위젯은 내부적으로 `SchoolCubit`을 사용하여 비동기적으로 학교 데이터를 로드하고 상태를 관리합니다:

1. 초기 상태: 지역 목록 로드 (`RegionsLoaded`)
2. 지역 선택 시: 해당 지역의 학교 목록 로드 (`SchoolsLoaded`)
3. 학교명 입력 시: 실시간 필터링으로 검색 결과 업데이트 (`SchoolsLoaded` with filtered schools)
4. 오류 발생 시: 오류 메시지 표시 (`SchoolError`)

## 구현 예시

`RegisterPage`에서의 구현 예시:

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      '학교 선택',
      style: Theme.of(context).textTheme.titleMedium,
    ),
    const SizedBox(height: 8),
    SchoolSelector(
      hintText: '근무 중인 학교를 선택하세요',
      allowCustomInput: true,
      onSchoolSelected: (school) {
        setState(() {
          _selectedSchool = school;
          if (school != null) {
            _schoolNameController.text = school.name;
          } else {
            _schoolNameController.text = '';
          }
        });
      },
    ),
  ],
)
```

## 확장 가능성

- 학교 종류 필터링 기능 추가 (초등학교/중학교/고등학교)
- 지도 연동으로 위치 기반 학교 찾기 기능
- 온라인 API 연동으로 최신 학교 데이터 활용
