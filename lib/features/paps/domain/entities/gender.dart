/// 성별 (남자, 여자)
enum Gender {
  male('남자'),
  female('여자');
  
  final String koreanName;
  
  const Gender(this.koreanName);
  
  static Gender fromKoreanName(String name) {
    return Gender.values.firstWhere(
      (gender) => gender.koreanName == name,
      orElse: () => throw ArgumentError('유효하지 않은 성별입니다: $name'),
    );
  }
  
  @override
  String toString() => koreanName;
}
