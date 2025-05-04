import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/teacher_settings.dart';
import '../repositories/teacher_settings_repository.dart';

/// 교사 설정 저장 유스케이스
class SaveTeacherSettings implements UseCase<TeacherSettings, SaveTeacherSettingsParams> {
  final TeacherSettingsRepository repository;

  const SaveTeacherSettings(this.repository);

  @override
  Future<Either<Failure, TeacherSettings>> call(SaveTeacherSettingsParams params) async {
    return await repository.saveTeacherSettings(params.settings);
  }
}

/// 교사 설정 저장 유스케이스 파라미터
class SaveTeacherSettingsParams extends Equatable {
  final TeacherSettings settings;

  const SaveTeacherSettingsParams({
    required this.settings,
  });

  @override
  List<Object?> get props => [settings];
}