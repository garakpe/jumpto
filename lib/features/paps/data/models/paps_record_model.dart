import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/event.dart';
import '../../domain/entities/fitness_factor.dart';
import '../../domain/entities/gender.dart';
import '../../domain/entities/grade.dart';
import '../../domain/entities/paps_record.dart';
import '../../domain/entities/school_level.dart';

/// 팝스 측정 기록 모델
///
/// Firestore와의 데이터 변환을 위한 모델 클래스
class PapsRecordModel extends PapsRecord {
  /// 생성자
  PapsRecordModel({
    required super.id,
    required super.studentId,
    required super.schoolLevel,
    required super.grade,
    required super.gender,
    required super.fitnessFactor,
    required super.event,
    required super.value,
    required super.recordGrade,
    required super.score,
    required super.recordedAt,
  });
  
  /// 도메인 엔티티에서 모델 생성
  factory PapsRecordModel.fromEntity(PapsRecord entity) {
    return PapsRecordModel(
      id: entity.id,
      studentId: entity.studentId,
      schoolLevel: entity.schoolLevel,
      grade: entity.grade,
      gender: entity.gender,
      fitnessFactor: entity.fitnessFactor,
      event: entity.event,
      value: entity.value,
      recordGrade: entity.recordGrade,
      score: entity.score,
      recordedAt: entity.recordedAt,
    );
  }
  
  /// JSON에서 모델 생성
  factory PapsRecordModel.fromJson(Map<String, dynamic> json) {
    return PapsRecordModel(
      id: json['id'] ?? '',
      studentId: json['studentId'],
      schoolLevel: SchoolLevel.fromKoreanName(json['schoolLevel']),
      grade: Grade.fromString(
        SchoolLevel.fromKoreanName(json['schoolLevel']), 
        json['grade']
      ),
      gender: Gender.fromKoreanName(json['gender']),
      fitnessFactor: FitnessFactor.fromKoreanName(json['fitnessFactor']),
      event: Event.findByName(json['event']),
      value: json['value'].toDouble(),
      recordGrade: json['recordGrade'],
      score: json['score'],
      recordedAt: json['recordedAt'] is String 
          ? DateTime.parse(json['recordedAt'])
          : (json['recordedAt'] as Timestamp).toDate(),
    );
  }
  
  /// 모델을 JSON으로 변환
  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    
    // Firestore는 DateTime을 Timestamp로 변환
    json['recordedAt'] = Timestamp.fromDate(recordedAt);
    
    return json;
  }
  
  /// 복사본 생성 (일부 속성 변경 가능)
  PapsRecordModel copyWith({
    String? id,
    String? studentId,
    SchoolLevel? schoolLevel,
    Grade? grade,
    Gender? gender,
    FitnessFactor? fitnessFactor,
    Event? event,
    double? value,
    dynamic recordGrade,
    int? score,
    DateTime? recordedAt,
  }) {
    return PapsRecordModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      schoolLevel: schoolLevel ?? this.schoolLevel,
      grade: grade ?? this.grade,
      gender: gender ?? this.gender,
      fitnessFactor: fitnessFactor ?? this.fitnessFactor,
      event: event ?? this.event,
      value: value ?? this.value,
      recordGrade: recordGrade ?? this.recordGrade,
      score: score ?? this.score,
      recordedAt: recordedAt ?? this.recordedAt,
    );
  }
}
