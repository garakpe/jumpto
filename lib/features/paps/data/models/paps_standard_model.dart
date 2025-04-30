import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/paps_standard.dart';

part 'paps_standard_model.g.dart';

/// PapsStandard 엔티티의 데이터 모델 구현
/// Firestore 문서와 도메인 엔티티 사이의 변환을 담당
@JsonSerializable()
class PapsStandardModel extends PapsStandard {
  const PapsStandardModel({
    required PapsItemId itemId,
    required String itemName,
    required String category,
    required String gender,
    required String grade,
    required String unit,
    required bool isHigherBetter,
    required Map<PapsGrade, dynamic> criteria,
  }) : super(
          itemId: itemId,
          itemName: itemName,
          category: category,
          gender: gender,
          grade: grade,
          unit: unit,
          isHigherBetter: isHigherBetter,
          criteria: criteria,
        );

  /// Firestore 문서에서 PapsStandardModel 객체 생성
  factory PapsStandardModel.fromJson(Map<String, dynamic> json) {
    // PapsItemId Enum 변환
    final PapsItemId itemId = _stringToPapsItemId(json['itemId'] as String);
    
    // criteria Map 변환 (String -> PapsGrade key로 변환)
    final Map<String, dynamic> rawCriteria = json['criteria'] as Map<String, dynamic>;
    final Map<PapsGrade, dynamic> criteriaMapped = {};
    
    for (final entry in rawCriteria.entries) {
      final PapsGrade grade = _stringToPapsGrade(entry.key);
      criteriaMapped[grade] = entry.value;
    }

    return PapsStandardModel(
      itemId: itemId,
      itemName: json['itemName'] as String,
      category: json['category'] as String,
      gender: json['gender'] as String,
      grade: json['grade'] as String,
      unit: json['unit'] as String,
      isHigherBetter: json['isHigherBetter'] as bool,
      criteria: criteriaMapped,
    );
  }

  /// PapsStandardModel 객체를 Firestore 문서로 변환
  Map<String, dynamic> toJson() {
    // PapsItemId Enum을 String으로 변환
    final String itemIdString = _papsItemIdToString(itemId);
    
    // criteria Map 변환 (PapsGrade -> String key로 변환)
    final Map<String, dynamic> criteriaConverted = {};
    
    for (final entry in criteria.entries) {
      final String gradeString = _papsGradeToString(entry.key);
      criteriaConverted[gradeString] = entry.value;
    }

    return {
      'itemId': itemIdString,
      'itemName': itemName,
      'category': category,
      'gender': gender,
      'grade': grade,
      'unit': unit,
      'isHigherBetter': isHigherBetter,
      'criteria': criteriaConverted,
    };
  }

  /// 도메인 엔티티에서 데이터 모델 생성
  factory PapsStandardModel.fromEntity(PapsStandard entity) {
    return PapsStandardModel(
      itemId: entity.itemId,
      itemName: entity.itemName,
      category: entity.category,
      gender: entity.gender,
      grade: entity.grade,
      unit: entity.unit,
      isHigherBetter: entity.isHigherBetter,
      criteria: entity.criteria,
    );
  }

  /// String을 PapsItemId Enum으로 변환하는 헬퍼 메서드
  static PapsItemId _stringToPapsItemId(String value) {
    return PapsItemId.values.firstWhere(
      (element) => element.toString() == 'PapsItemId.$value',
      orElse: () => PapsItemId.pacer,
    );
  }

  /// PapsItemId Enum을 String으로 변환하는 헬퍼 메서드
  static String _papsItemIdToString(PapsItemId itemId) {
    return itemId.toString().split('.').last;
  }

  /// String을 PapsGrade Enum으로 변환하는 헬퍼 메서드
  static PapsGrade _stringToPapsGrade(String value) {
    return PapsGrade.values.firstWhere(
      (element) => element.toString() == 'PapsGrade.$value',
      orElse: () => PapsGrade.grade3,
    );
  }

  /// PapsGrade Enum을 String으로 변환하는 헬퍼 메서드
  static String _papsGradeToString(PapsGrade grade) {
    return grade.toString().split('.').last;
  }
}
