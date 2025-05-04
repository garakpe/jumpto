import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:universal_html/html.dart' as html;

import '../entities/index.dart';

/// 팝스 기준표를 로드하는 유스케이스
class LoadPapsStandards {
  /// 팝스 기준표 컬렉션
  PapsStandardsCollection? _standardsCollection;

  /// 팝스 기준표 컬렉션 가져오기 (싱글톤 패턴)
  Future<PapsStandardsCollection> getStandardsCollection() async {
    if (_standardsCollection != null) {
      return _standardsCollection!;
    }
    
    String jsonString;
    
    // 웹 환경에서는 localStorage에서 먼저 시도
    if (kIsWeb) {
      try {
        // localStorage에서 캐싱된 데이터 확인
        final cachedData = html.window.localStorage['paps_standards_cache'];
        if (cachedData != null && cachedData.isNotEmpty) {
          print('localStorage에서 팝스 기준표 데이터를 로드했습니다.');
          jsonString = cachedData;
          _standardsCollection = PapsStandardsCollection.fromJsonString(jsonString);
          return _standardsCollection!;
        }
      } catch (e) {
        print('localStorage에서 데이터 로드 실패: $e');
      }
      
      // 로컬스토리지에 없으면 다양한 경로 시도
      try {
        jsonString = await rootBundle.loadString('assets/data/paps_standards.json');
      } catch (e) {
        print('첫 번째 경로에서 로드 실패: $e');
        try {
          jsonString = await rootBundle.loadString('assets/assets/data/paps_standards.json');
        } catch (e) {
          print('두 번째 경로에서 로드 실패: $e');
          try {
            jsonString = await rootBundle.loadString('/assets/data/paps_standards.json');
          } catch (e) {
            print('세 번째 경로에서 로드 실패: $e');
            // 폴백 데이터 - 기본 데이터 제공
            print('폴백 데이터를 사용합니다.');
            jsonString = _getFallbackPapsStandardsJson();
          }
        }
      }
    } else {
      // 모바일/데스크톱 환경
      jsonString = await rootBundle.loadString('assets/data/paps_standards.json');
    }
    
    _standardsCollection = PapsStandardsCollection.fromJsonString(jsonString);
    
    // 웹에서 캐싱
    if (kIsWeb) {
      try {
        html.window.localStorage['paps_standards_cache'] = jsonString;
        print('팝스 기준표 데이터를 localStorage에 캐싱했습니다.');
      } catch (e) {
        print('localStorage 캐싱 실패: $e');
      }
    }
    
    return _standardsCollection!;
  }
  
  /// 폴백 데이터 - 파일 로드 실패 시 사용
  String _getFallbackPapsStandardsJson() {
    // 가장 기본적인 데이터만 포함한 간소화된 JSON 반환
    return '''{
      "standards": [
        {
          "schoolLevel": "elementary",
          "gradeNumber": 5,
          "gender": "male",
          "fitnessFactor": "cardioEndurance",
          "eventName": "왕복오래달리기",
          "gradeRanges": [
            {"grade": 1, "min": 61, "max": 999, "score": 20},
            {"grade": 2, "min": 51, "max": 60, "score": 17},
            {"grade": 3, "min": 41, "max": 50, "score": 14},
            {"grade": 4, "min": 31, "max": 40, "score": 11},
            {"grade": 5, "min": 0, "max": 30, "score": 8}
          ],
          "desc": "초등학교 5학년 남자 심폐지구력 왕복오래달리기"
        }
      ]
    }''';
  }
  
  /// 측정값의 등급과 점수 계산하기
  Future<Map<String, dynamic>?> calculateGradeAndScore({
    required SchoolLevel schoolLevel,
    required int gradeNumber,
    required Gender gender,
    required FitnessFactor fitnessFactor,
    required String eventName,
    required double value,
  }) async {
    final standards = await getStandardsCollection();
    
    return standards.calculateGradeAndScore(
      schoolLevel: schoolLevel,
      gradeNumber: gradeNumber,
      gender: gender,
      fitnessFactor: fitnessFactor,
      eventName: eventName,
      value: value,
    );
  }
  
  /// 특정 조건의 기준표 찾기
  Future<PapsStandard?> findStandard({
    required SchoolLevel schoolLevel,
    required int gradeNumber,
    required Gender gender,
    required FitnessFactor fitnessFactor,
    required String eventName,
  }) async {
    final standards = await getStandardsCollection();
    
    return standards.findStandard(
      schoolLevel: schoolLevel,
      gradeNumber: gradeNumber,
      gender: gender,
      fitnessFactor: fitnessFactor,
      eventName: eventName,
    );
  }
  
  /// 특정 조건에 맞는 기준표 목록 필터링
  Future<List<PapsStandard>> filterStandards({
    SchoolLevel? schoolLevel,
    int? gradeNumber,
    Gender? gender,
    FitnessFactor? fitnessFactor,
    String? eventName,
  }) async {
    final standards = await getStandardsCollection();
    
    return standards.filter(
      schoolLevel: schoolLevel,
      gradeNumber: gradeNumber,
      gender: gender,
      fitnessFactor: fitnessFactor,
      eventName: eventName,
    );
  }
}
