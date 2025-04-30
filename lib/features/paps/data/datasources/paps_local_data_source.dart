import 'dart:convert';

import 'package:flutter/services.dart';

import '../../domain/entities/index.dart';

/// 팝스 관련 로컬 데이터 소스
/// 
/// 팝스 기준표를 자산에서 로드하는 역할을 담당합니다.
abstract class PapsLocalDataSource {
  /// 팝스 기준표 데이터를 자산에서 로드
  Future<PapsStandardsCollection> getPapsStandards();
}

/// 팝스 로컬 데이터 소스 구현체
class PapsLocalDataSourceImpl implements PapsLocalDataSource {
  static const String _assetsPath = 'assets/data/paps_standards.json';
  
  @override
  Future<PapsStandardsCollection> getPapsStandards() async {
    try {
      // 자산에서 JSON 파일 로드
      final jsonString = await rootBundle.loadString(_assetsPath);
      
      // JSON을 PapsStandardsCollection으로 변환
      return PapsStandardsCollection.fromJsonString(jsonString);
    } catch (e) {
      throw Exception('팝스 기준표를 로드할 수 없습니다: $e');
    }
  }
}
