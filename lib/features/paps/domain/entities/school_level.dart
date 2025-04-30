/// 학교급 (초등학교, 중학교, 고등학교)
enum SchoolLevel {
  elementary('초등학교'),
  middle('중학교'),
  high('고등학교');
  
  final String koreanName;
  
  const SchoolLevel(this.koreanName);
  
  static SchoolLevel fromKoreanName(String name) {
    return SchoolLevel.values.firstWhere(
      (level) => level.koreanName == name,
      orElse: () => throw ArgumentError('유효하지 않은 학교급입니다: $name'),
    );
  }
  
  @override
  String toString() => koreanName;
}
