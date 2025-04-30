import 'school_level.dart';

/// 학년 클래스
/// 
/// 각 학교급별 학년을 표현합니다. (초3~초6, 중1~중3, 고1~고3)
class Grade {
  final SchoolLevel schoolLevel;
  final int gradeNumber;
  final String koreanName;
  
  const Grade(this.schoolLevel, this.gradeNumber)
    : koreanName = '$gradeNumber학년';
  
  /// 학년 문자열로부터 Grade 객체 생성 (예: "3학년", "5학년")
  static Grade fromString(SchoolLevel schoolLevel, String gradeStr) {
    final regex = RegExp(r'(\d+)학년');
    final match = regex.firstMatch(gradeStr);
    
    if (match != null) {
      final gradeNumber = int.parse(match.group(1)!);
      return Grade(schoolLevel, gradeNumber);
    }
    
    throw ArgumentError('유효하지 않은 학년 형식입니다: $gradeStr');
  }
  
  @override
  String toString() => '$schoolLevel $koreanName';
  
  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    (other is Grade &&
     schoolLevel == other.schoolLevel &&
     gradeNumber == other.gradeNumber);
  
  @override
  int get hashCode => schoolLevel.hashCode ^ gradeNumber.hashCode;
}
