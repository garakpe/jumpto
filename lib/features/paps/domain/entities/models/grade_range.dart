/// 등급 범위 클래스
/// 
/// 팝스 기준표의 각 등급별 범위를 정의합니다.
/// 등급(1~5 또는 비만관련 문자열), 점수(0~20), 시작값, 종료값을 포함합니다.
class GradeRange {
  /// 등급 (1~5등급 또는 '고도비만', '마름' 등 문자열)
  final dynamic grade;
  
  /// 점수 (0~20)
  final int score;
  
  /// 측정값 시작 범위
  final double start;
  
  /// 측정값 종료 범위
  final double end;
  
  /// 생성자
  const GradeRange({
    required this.grade,
    required this.score,
    required this.start,
    required this.end,
  });
  
  /// JSON으로부터 GradeRange 객체 생성
  factory GradeRange.fromJson(Map<String, dynamic> json) {
    var gradeValue = json['등급'];
    // 숫자형 등급(1~5)인 경우 int로 변환
    if (gradeValue is String && int.tryParse(gradeValue) != null) {
      gradeValue = int.parse(gradeValue);
    }
    
    return GradeRange(
      grade: gradeValue,
      score: json['점수'],
      start: json['시작'].toDouble(),
      end: json['종료'].toDouble(),
    );
  }
  
  /// GradeRange 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      '등급': grade,
      '점수': score,
      '시작': start,
      '종료': end,
    };
  }
  
  /// 특정 측정값이 이 등급 범위에 속하는지 확인
  bool containsValue(double value) {
    return value >= start && value <= end;
  }
  
  @override
  String toString() {
    return 'GradeRange(grade: $grade, score: $score, start: $start, end: $end)';
  }
  
  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    (other is GradeRange &&
     grade == other.grade &&
     score == other.score &&
     start == other.start &&
     end == other.end);
  
  @override
  int get hashCode => 
    grade.hashCode ^ 
    score.hashCode ^ 
    start.hashCode ^ 
    end.hashCode;
}
