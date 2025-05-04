# 테스트 전략

이 문서는 온라인 팝스(PAPS) 교육 플랫폼의 테스트 전략과 방법론을 설명합니다.

## 테스트 계층

클린 아키텍처 기반으로 다음과 같은 테스트 계층을 구현합니다:

### 1. 단위 테스트 (Unit Tests)

개별 클래스와 함수의 동작을 검증합니다.

**테스트 대상**:
- 도메인 엔티티 (Entity)
- 유스케이스 (UseCase)
- 레포지토리 구현체 (Repository Implementation)
- 데이터 소스 (DataSource)
- 큐빗/블록 (Cubit/BLoC)

**주요 도구**:
- `flutter_test` 패키지
- `mockito` 또는 `mocktail`을 사용한 모킹
- `bloc_test`를 사용한 상태 관리 테스트

**예시**:
```dart
void main() {
  group('CalculatePapsGrade', () {
    late LoadPapsStandards mockLoadPapsStandards;
    late CalculatePapsGrade useCase;
    
    setUp(() {
      mockLoadPapsStandards = MockLoadPapsStandards();
      useCase = CalculatePapsGrade(mockLoadPapsStandards);
    });
    
    test('should return grade and score for valid input', () async {
      // given
      const expectedResult = {'grade': 3, 'score': 14};
      when(mockLoadPapsStandards.calculateGradeAndScore(
        schoolLevel: SchoolLevel.elementary,
        gradeNumber: 5,
        gender: Gender.male,
        fitnessFactor: FitnessFactor.cardioEndurance,
        eventName: '왕복오래달리기',
        value: 45.0,
      )).thenAnswer((_) async => expectedResult);
      
      // when
      final result = await useCase.calculate(
        schoolLevel: SchoolLevel.elementary,
        gradeNumber: 5,
        gender: Gender.male,
        fitnessFactor: FitnessFactor.cardioEndurance,
        eventName: '왕복오래달리기',
        value: 45.0,
      );
      
      // then
      expect(result, expectedResult);
    });
  });
}
```

### 2. 통합 테스트 (Integration Tests)

여러 컴포넌트 간의 상호작용을 검증합니다.

**테스트 대상**:
- 유스케이스와 레포지토리 간 상호작용
- 레포지토리와 데이터 소스 간 상호작용
- 프레젠테이션과 도메인 계층 간 상호작용

**주요 도구**:
- `integration_test` 패키지
- `flutter_test` 패키지

### 3. 위젯 테스트 (Widget Tests)

UI 컴포넌트의 렌더링과 상호작용을 검증합니다.

**테스트 대상**:
- 공통 위젯 (AppButton, AppTextField 등)
- 화면별 위젯 (PapsStandardsPage, PapsMeasurementPage 등)

**주요 도구**:
- `flutter_test` 패키지
- `golden_toolkit`을 사용한 골든 테스트

**예시**:
```dart
void main() {
  group('MeasurementResultCard', () {
    testWidgets('should display grade and score correctly', (WidgetTester tester) async {
      // given
      const grade = 3;
      const score = 14;
      bool savePressed = false;
      
      // when
      await tester.pumpWidget(MaterialApp(
        home: MeasurementResultCard(
          grade: grade,
          score: score,
          onSave: () => savePressed = true,
        ),
      ));
      
      // then
      expect(find.text('3등급'), findsOneWidget);
      expect(find.text('14점'), findsOneWidget);
      
      await tester.tap(find.byType(ElevatedButton));
      expect(savePressed, true);
    });
  });
}
```

### 4. E2E 테스트 (End-to-End Tests)

전체 앱 흐름을 검증합니다.

**테스트 대상**:
- 로그인 → 홈 → 기능 사용 → 로그아웃 등의 전체 사용자 흐름
- 실제 Firebase 백엔드와의 상호작용

**주요 도구**:
- `integration_test` 패키지
- Firebase 에뮬레이터 스위트

## 웹 환경 테스트 전략

웹 환경에서의 테스트를 위한 추가 전략입니다.

### 1. 에셋 로드 테스트

**테스트 대상**:
- 다양한 경로를 통한 에셋 파일 로드 기능
- localStorage 캐싱 메커니즘

**테스트 방법**:
- 모의 웹 환경에서 다양한 경로 시나리오 테스트
- localStorage 모킹을 통한 캐싱 테스트

**예시**:
```dart
group('LoadPapsStandards in web environment', () {
  late LoadPapsStandards useCase;
  late MockLocalStorage mockLocalStorage;
  
  setUp(() {
    mockLocalStorage = MockLocalStorage();
    useCase = LoadPapsStandards();
    // 웹 환경 모킹 설정
  });
  
  test('should load data from localStorage when available', () async {
    // given
    when(mockLocalStorage.getItem('paps_standards_cache'))
      .thenReturn(validJsonString);
    
    // when
    final result = await useCase.getStandardsCollection();
    
    // then
    expect(result, isA<PapsStandardsCollection>());
    expect(result.standards.length, greaterThan(0));
  });
  
  test('should try multiple paths when localStorage is empty', () async {
    // 경로 시도 테스트 로직
  });
  
  test('should use fallback data when all load attempts fail', () async {
    // 폴백 데이터 사용 테스트 로직
  });
});
```

### 2. 크로스 브라우저 테스트

**테스트 대상**:
- 다양한 웹 브라우저에서의 호환성 (Chrome, Firefox, Safari, Edge)
- 반응형 디자인 및 레이아웃

**테스트 방법**:
- 로컬 브라우저 테스트
- BrowserStack 또는 유사 서비스를 통한 크로스 브라우저 테스트

### 3. 네트워크 조건 테스트

**테스트 대상**:
- 다양한 네트워크 조건에서의 앱 동작 (느린 연결, 간헐적 연결 끊김)
- 오프라인 모드 지원

**테스트 방법**:
- Chrome DevTools의 네트워크 조절 기능 활용
- 실제 네트워크 제한 환경에서의 테스트

## 테스트 자동화

지속적 통합(CI)을 위한 테스트 자동화 전략입니다.

### GitHub Actions

GitHub Actions를 사용하여 다음 작업을 자동화합니다:

1. 코드 컴파일 및 정적 분석
2. 단위 테스트 실행
3. 위젯 테스트 실행
4. 통합 테스트 실행 (일부)

**예시 워크플로우**:
```yaml
name: Flutter Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.7.0'
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test
```

## 테스트 우선순위

1. **핵심 비즈니스 로직**: 팝스 기준표 로드 및 등급/점수 계산 로직
2. **인증 관련 기능**: 로그인, 회원가입, 권한 관리
3. **데이터 관리**: 측정 기록 저장 및 조회
4. **UI 컴포넌트**: 공통 위젯 및 화면
