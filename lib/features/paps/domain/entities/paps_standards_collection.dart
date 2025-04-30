import 'dart:convert';

import 'event.dart';
import 'fitness_factor.dart';
import 'gender.dart';
import 'grade.dart';
import 'grade_range.dart';
import 'school_level.dart';
import 'paps_standard.dart';

/// 팝스 기준표 컬렉션
///
/// 모든 팝스 측정 기준 데이터를 관리하는 컬렉션 클래스입니다.
/// JSON 데이터를 파싱하고 필터링하는 기능을 제공합니다.
class PapsStandardsCollection {
  /// 모든 팝스 기준 데이터
  final List<PapsStandard> standards;
  
  /// 생성자
  PapsStandardsCollection(this.standards);
  
  /// JSON 문자열에서 PapsStandardsCollection 생성
  factory PapsStandardsCollection.fromJsonString(String jsonString) {
    final List<PapsStandard> allStandards = [];
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    
    // 학교급별 순회
    jsonData.forEach((schoolLevelKey, schoolLevelData) {
      final schoolLevel = SchoolLevel.fromKoreanName(schoolLevelKey);
      
      // 성별별 순회
      schoolLevelData.forEach((genderKey, genderData) {
        final gender = Gender.fromKoreanName(genderKey);
        
        // 학년별 순회
        genderData.forEach((gradeKey, gradeData) {
          final grade = Grade.fromString(schoolLevel, gradeKey);
          
          // 체력요인별 순회
          gradeData.forEach((fitnessFactorKey, fitnessFactorData) {
            final fitnessFactor = FitnessFactor.fromKoreanName(fitnessFactorKey);
            
            // 평가종목별 순회
            fitnessFactorData.forEach((eventKey, eventData) {
              final event = Event.findByName(eventKey);
              
              // 등급 범위 목록 파싱
              final List<dynamic> gradeRangesJson = eventData;
              final List<GradeRange> gradeRanges = [];
              
              for (var rangeJson in gradeRangesJson) {
                gradeRanges.add(GradeRange(
                  grade: rangeJson['등급'],
                  score: rangeJson['점수'],
                  start: (rangeJson['시작'] as num).toDouble(),
                  end: (rangeJson['종료'] as num).toDouble(),
                ));
              }
              
              // PapsStandard 객체 생성 및 추가
              allStandards.add(PapsStandard(
                schoolLevel: schoolLevel,
                gender: gender,
                grade: grade,
                fitnessFactor: fitnessFactor,
                event: event,
                gradeRanges: gradeRanges,
              ));
            });
          });
        });
      });
    });
    
    return PapsStandardsCollection(allStandards);
  }
  
  /// 학교급, 학년, 성별, 체력요인, 평가종목으로 해당하는 기준표 찾기
  PapsStandard? findStandard({
    required SchoolLevel schoolLevel,
    required int gradeNumber,
    required Gender gender,
    required FitnessFactor fitnessFactor,
    required String eventName,
  }) {
    try {
      return standards.firstWhere(
        (standard) => 
          standard.schoolLevel == schoolLevel &&
          standard.grade.gradeNumber == gradeNumber &&
          standard.gender == gender &&
          standard.fitnessFactor == fitnessFactor &&
          standard.event.koreanName == eventName
      );
    } catch (e) {
      // 해당 조건의 기준이 없는 경우
      return null;
    }
  }
  
  /// 측정값에 해당하는 등급과 점수 계산
  Map<String, dynamic>? calculateGradeAndScore({
    required SchoolLevel schoolLevel,
    required int gradeNumber,
    required Gender gender,
    required FitnessFactor fitnessFactor,
    required String eventName,
    required double value,
  }) {
    final standard = findStandard(
      schoolLevel: schoolLevel,
      gradeNumber: gradeNumber,
      gender: gender,
      fitnessFactor: fitnessFactor,
      eventName: eventName,
    );
    
    if (standard != null) {
      return standard.calculateGradeAndScore(value);
    }
    
    return null;
  }
  
  /// 특정 조건에 맞는 기준표 필터링
  List<PapsStandard> filter({
    SchoolLevel? schoolLevel,
    int? gradeNumber,
    Gender? gender,
    FitnessFactor? fitnessFactor,
    String? eventName,
  }) {
    return standards.where((standard) {
      bool match = true;
      
      if (schoolLevel != null) {
        match = match && standard.schoolLevel == schoolLevel;
      }
      
      if (gradeNumber != null) {
        match = match && standard.grade.gradeNumber == gradeNumber;
      }
      
      if (gender != null) {
        match = match && standard.gender == gender;
      }
      
      if (fitnessFactor != null) {
        match = match && standard.fitnessFactor == fitnessFactor;
      }
      
      if (eventName != null) {
        match = match && standard.event.koreanName == eventName;
      }
      
      return match;
    }).toList();
  }
}
