# API 문서

이 문서는 온라인 팝스(PAPS) 교육 플랫폼의 주요 API 및 유스케이스의 용도와 사용법을 설명합니다.

## 도메인 레이어 (Domain Layer)

### LoadPapsStandards

팝스 기준표 데이터를 로드하는 유스케이스입니다.

#### 주요 메서드

##### `getStandardsCollection()`

```dart
Future<PapsStandardsCollection> getStandardsCollection()
```

**설명**: 모든 팝스 기준표 데이터를 포함하는 컬렉션을 로드합니다.

**동작 방식**:
- 싱글톤 패턴으로 구현되어 있어 한 번 로드된 데이터는 메모리에 캐싱됩니다.
- 웹 환경에서는 다음과 같은 순서로 데이터 로드를 시도합니다:
  1. localStorage에서 캐싱된 데이터 확인
  2. 다양한 경로로 assets에서 JSON 파일 로드 시도
  3. 모든 시도 실패 시 기본 폴백 데이터 사용
- 모바일/데스크톱 환경에서는 일반적인 에셋 로드 방식 사용

**반환**: `PapsStandardsCollection` 타입의 기준표 컬렉션

**사용 예시**:
```dart
final standardsCollection = await loadPapsStandards.getStandardsCollection();
```

##### `calculateGradeAndScore()`

```dart
Future<Map<String, dynamic>?> calculateGradeAndScore({
  required SchoolLevel schoolLevel,
  required int gradeNumber,
  required Gender gender, 
  required FitnessFactor fitnessFactor,
  required String eventName,
  required double value,
})
```

**설명**: 주어진 측정값에 대한 등급과 점수를 계산합니다.

**매개변수**:
- `schoolLevel`: 학교급 (초/중/고)
- `gradeNumber`: 학년 (1~6)
- `gender`: 성별 (남/여)
- `fitnessFactor`: 체력요인 (심폐지구력, 유연성 등)
- `eventName`: 평가종목 이름 (왕복오래달리기 등)
- `value`: 측정값

**반환**: 등급과 점수를 포함하는 Map (`{ "grade": int, "score": int }`) 또는 null

**사용 예시**:
```dart
final result = await loadPapsStandards.calculateGradeAndScore(
  schoolLevel: SchoolLevel.elementary,
  gradeNumber: 5,
  gender: Gender.male,
  fitnessFactor: FitnessFactor.cardioEndurance,
  eventName: "왕복오래달리기",
  value: 50.0,
);

if (result != null) {
  final grade = result["grade"]; // 3
  final score = result["score"]; // 14
}
```

##### `findStandard()`

```dart
Future<PapsStandard?> findStandard({
  required SchoolLevel schoolLevel,
  required int gradeNumber,
  required Gender gender,
  required FitnessFactor fitnessFactor,
  required String eventName,
})
```

**설명**: 주어진 조건에 맞는 팝스 기준표를 찾습니다.

**매개변수**:
- `schoolLevel`: 학교급 (초/중/고)
- `gradeNumber`: 학년 (1~6)
- `gender`: 성별 (남/여)
- `fitnessFactor`: 체력요인 (심폐지구력, 유연성 등)
- `eventName`: 평가종목 이름 (왕복오래달리기 등)

**반환**: 조건에 맞는 `PapsStandard` 객체 또는 null

### CalculatePapsGrade

팝스 측정값의 등급 및 점수를 계산하는 유스케이스입니다.

#### 주요 메서드

##### `calculate()`

```dart
Future<Map<String, dynamic>?> calculate({
  required SchoolLevel schoolLevel,
  required int gradeNumber,
  required Gender gender,
  required FitnessFactor fitnessFactor,
  required String eventName,
  required double value,
})
```

**설명**: 측정값에 대한 등급 및 점수를 계산합니다. 내부적으로 `LoadPapsStandards.calculateGradeAndScore()`를 호출합니다.

##### `calculateTotalScore()`

```dart
int calculateTotalScore(List<PapsRecord> records)
```

**설명**: 학생의 팝스 측정 기록 리스트에서 총점을 계산합니다.

**매개변수**:
- `records`: 학생의 팝스 측정 기록 리스트

**반환**: 총 점수 (0~100점)

##### `calculateOverallGrade()`

```dart
int calculateOverallGrade(int totalScore)
```

**설명**: 총점에 대한 종합 등급을 계산합니다.

**매개변수**:
- `totalScore`: 총점 (0~100점)

**반환**: 종합 등급 (1~5)

### GetPapsStandards

특정 조건에 맞는 팝스 기준표를 조회하는 유스케이스입니다.

```dart
Future<Either<Failure, PapsStandard?>> call(GetPapsStandardsParams params)
```

**설명**: Repository를 통해 특정 조건의 팝스 기준표를 조회합니다.

**매개변수**:
- `params`: 조회 조건 (학교급, 학년, 성별, 체력요인, 종목명)

**반환**: 성공 시 `PapsStandard` 또는 null, 실패 시 `Failure`

### SavePapsRecord

팝스 측정 기록을 저장하는 유스케이스입니다.

```dart
Future<Either<Failure, PapsRecord>> call(PapsRecordParams params)
```

**설명**: Repository를 통해 팝스 측정 기록을 Firestore에 저장합니다.

**매개변수**:
- `params`: 저장할 측정 기록 데이터

**반환**: 성공 시 저장된 `PapsRecord`, 실패 시 `Failure`

### GetStudentPapsRecords

학생의 팝스 측정 기록 목록을 조회하는 유스케이스입니다.

```dart
Future<Either<Failure, List<PapsRecord>>> call(StudentIdParams params)
```

**설명**: Repository를 통해 특정 학생의 모든 팝스 측정 기록을 조회합니다.

**매개변수**:
- `params`: 학생 ID

**반환**: 성공 시 `PapsRecord` 목록, 실패 시 `Failure`

## 프레젠테이션 레이어 (Presentation Layer)

### PapsCubit

팝스 관련 상태 관리 Cubit입니다.

#### 주요 메서드

##### `loadPapsStandard()`

```dart
Future<void> loadPapsStandard({
  required SchoolLevel schoolLevel,
  required int gradeNumber,
  required Gender gender, 
  required FitnessFactor fitnessFactor,
  required String eventName,
})
```

**설명**: 특정 조건의 팝스 기준표를 로드하고 상태를 업데이트합니다.

##### `calculateGradeAndScore()`

```dart
Future<void> calculateGradeAndScore({
  required SchoolLevel schoolLevel,
  required int gradeNumber,
  required Gender gender, 
  required FitnessFactor fitnessFactor,
  required String eventName,
  required double value,
})
```

**설명**: 측정값에 대한 등급 및 점수를 계산하고 상태를 업데이트합니다.

##### `savePapsRecord()`

```dart
Future<void> savePapsRecord(PapsRecord record)
```

**설명**: 팝스 측정 기록을 저장하고 상태를 업데이트합니다.

##### `getStudentRecords()`

```dart
Future<void> getStudentRecords(String studentId)
```

**설명**: 학생의 팝스 측정 기록 목록을 조회하고 상태를 업데이트합니다.
