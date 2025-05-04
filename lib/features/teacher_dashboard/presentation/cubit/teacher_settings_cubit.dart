import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../features/paps/domain/entities/index.dart';
import '../../domain/entities/teacher_settings.dart';
import '../../domain/usecases/get_teacher_settings.dart';
import '../../domain/usecases/save_teacher_settings.dart';
import 'teacher_settings_state.dart';

/// 교사 설정 Cubit
class TeacherSettingsCubit extends Cubit<TeacherSettingsState> {
  final GetTeacherSettings getTeacherSettings;
  final SaveTeacherSettings saveTeacherSettings;

  TeacherSettingsCubit({
    required this.getTeacherSettings,
    required this.saveTeacherSettings,
  }) : super(const TeacherSettingsInitial());

  /// 교사 설정 로드
  Future<void> loadSettings(String teacherId) async {
    emit(const TeacherSettingsLoading());

    final result = await getTeacherSettings(GetTeacherSettingsParams(teacherId: teacherId));

    emit(result.fold(
      (failure) => TeacherSettingsError(message: _mapFailureToMessage(failure)),
      (settings) => TeacherSettingsLoaded(settings: settings),
    ));
  }

  /// 교사 설정 저장
  Future<void> saveSettings(TeacherSettings settings) async {
    emit(const TeacherSettingsLoading());

    final result = await saveTeacherSettings(SaveTeacherSettingsParams(settings: settings));

    emit(result.fold(
      (failure) => TeacherSettingsError(message: _mapFailureToMessage(failure)),
      (settings) => TeacherSettingsSaved(settings: settings),
    ));
  }

  /// 측정 종목 업데이트
  Future<void> updateSelectedEvent(String teacherId, FitnessFactor factor, String eventName) async {
    // 현재 상태가 로드된 상태인지 확인
    if (state is TeacherSettingsLoaded) {
      final currentSettings = (state as TeacherSettingsLoaded).settings;
      
      // 선택된 종목 업데이트
      final updatedSettings = currentSettings.updateSelectedEvent(factor, eventName);
      
      // 업데이트된 설정 저장
      await saveSettings(updatedSettings);
    } else if (state is TeacherSettingsSaved) {
      final currentSettings = (state as TeacherSettingsSaved).settings;
      
      // 선택된 종목 업데이트
      final updatedSettings = currentSettings.updateSelectedEvent(factor, eventName);
      
      // 업데이트된 설정 저장
      await saveSettings(updatedSettings);
    } else {
      // 설정이 로드되어 있지 않은 경우, 먼저 로드
      await loadSettings(teacherId);
      
      if (state is TeacherSettingsLoaded) {
        // 로드 후 업데이트
        await updateSelectedEvent(teacherId, factor, eventName);
      }
    }
  }

  /// 실패 메시지 매핑
  String _mapFailureToMessage(Failure failure) {
    // 실패 유형에 따른 메시지 반환
    switch (failure.runtimeType) {
      case ServerFailure:
        return (failure as ServerFailure).message;
      case NetworkFailure:
        return (failure as NetworkFailure).message;
      case CacheFailure:
        return (failure as CacheFailure).message;
      case AuthFailure:
        return (failure as AuthFailure).message;
      case UnknownFailure:
        return (failure as UnknownFailure).message;
      default:
        return '오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
    }
  }
}