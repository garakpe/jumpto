import 'dart:convert';
import 'dart:developer' as developer;

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
    
    developer.log('JSON 데이터 파싱 시작: ${jsonData.keys.toList()}');
    
    // 학교급별 순회
    jsonData.forEach((schoolLevelKey, schoolLevelData) {
      try {
        developer.log('학교급 처리: $schoolLevelKey');
        final schoolLevel = SchoolLevel.fromKoreanName(schoolLevelKey);
        
        // 성별별 순회
        if (schoolLevelData is! Map) {
          developer.log('성별 데이터 형식 오류: $schoolLevelData');
          return;
        }
        
        (schoolLevelData as Map).forEach((genderKey, genderData) {
          try {
            developer.log('성별 처리: $genderKey');
            final gender = Gender.fromKoreanName(genderKey);
            
            // 학년별 순회
            if (genderData is! Map) {
              developer.log('학년 데이터 형식 오류: $genderData');
              return;
            }
            
            (genderData as Map).forEach((gradeKey, gradeData) {
              try {
                developer.log('학년 처리: $gradeKey');
                final grade = Grade.fromString(schoolLevel, gradeKey);
                
                // 체력요인별 순회
                if (gradeData is! Map) {
                  developer.log('체력요인 데이터 형식 오류: $gradeData');
                  return;
                }
                
                (gradeData as Map).forEach((fitnessFactorKey, fitnessFactorData) {
                  try {
                    developer.log('체력요인 처리: $fitnessFactorKey');
                    final fitnessFactor = FitnessFactor.fromKoreanName(fitnessFactorKey);
                    
                    // 평가종목별 순회
                    if (fitnessFactorData is! Map) {
                      developer.log('평가종목 데이터 형식 오류: $fitnessFactorData');
                      return;
                    }
                    
                    (fitnessFactorData as Map).forEach((eventKey, eventData) {
                      try {
                        developer.log('평가종목 처리: $eventKey');
                        Event? event;
                        try {
                          event = Event.findByName(eventKey);
                        } catch (e) {
                          developer.log('평가종목 매핑 실패: $eventKey - $e', error: e);
                          // 찾을 수 없는 경우 해당 체력요인에 대한 첫 번째 이벤트 사용
                          final availableEvents = Event.findByFitnessFactor(fitnessFactor);
                          if (availableEvents.isNotEmpty) {
                            event = availableEvents.first;
                            developer.log('대체 평가종목 사용: ${event.koreanName}');
                          } else {
                            return;
                          }
                        }
                        
                        // 등급 범위 목록 파싱
                        if (eventData is! List) {
                          developer.log('등급 범위 데이터 형식 오류: $eventData');
                          return;
                        }
                        
                        final List<dynamic> gradeRangesJson = eventData;
                        final List<GradeRange> gradeRanges = [];
                        
                        for (var rangeJson in gradeRangesJson) {
                          try {
                            final grade = rangeJson['등급'];
                            final score = rangeJson['점수'];
                            final start = (rangeJson['시작'] as num).toDouble();
                            final end = (rangeJson['종료'] as num).toDouble();
                            
                            gradeRanges.add(GradeRange(
                              grade: grade,
                              score: score,
                              start: start,
                              end: end,
                            ));
                          } catch (e) {
                            developer.log('등급 범위 파싱 오류: $rangeJson - $e', error: e);
                          }
                        }
                        
                        if (gradeRanges.isEmpty) {
                          developer.log('등급 범위가 비어있음: $eventKey');
                          return;
                        }
                        
                        // PapsStandard 객체 생성 및 추가
                        final standard = PapsStandard(
                          schoolLevel: schoolLevel,
                          gender: gender,
                          grade: grade,
                          fitnessFactor: fitnessFactor,
                          event: event,
                          gradeRanges: gradeRanges,
                        );
                        
                        allStandards.add(standard);
                        developer.log('기준 추가됨: ${standard.schoolLevel.koreanName} ${standard.grade.koreanName} ${standard.gender.koreanName} ${standard.fitnessFactor.koreanName} ${standard.event.koreanName}');
                        
                      } catch (e) {
                        developer.log('평가종목 처리 중 오류: $eventKey - $e', error: e);
                      }
                    });
                  } catch (e) {
                    developer.log('체력요인 처리 중 오류: $fitnessFactorKey - $e', error: e);
                  }
                });
              } catch (e) {
                developer.log('학년 처리 중 오류: $gradeKey - $e', error: e);
              }
            });
          } catch (e) {
            developer.log('성별 처리 중 오류: $genderKey - $e', error: e);
          }
        });
      } catch (e) {
        developer.log('학교급 처리 중 오류: $schoolLevelKey - $e', error: e);
      }
    });
    
    developer.log('팝스 기준표 파싱 완료: ${allStandards.length}개 기준');
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
      developer.log('기준표 검색: ${schoolLevel.koreanName} $gradeNumber학년 ${gender.koreanName} ${fitnessFactor.koreanName} $eventName');
      developer.log('검색 가능한 기준표: ${standards.length}개');
      
      // 정확히 일치하는 항목 검색
      try {
        final exactMatch = standards.firstWhere(
          (standard) => 
            standard.schoolLevel == schoolLevel &&
            standard.grade.gradeNumber == gradeNumber &&
            standard.gender == gender &&
            standard.fitnessFactor == fitnessFactor &&
            standard.event.koreanName == eventName
        );
        developer.log('정확히 일치하는 기준표 찾음');
        return exactMatch;
      } catch (e) {
        developer.log('정확히 일치하는 기준표 없음: $e');
      }
      
      // 종목명만 일부 다를 경우 체력요인으로 검색
      try {
        final factorMatch = standards.firstWhere(
          (standard) => 
            standard.schoolLevel == schoolLevel &&
            standard.grade.gradeNumber == gradeNumber &&
            standard.gender == gender &&
            standard.fitnessFactor == fitnessFactor
        );
        developer.log('체력요인으로 일치하는 기준표 찾음: ${factorMatch.event.koreanName}');
        return factorMatch;
      } catch (e) {
        developer.log('체력요인으로 일치하는 기준표 없음: $e');
      }
      
      // 일치하는 항목이 없는 경우
      developer.log('일치하는 기준표를 찾을 수 없음');
      return null;
    } catch (e) {
      developer.log('기준표 검색 중 오류 발생: $e', error: e);
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
