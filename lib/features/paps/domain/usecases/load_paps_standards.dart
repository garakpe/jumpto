import 'dart:convert';

import 'package:flutter/services.dart';

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
    
    // assets에서 팝스 기준표 JSON 파일 로드
    final jsonString = await rootBundle.loadString('assets/data/paps_standards.json');
    _standardsCollection = PapsStandardsCollection.fromJsonString(jsonString);
    
    return _standardsCollection!;
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
