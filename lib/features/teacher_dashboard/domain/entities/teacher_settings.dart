import 'package:equatable/equatable.dart';
import '../../../../features/paps/domain/entities/index.dart';

/// 교사 설정 엔티티
class TeacherSettings extends Equatable {
  /// 고유 식별자 (교사 ID)
  final String teacherId;
  
  /// 선택된 측정 종목 (FitnessFactor: 선택된 종목명)
  final Map<FitnessFactor, String> selectedEvents;
  
  /// 생성일시
  final DateTime createdAt;
  
  /// 수정일시
  final DateTime updatedAt;

  const TeacherSettings({
    required this.teacherId,
    required this.selectedEvents,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 기본 설정으로 초기화된 인스턴스 생성
  factory TeacherSettings.defaultSettings(String teacherId) {
    final now = DateTime.now();
    return TeacherSettings(
      teacherId: teacherId,
      selectedEvents: {
        FitnessFactor.cardioEndurance: '왕복오래달리기',
        FitnessFactor.flexibility: '앉아윗몸앞으로굽히기',
        FitnessFactor.muscularStrength: '윗몸말아올리기',
        FitnessFactor.power: '50m달리기',
        FitnessFactor.bmi: '체질량지수',
      },
      createdAt: now,
      updatedAt: now,
    );
  }

  /// 복사본 생성 (불변성 유지)
  TeacherSettings copyWith({
    String? teacherId,
    Map<FitnessFactor, String>? selectedEvents,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TeacherSettings(
      teacherId: teacherId ?? this.teacherId,
      selectedEvents: selectedEvents ?? this.selectedEvents,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 선택된 종목 업데이트
  TeacherSettings updateSelectedEvent(FitnessFactor factor, String eventName) {
    final updatedEvents = Map<FitnessFactor, String>.from(selectedEvents);
    updatedEvents[factor] = eventName;
    
    return copyWith(
      selectedEvents: updatedEvents,
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [teacherId, selectedEvents, createdAt, updatedAt];
}