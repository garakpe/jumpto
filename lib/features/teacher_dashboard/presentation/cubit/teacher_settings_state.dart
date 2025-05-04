import 'package:equatable/equatable.dart';

import '../../domain/entities/teacher_settings.dart';

/// 교사 설정 Cubit 상태
abstract class TeacherSettingsState extends Equatable {
  const TeacherSettingsState();

  @override
  List<Object?> get props => [];
}

/// 초기 상태
class TeacherSettingsInitial extends TeacherSettingsState {
  const TeacherSettingsInitial();
}

/// 로딩 상태
class TeacherSettingsLoading extends TeacherSettingsState {
  const TeacherSettingsLoading();
}

/// 로드 성공 상태
class TeacherSettingsLoaded extends TeacherSettingsState {
  final TeacherSettings settings;

  const TeacherSettingsLoaded({required this.settings});

  @override
  List<Object?> get props => [settings];
}

/// 저장 성공 상태
class TeacherSettingsSaved extends TeacherSettingsState {
  final TeacherSettings settings;

  const TeacherSettingsSaved({required this.settings});

  @override
  List<Object?> get props => [settings];
}

/// 오류 상태
class TeacherSettingsError extends TeacherSettingsState {
  final String message;

  const TeacherSettingsError({required this.message});

  @override
  List<Object?> get props => [message];
}