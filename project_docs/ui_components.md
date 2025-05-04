# UI 컴포넌트 문서

이 문서는 온라인 팝스(PAPS) 교육 플랫폼에서 사용되는 주요 UI 컴포넌트들과 그 사용법을 설명합니다.

## 공통 컴포넌트

### AppButton

표준화된 버튼 위젯입니다.

**위치**: `/lib/core/presentation/widgets/app_button.dart`

**주요 특징**:
- 일관된 스타일의 Material 버튼
- 텍스트와 아이콘 동시 사용 가능
- 로딩 상태 표시 기능

**사용 예시**:
```dart
AppButton(
  text: '계산하기',
  onPressed: () => calculateGrade(),
  icon: Icons.calculate,
  isLoading: state is CalculatingState,
)
```

### AppTextField

표준화된 텍스트 입력 위젯입니다.

**위치**: `/lib/core/presentation/widgets/app_text_field.dart`

**주요 특징**:
- 일관된 스타일의 Material 텍스트 필드
- 라벨, 힌트 텍스트, 오류 메시지 지원
- 접두/접미 아이콘 및 다양한 입력 타입 지원

**사용 예시**:
```dart
AppTextField(
  label: '측정값',
  hintText: '숫자만 입력하세요',
  controller: valueController,
  keyboardType: TextInputType.number,
  validator: (value) => value!.isEmpty ? '값을 입력해주세요' : null,
)
```

### LoadingView

로딩 상태를 표시하는 위젯입니다.

**위치**: `/lib/core/presentation/widgets/loading_view.dart`

**주요 특징**:
- 화면 중앙에 로딩 인디케이터 표시
- 전체 화면을 덮는 오버레이 제공

**사용 예시**:
```dart
if (state is LoadingState) {
  return const LoadingView();
}
```

### ErrorView

오류 상태를 표시하는 위젯입니다.

**위치**: `/lib/core/presentation/widgets/error_view.dart`

**주요 특징**:
- 오류 메시지와 재시도 버튼 제공
- 사용자 친화적인 오류 표시

**사용 예시**:
```dart
if (state is ErrorState) {
  return ErrorView(
    message: state.message,
    onRetry: () => context.read<MyCubit>().loadData(),
  );
}
```

## 팝스 관련 컴포넌트

### MeasurementResultCard

팝스 측정 결과를 표시하는 카드 위젯입니다.

**위치**: `/lib/features/paps/presentation/widgets/measurement_result_card.dart`

**주요 특징**:
- 측정 등급과 점수를 시각적으로 표시
- 등급에 따른 색상 변화
- 저장 버튼 제공

**사용 예시**:
```dart
MeasurementResultCard(
  grade: 3,
  score: 14,
  onSave: () => saveMeasurementRecord(),
)
```

### GradeRangeTable

팝스 기준표 범위를 표 형태로 보여주는 위젯입니다.

**위치**: `/lib/features/paps/presentation/widgets/grade_range_table.dart`

**주요 특징**:
- 등급별 범위값 및 점수를 표로 표시
- 등급에 따른 스타일 차별화
- 현재 선택된 종목 및 학년, 성별에 맞는 기준 표시

**사용 예시**:
```dart
GradeRangeTable(
  standard: papsStandard,
  highlightGrade: selectedGrade,
)
```

### MenuCard

메뉴 항목을 카드 형태로 보여주는 위젯입니다.

**위치**: `/lib/features/common/presentation/widgets/menu_card.dart`

**주요 특징**:
- 아이콘, 제목, 설명을 포함한 메뉴 카드
- 터치 시 화면 이동 기능
- 메뉴 항목의 중요도에 따른 스타일 변화

**사용 예시**:
```dart
MenuCard(
  icon: Icons.fitness_center,
  title: '팝스 측정',
  description: '체력 요소별 측정 결과를 기록해보세요',
  onTap: () => context.push('/paps/measurement'),
)
```

## 팝스 관련 화면

### PapsStandardsPage

팝스 기준표를 조회하는 화면입니다.

**위치**: `/lib/features/paps/presentation/pages/paps_standards_page.dart`

**주요 기능**:
- 학교급, 학년, 성별, 체력요인, 종목 선택 필터 제공
- 선택된 조건에 맞는 팝스 기준표 표시
- 응답형 디자인으로 다양한 화면 크기 지원

### PapsMeasurementPage

팝스 측정값을 입력하고 등급과 점수를 확인하는 화면입니다.

**위치**: `/lib/features/paps/presentation/pages/paps_measurement_page.dart`

**주요 기능**:
- 필터 섹션: 학교급, 학년, 성별, 체력요인, 종목 선택
- 측정값 입력 섹션: 선택된 종목에 맞는 힌트와 키보드 타입 제공
- 결과 섹션: 등급과 점수 표시 및 저장 기능

**웹 환경 최적화**:
- localStorage를 활용한 데이터 캐싱
- 다양한 경로로 에셋 로드 시도
- 폴백 데이터 제공 메커니즘
