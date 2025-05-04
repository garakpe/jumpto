import '../../../../features/paps/domain/entities/index.dart';
import '../../domain/entities/teacher_settings.dart';

/// 교사 설정 모델 (데이터 계층)
class TeacherSettingsModel extends TeacherSettings {
  const TeacherSettingsModel({
    required super.teacherId,
    required super.selectedEvents,
    required super.createdAt,
    required super.updatedAt,
  });

  /// 엔티티에서 모델 생성
  factory TeacherSettingsModel.fromDomain(TeacherSettings settings) {
    return TeacherSettingsModel(
      teacherId: settings.teacherId,
      selectedEvents: settings.selectedEvents,
      createdAt: settings.createdAt,
      updatedAt: settings.updatedAt,
    );
  }

  /// JSON에서 모델 생성
  factory TeacherSettingsModel.fromJson(Map<String, dynamic> json) {
    final selectedEventsMap = <FitnessFactor, String>{};
    
    // JSON에서 Map<String, String>으로 변환된 selectedEvents를 
    // Map<FitnessFactor, String>으로 변환
    final jsonSelectedEvents = json['selectedEvents'] as Map<String, dynamic>;
    
    jsonSelectedEvents.forEach((key, value) {
      final fitnessFactor = _stringToFitnessFactor(key);
      selectedEventsMap[fitnessFactor] = value as String;
    });

    return TeacherSettingsModel(
      teacherId: json['teacherId'] as String,
      selectedEvents: selectedEventsMap,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// 모델을 JSON으로 변환
  Map<String, dynamic> toJson() {
    final selectedEventsJson = <String, String>{};
    
    // Map<FitnessFactor, String>을 Map<String, String>으로 변환
    selectedEvents.forEach((factor, eventName) {
      selectedEventsJson[factor.name] = eventName;
    });

    return {
      'teacherId': teacherId,
      'selectedEvents': selectedEventsJson,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// 문자열을 FitnessFactor로 변환
  static FitnessFactor _stringToFitnessFactor(String name) {
    switch (name) {
      case 'cardioEndurance':
        return FitnessFactor.cardioEndurance;
      case 'flexibility':
        return FitnessFactor.flexibility;
      case 'muscularStrength':
        return FitnessFactor.muscularStrength;
      case 'power':
        return FitnessFactor.power;
      case 'bmi':
        return FitnessFactor.bmi;
      default:
        throw ArgumentError('Invalid FitnessFactor name: $name');
    }
  }

  /// 복사본 생성 (불변성 유지)
  @override
  TeacherSettingsModel copyWith({
    String? teacherId,
    Map<FitnessFactor, String>? selectedEvents,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TeacherSettingsModel(
      teacherId: teacherId ?? this.teacherId,
      selectedEvents: selectedEvents ?? this.selectedEvents,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}