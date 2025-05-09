/// 학교 엔티티
///
/// 학교 정보를 표현하는 클래스입니다.
class School {
  /// 학교 코드
  final String code;
  
  /// 학교명
  final String name;
  
  /// 설립년도
  final String establishmentYear;
  
  /// 남녀공학 구분 (남, 여, 남여공학)
  final String genderType;
  
  /// 주야구분 (주간, 야간, 주야간)
  final String dayNightType;
  
  /// 지역명 (서울특별시, 경기도 등)
  final String region;
  
  /// 학교 종류 (초등학교, 중학교, 고등학교 등)
  final String schoolType;
  
  /// 설립 구분 (국립, 공립, 사립 등)
  final String foundationType;
  
  /// 생성자
  School({
    required this.code,
    required this.name,
    required this.establishmentYear,
    required this.genderType,
    required this.dayNightType,
    required this.region,
    required this.schoolType,
    required this.foundationType,
  });
  
  @override
  String toString() {
    return '$name ($schoolType, $region)';
  }
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is School && code == other.code;
  
  @override
  int get hashCode => code.hashCode;
}
