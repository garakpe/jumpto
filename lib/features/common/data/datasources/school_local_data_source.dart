import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/school_model.dart';

/// 학교 로컬 데이터 소스 인터페이스
abstract class SchoolLocalDataSource {
  /// 지역 목록 조회
  Future<List<String>> getRegions();

  /// 특정 지역의 학교 목록 조회
  Future<List<SchoolModel>> getSchoolsByRegion(String region);

  /// 학교 이름으로 검색
  Future<List<SchoolModel>> searchSchools(String region, String query);
}

/// 학교 로컬 데이터 소스 구현체
class SchoolLocalDataSourceImpl implements SchoolLocalDataSource {
  // 지역별 파일명 매핑
  final Map<String, String> _regionFileMap = {
    '서울': 'school_seoul.json',
    '부산': 'school_busan.json',
    '충청도': 'school_choongchung.json',
    '대전': 'school_daejoen.json',
    '대구': 'school_daeku.json',
    '인천': 'school_inchon.json',
    '제주': 'school_jejoo.json',
    '전라도': 'school_joenrado.json',
    '강원도': 'school_kangwondo.json',
    '광주': 'school_kwangju.json',
    '경기도': 'school_kyungido.json',
    '경상도': 'school_kyungsangdo.json',
    '세종': 'school_sejong.json',
    '울산': 'school_ulsan.json',
  };

  // 지역별 학교 데이터 캐시
  final Map<String, List<SchoolModel>> _schoolsCache = {};

  @override
  Future<List<String>> getRegions() async {
    // 지역 목록 반환
    return _regionFileMap.keys.toList();
  }

  @override
  Future<List<SchoolModel>> getSchoolsByRegion(String region) async {
    // 캐시에 있으면 캐시에서 반환
    if (_schoolsCache.containsKey(region)) {
      return _schoolsCache[region]!;
    }

    // 지역에 해당하는 파일명 확인
    final fileName = _regionFileMap[region];
    if (fileName == null) {
      throw Exception('지역을 찾을 수 없습니다: $region');
    }

    try {
      // 파일 경로 - 슬래시 처리 주의
      final filePath = 'assets/school_code/$fileName';
      print('학교 데이터 파일 로드 시도: $filePath');
      
      // 파일 읽기 시도
      String jsonString;
      try {
        jsonString = await rootBundle.loadString(filePath);
        print('학교 데이터 파일 로드 성공: $filePath');
      } catch (e) {
        // 첫 번째 방법 실패시 대체 경로 시도
        final alternatePath = 'assets/school_code/$fileName';
        print('대체 경로로 학교 데이터 파일 로드 시도: $alternatePath');
        jsonString = await rootBundle.loadString(alternatePath);
        print('대체 경로로 학교 데이터 파일 로드 성공: $alternatePath');
      }
      
      // JSON 파싱
      List<dynamic> jsonList;
      try {
        jsonList = json.decode(jsonString) as List<dynamic>;
      } catch (e) {
        print('JSON 파싱 오류: $e');
        print('JSON 데이터 샘플: ${jsonString.substring(0, jsonString.length > 100 ? 100 : jsonString.length)}...');
        throw Exception('JSON 파싱 실패: $e');
      }

      print('학교 데이터 항목 수: ${jsonList.length}');

      // JSON 데이터를 모델로 변환
      try {
        final schools = jsonList.map((json) => SchoolModel.fromJson(json)).toList();
        print('학교 모델 변환 성공: ${schools.length}개 학교 데이터 로드됨');
        
        // 캐시에 저장
        _schoolsCache[region] = schools;
        return schools;
      } catch (e) {
        print('학교 모델 변환 오류: $e');
        if (jsonList.isNotEmpty) {
          print('첫 번째 항목 샘플: ${jsonList.first}');
        }
        throw Exception('학교 모델 변환 실패: $e');
      }
    } catch (e) {
      print('학교 데이터 로드 실패: $e');
      // 빈 리스트 반환하여 앱 크래시 방지
      return [];
    }
  }

  @override
  Future<List<SchoolModel>> searchSchools(String region, String query) async {
    // 지역의 모든 학교 가져오기
    final schools = await getSchoolsByRegion(region);

    // 검색어가 비어있으면 모든 학교 반환
    if (query.isEmpty) {
      return schools;
    }

    // 검색어로 필터링
    return schools.where((school) => school.name.contains(query)).toList();
  }
}
