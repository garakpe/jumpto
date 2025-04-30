import 'models/event.dart';
import 'models/fitness_factor.dart';
import 'models/gender.dart';
import 'models/grade.dart';
import 'models/school_level.dart';

/// 팝스 측정 기록 엔티티
///
/// 학생의 팝스 측정 기록을 저장하는 클래스입니다.
class PapsRecord {
  /// 고유 식별자
  final String id;
  
  /// 학생 ID
  final String studentId;
  
  /// 학교급
  final SchoolLevel schoolLevel;
  
  /// 학년
  final Grade grade;
  
  /// 성별
  final Gender gender;
  
  /// 체력요인
  final FitnessFactor fitnessFactor;
  
  /// 평가종목
  final Event event;
  
  /// 측정값
  final double value;
  
  /// 등급 (1~5 또는 비만 관련 문자열)
  final dynamic recordGrade;
  
  /// 점수 (0~20)
  final int score;
  
  /// 측정 일시
  final DateTime recordedAt;

  /// 생성자
  PapsRecord({
    required this.id,
    required this.studentId,
    required this.schoolLevel,
    required this.grade,
    required this.gender,
    required this.fitnessFactor,
    required this.event,
    required this.value,
    required this.recordGrade,
    required this.score,
    required this.recordedAt,
  });

  /// JSON 형태에서 객체 생성
  factory PapsRecord.fromJson(Map<String, dynamic> json) {
    return PapsRecord(
      id: json['id'],
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
      recordedAt: DateTime.parse(json['recordedAt']),
    );
  }

  /// 객체를 JSON 형태로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'schoolLevel': schoolLevel.koreanName,
      'grade': grade.koreanName,
      'gender': gender.koreanName,
      'fitnessFactor': fitnessFactor.koreanName,
      'event': event.koreanName,
      'value': value,
      'recordGrade': recordGrade,
      'score': score,
      'recordedAt': recordedAt.toIso8601String(),
    };
  }
  
  /// 복사본 생성 (일부 속성 변경 가능)
  PapsRecord copyWith({
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
    return PapsRecord(
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
  
  @override
  String toString() {
    return 'PapsRecord(id: $id, studentId: $studentId, schoolLevel: $schoolLevel, ' +
           'grade: $grade, gender: $gender, fitnessFactor: $fitnessFactor, ' +
           'event: $event, value: $value, recordGrade: $recordGrade, ' +
           'score: $score, recordedAt: $recordedAt)';
  }
  
  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    (other is PapsRecord &&
     id == other.id &&
     studentId == other.studentId &&
     schoolLevel == other.schoolLevel &&
     grade == other.grade &&
     gender == other.gender &&
     fitnessFactor == other.fitnessFactor &&
     event == other.event &&
     value == other.value &&
     recordGrade == other.recordGrade &&
     score == other.score &&
     recordedAt == other.recordedAt);
  
  @override
  int get hashCode =>
    id.hashCode ^
    studentId.hashCode ^
    schoolLevel.hashCode ^
    grade.hashCode ^
    gender.hashCode ^
    fitnessFactor.hashCode ^
    event.hashCode ^
    value.hashCode ^
    recordGrade.hashCode ^
    score.hashCode ^
    recordedAt.hashCode;
}
