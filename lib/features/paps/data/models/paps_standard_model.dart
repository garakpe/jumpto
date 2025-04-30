import '../../domain/entities/fitness_factor.dart';
import '../../domain/entities/gender.dart';
import '../../domain/entities/grade.dart';
import '../../domain/entities/school_level.dart';
import '../../domain/entities/event.dart';
import '../../domain/entities/grade_range.dart';
import '../../domain/entities/paps_standard.dart';

/// PapsStandard 엔티티의 데이터 모델 구현
/// Firestore 문서와 도메인 엔티티 사이의 변환을 담당

class PapsStandardModel extends PapsStandard {
  PapsStandardModel({
    required super.schoolLevel,
    required super.gender,
    required super.grade,
    required super.fitnessFactor,
    required super.event,
    required super.gradeRanges,
  });

  /// Firestore 문서에서 PapsStandardModel 객체 생성
  factory PapsStandardModel.fromJson(Map<String, dynamic> json) {
    final schoolLevel = SchoolLevel.fromKoreanName(json['schoolLevel']);
    final gender = Gender.fromKoreanName(json['gender']);
    final grade = Grade.fromString(schoolLevel, json['grade']);
    final fitnessFactor = FitnessFactor.fromKoreanName(json['fitnessFactor']);
    final event = Event.findByName(json['event']);

    final List<GradeRange> gradeRanges =
        (json['gradeRanges'] as List)
            .map((range) => GradeRange.fromJson(range as Map<String, dynamic>))
            .toList();

    return PapsStandardModel(
      schoolLevel: schoolLevel,
      gender: gender,
      grade: grade,
      fitnessFactor: fitnessFactor,
      event: event,
      gradeRanges: gradeRanges,
    );
  }

  /// PapsStandardModel 객체를 Firestore 문서로 변환
  Map<String, dynamic> toJson() {
    return {
      'schoolLevel': schoolLevel.koreanName,
      'gender': gender.koreanName,
      'grade': grade.koreanName,
      'fitnessFactor': fitnessFactor.koreanName,
      'event': event.koreanName,
      'gradeRanges': gradeRanges.map((range) => range.toJson()).toList(),
    };
  }

  /// 도메인 엔티티에서 데이터 모델 생성
  factory PapsStandardModel.fromEntity(PapsStandard entity) {
    return PapsStandardModel(
      schoolLevel: entity.schoolLevel,
      gender: entity.gender,
      grade: entity.grade,
      fitnessFactor: entity.fitnessFactor,
      event: entity.event,
      gradeRanges: entity.gradeRanges,
    );
  }
}
