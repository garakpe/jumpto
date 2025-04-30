/// 체력요인 (심폐지구력, 유연성, 근력근지구력, 순발력, 비만)
enum FitnessFactor {
  cardioEndurance('심폐지구력'),
  flexibility('유연성'),
  muscularStrength('근력근지구력'),
  power('순발력'),
  bmi('비만');
  
  final String koreanName;
  
  const FitnessFactor(this.koreanName);
  
  static FitnessFactor fromKoreanName(String name) {
    return FitnessFactor.values.firstWhere(
      (factor) => factor.koreanName == name,
      orElse: () => throw ArgumentError('유효하지 않은 체력요인입니다: $name'),
    );
  }
  
  @override
  String toString() => koreanName;
}
