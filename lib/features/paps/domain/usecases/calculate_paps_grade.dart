import '../entities/index.dart';
import 'load_paps_standards.dart';

/// 팝스 측정값의 등급 및 점수 계산 유스케이스
class CalculatePapsGrade {
  final LoadPapsStandards _loadPapsStandards;

  /// 생성자
  CalculatePapsGrade(this._loadPapsStandards);

  /// 측정값 등급 및 점수 계산
  ///
  /// [schoolLevel] 학교급 (초/중/고)
  /// [gradeNumber] 학년 (1~6)
  /// [gender] 성별 (남/여)
  /// [fitnessFactor] 체력요인 
  /// [eventName] 평가종목 이름
  /// [value] 측정값
  ///
  /// 반환값: {grade: 등급값, score: 점수} 형태의 Map
  Future<Map<String, dynamic>?> calculate({
    required SchoolLevel schoolLevel,
    required int gradeNumber,
    required Gender gender,
    required FitnessFactor fitnessFactor,
    required String eventName,
    required double value,
  }) async {
    return await _loadPapsStandards.calculateGradeAndScore(
      schoolLevel: schoolLevel,
      gradeNumber: gradeNumber,
      gender: gender,
      fitnessFactor: fitnessFactor,
      eventName: eventName,
      value: value,
    );
  }
  
  /// 학생 기록 리스트의 총점 계산
  /// 
  /// [records] 학생의 팝스 측정 기록 리스트
  /// 
  /// 반환값: 총 점수 (0~100점)
  int calculateTotalScore(List<PapsRecord> records) {
    // 중복 체력 요인을 제거하고 최대 5개 요소만 사용
    final uniqueFactorRecords = <FitnessFactor, PapsRecord>{};
    
    // 각 체력요인별로 최신/최고 점수의 기록을 저장
    for (final record in records) {
      final factor = record.fitnessFactor;
      
      if (!uniqueFactorRecords.containsKey(factor) || 
          uniqueFactorRecords[factor]!.score < record.score) {
        uniqueFactorRecords[factor] = record;
      }
    }
    
    // 총점 계산
    return uniqueFactorRecords.values.fold(0, (sum, record) => sum + record.score);
  }
  
  /// 종합 등급 계산
  /// 
  /// [totalScore] 총점 (0~100점)
  /// 
  /// 반환값: 종합 등급 (1~5)
  int calculateOverallGrade(int totalScore) {
    if (totalScore >= 80) {
      return 1;
    } else if (totalScore >= 60) {
      return 2;
    } else if (totalScore >= 40) {
      return 3;
    } else if (totalScore >= 20) {
      return 4;
    } else {
      return 5;
    }
  }
}
