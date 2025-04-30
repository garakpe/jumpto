import 'package:flutter/foundation.dart';

import 'event.dart';
import 'fitness_factor.dart';
import 'gender.dart';
import 'grade.dart';
import 'grade_range.dart';
import 'school_level.dart';

/// 팝스 기준표 엔티티
///
/// 팝스(PAPS) 측정 기준을 정의하는 클래스입니다.
/// 학교급(초/중/고), 성별, 학년, 체력요인, 평가종목, 등급 범위 등의 정보를 포함합니다.
class PapsStandard {
  /// 학교급
  final SchoolLevel schoolLevel;
  
  /// 성별
  final Gender gender;
  
  /// 학년
  final Grade grade;
  
  /// 체력요인
  final FitnessFactor fitnessFactor;
  
  /// 평가종목
  final Event event;
  
  /// 등급 범위 목록
  final List<GradeRange> gradeRanges;

  /// 생성자
  PapsStandard({
    required this.schoolLevel,
    required this.gender,
    required this.grade,
    required this.fitnessFactor,
    required this.event,
    required this.gradeRanges,
  });

  /// JSON으로부터 PapsStandard 객체 생성
  factory PapsStandard.fromJson(Map<String, dynamic> json) {
    final schoolLevelString = json.keys.first;
    final schoolLevel = SchoolLevel.fromKoreanName(schoolLevelString);
    
    final genderData = json[schoolLevelString];
    final genderString = genderData.keys.first;
    final gender = Gender.fromKoreanName(genderString);
    
    final gradeData = genderData[genderString];
    final gradeString = gradeData.keys.first;
    final grade = Grade.fromString(schoolLevel, gradeString);
    
    final fitnessFactorData = gradeData[gradeString];
    final fitnessFactorString = fitnessFactorData.keys.first;
    final fitnessFactor = FitnessFactor.fromKoreanName(fitnessFactorString);
    
    final eventData = fitnessFactorData[fitnessFactorString];
    final eventString = eventData.keys.first;
    final event = Event.findByName(eventString);
    
    final List<GradeRange> gradeRanges = (eventData[eventString] as List)
      .map((range) => GradeRange.fromJson(range))
      .toList();
    
    return PapsStandard(
      schoolLevel: schoolLevel,
      gender: gender,
      grade: grade,
      fitnessFactor: fitnessFactor,
      event: event,
      gradeRanges: gradeRanges,
    );
  }

  /// 측정값에 해당하는 등급과 점수 계산하기
  Map<String, dynamic> calculateGradeAndScore(double value) {
    for (var range in gradeRanges) {
      if (range.containsValue(value)) {
        return {
          'grade': range.grade,
          'score': range.score,
        };
      }
    }
    
    // 해당하는 등급을 찾지 못한 경우 기본값 반환
    return {
      'grade': 5,
      'score': 0,
    };
  }
  
  @override
  String toString() {
    return 'PapsStandard(schoolLevel: $schoolLevel, gender: $gender, grade: $grade, ' +
           'fitnessFactor: $fitnessFactor, event: $event, gradeRanges: $gradeRanges)';
  }
  
  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    (other is PapsStandard &&
     schoolLevel == other.schoolLevel &&
     gender == other.gender &&
     grade == other.grade &&
     fitnessFactor == other.fitnessFactor &&
     event == other.event &&
     listEquals(gradeRanges, other.gradeRanges));
  
  @override
  int get hashCode =>
    schoolLevel.hashCode ^
    gender.hashCode ^
    grade.hashCode ^
    fitnessFactor.hashCode ^
    event.hashCode ^
    gradeRanges.hashCode;
}
