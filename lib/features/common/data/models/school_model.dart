import '../../domain/entities/school.dart';

/// 학교 모델 클래스
///
/// JSON 파일에서 읽어온 학교 데이터를 처리하기 위한 모델 클래스입니다.
class SchoolModel extends School {
  SchoolModel({
    required String code,
    required String name,
    required String establishmentYear,
    required String genderType,
    required String dayNightType,
    required String region,
    required String schoolType,
    required String foundationType,
  }) : super(
          code: code,
          name: name,
          establishmentYear: establishmentYear,
          genderType: genderType,
          dayNightType: dayNightType,
          region: region,
          schoolType: schoolType,
          foundationType: foundationType,
        );

  /// JSON 데이터로부터 SchoolModel 객체 생성
  factory SchoolModel.fromJson(Map<String, dynamic> json) {
    // key 가능성 처리 - BOM 문자 또는 공백 문제 해결
    String getStringValue(Map<String, dynamic> map, List<String> possibleKeys, String defaultValue) {
      for (final key in possibleKeys) {
        if (map.containsKey(key) && map[key] != null) {
          return map[key].toString();
        }
      }
      return defaultValue;
    }
    
    // 학교코드는 다양한 형태로 존재할 수 있음
    final code = getStringValue(json, [
      '﻿학교코드', // BOM 문자가 있는 학교코드
      '학교코드',      // 일반 학교코드
      'school_code',     // 영문 학교코드
      'code',            // 일반 코드
      '﻿school_code',// BOM 문자가 있는 영문 학교코드
    ], '');
    
    try {
      return SchoolModel(
        code: code,
        name: getStringValue(json, ['학교명', 'school_name', 'name'], ''),
        establishmentYear: getStringValue(json, ['설립년도', 'establishment_year'], ''),
        genderType: getStringValue(json, ['남녀공학구분명', 'gender_type'], ''),
        dayNightType: getStringValue(json, ['주야구분명', 'day_night_type'], ''),
        region: getStringValue(json, ['우편번호시도명', '시도명', 'region', 'province'], ''),
        schoolType: getStringValue(json, ['학교종류구분명', 'school_type'], ''),
        foundationType: getStringValue(json, ['설립구분명', 'foundation_type'], ''),
      );
    } catch (e) {
      print('학교 모델 변환 오류: $e, JSON: $json');
      // 오류 발생시 기본 값으로 대체
      return SchoolModel(
        code: code.isEmpty ? 'unknown' : code,
        name: json['학교명']?.toString() ?? '',
        establishmentYear: '',
        genderType: '',
        dayNightType: '',
        region: '',
        schoolType: '',
        foundationType: '',
      );
    }
  }

  /// SchoolModel 객체를 JSON 데이터로 변환
  Map<String, dynamic> toJson() {
    return {
      '학교코드': code,
      '학교명': name,
      '설립년도': establishmentYear,
      '남녀공학구분명': genderType,
      '주야구분명': dayNightType,
      '우편번호시도명': region,
      '학교종류구분명': schoolType,
      '설립구분명': foundationType,
    };
  }

  /// School 엔티티로 변환
  School toEntity() {
    return School(
      code: code,
      name: name,
      establishmentYear: establishmentYear,
      genderType: genderType,
      dayNightType: dayNightType,
      region: region,
      schoolType: schoolType,
      foundationType: foundationType,
    );
  }
}
