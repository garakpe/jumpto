import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:async';
import 'dart:typed_data';
import 'dart:html' as html;

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

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
  static const String _fallbackJsonPath = '/assets/assets/data/paps_standards.json';
  static const String _deploymentJsonPath = '/assets/data/paps_standards.json';
  
  /// HTTP 요청을 통해 파일 로드하기
  Future<String> _loadJsonFromNetwork(String url) async {
    try {
      developer.log('네트워크 경로에서 JSON 로드 시도: $url');
      final response = await NetworkAssetBundle(Uri.parse(url)).loadString(url);
      developer.log('네트워크 경로에서 JSON 로드 성공: ${response.length} bytes');
      return response;
    } catch (e) {
      developer.log('네트워크 경로에서 JSON 로드 실패: $e', error: e);
      throw Exception('네트워크 경로에서 JSON을 로드할 수 없습니다: $e');
    }
  }

  @override
  Future<PapsStandardsCollection> getPapsStandards() async {
    String jsonString = '';
    developer.log('팝스 기준표 로드 시작');
    
    // 단계적으로 여러 방법 시도
    try {
      // 방법 0: localStorage에서 캐싱된 데이터 로드 (웹 환경에서만 작동)
      if (kIsWeb) {
        try {
          developer.log('방법 0: localStorage에서 캐싱된 데이터 로드 시도');
          final cachedData = html.window.localStorage['paps_standards_cache'];
          if (cachedData != null && cachedData.isNotEmpty) {
            jsonString = cachedData;
            developer.log('방법 0 성공: ${jsonString.length} bytes');
            // 성공하면 다음 방법으로 넘어가지 않고 바로 리턴
            return _processJsonString(jsonString);
          } else {
            developer.log('방법 0 실패: localStorage에 캐싱된 데이터 없음');
          }
        } catch (e) {
          developer.log('방법 0 실패: $e', error: e);
        }
      }

      // 방법 1: 기본 에셋 번들 경로에서 로드
      try {
        developer.log('방법 1: 기본 에셋 경로에서 로드 시도');
        jsonString = await rootBundle.loadString(_assetsPath);
        developer.log('방법 1 성공: ${jsonString.length} bytes');
      } catch (e) {
        developer.log('방법 1 실패: $e', error: e);
        
        // 방법 2: 웹 배포용 경로에서 로드
        try {
          developer.log('방법 2: 웹 배포 경로에서 로드 시도');
          jsonString = await _loadJsonFromNetwork(_deploymentJsonPath);
          developer.log('방법 2 성공');
        } catch (e2) {
          developer.log('방법 2 실패: $e2', error: e2);
          
          // 방법 3: 대체 경로에서 로드
          try {
            developer.log('방법 3: 대체 경로에서 로드 시도');
            jsonString = await _loadJsonFromNetwork(_fallbackJsonPath);
            developer.log('방법 3 성공');
          } catch (e3) {
            developer.log('방법 3 실패: $e3', error: e3);
            throw Exception('모든 로드 방법이 실패했습니다');
          }
        }
      }
      
      // JSON 문자열 처리
      return _processJsonString(jsonString);
    } catch (e) {
      developer.log('팝스 기준표 로드 오류: $e', error: e);
      
      // 내장 기본 데이터 사용 - 최악의 경우를 위한 하드코딩된 최소한의 기준
      try {
        developer.log('기본 하드코딩된 데이터 사용 시도');
        final fallbackData = _getMinimalFallbackData();
        developer.log('기본 데이터 로드 성공');
        return fallbackData;
      } catch (fallbackError) {
        developer.log('기본 데이터로도 실패: $fallbackError', error: fallbackError);
        throw Exception('팝스 기준표를 로드할 수 없습니다: $e');
      }
    }
  }
  
  /// JSON 문자열 처리 및 변환
  Future<PapsStandardsCollection> _processJsonString(String jsonString) async {
    // JSON 유효성 검사
    try {
      json.decode(jsonString);
      developer.log('JSON 형식 검증 완료');
    } catch (parseError) {
      developer.log('JSON 파싱 오류: $parseError', error: parseError);
      throw Exception('JSON 형식이 올바르지 않습니다: $parseError');
    }
    
    // 성공한 데이터 저장 (웹 환경인 경우)
    if (kIsWeb) {
      try {
        html.window.localStorage['paps_standards_cache'] = jsonString;
        developer.log('localStorage에 데이터 저장 성공');
      } catch (e) {
        developer.log('localStorage 저장 실패: $e', error: e);
      }
    }
    
    // JSON을 PapsStandardsCollection으로 변환
    final collection = PapsStandardsCollection.fromJsonString(jsonString);
    developer.log('팝스 기준표 변환 완료: ${collection.standards.length}개 기준');
    
    return collection;
  }
  
  /// 최소한의 기본 기준 데이터 제공
  PapsStandardsCollection _getMinimalFallbackData() {
    // 매우 기본적인 팝스 기준 데이터
    const String fallbackJson = '''
{
  "초등학교": {
    "남자": {
      "5학년": {
        "심폐지구력": {
          "왕복오래달리기": [
            {
              "등급": 1,
              "점수": 20,
              "시작": 100.0,
              "종료": 150.0
            },
            {
              "등급": 3,
              "점수": 10,
              "시작": 50.0,
              "종료": 99.9
            },
            {
              "등급": 5,
              "점수": 0,
              "시작": 0.0,
              "종료": 49.9
            }
          ]
        },
        "유연성": {
          "앉아윗몸앞으로굽히기": [
            {
              "등급": 1,
              "점수": 20,
              "시작": 10.0,
              "종료": 50.0
            },
            {
              "등급": 3,
              "점수": 10,
              "시작": 5.0,
              "종료": 9.9
            },
            {
              "등급": 5,
              "점수": 0,
              "시작": -40.0,
              "종료": 4.9
            }
          ]
        }
      }
    },
    "여자": {
      "5학년": {
        "심폐지구력": {
          "왕복오래달리기": [
            {
              "등급": 1,
              "점수": 20,
              "시작": 80.0,
              "종료": 150.0
            },
            {
              "등급": 3,
              "점수": 10,
              "시작": 40.0,
              "종료": 79.9
            },
            {
              "등급": 5,
              "점수": 0,
              "시작": 0.0,
              "종료": 39.9
            }
          ]
        },
        "유연성": {
          "앉아윗몸앞으로굽히기": [
            {
              "등급": 1,
              "점수": 20,
              "시작": 15.0,
              "종료": 50.0
            },
            {
              "등급": 3,
              "점수": 10,
              "시작": 8.0,
              "종료": 14.9
            },
            {
              "등급": 5,
              "점수": 0,
              "시작": -40.0,
              "종료": 7.9
            }
          ]
        }
      }
    }
  }
}
''';
    
    return PapsStandardsCollection.fromJsonString(fallbackJson);
  }
}
