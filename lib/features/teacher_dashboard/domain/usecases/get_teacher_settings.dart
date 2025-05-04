import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/teacher_settings.dart';
import '../repositories/teacher_settings_repository.dart';

/// 교사 설정 조회 유스케이스
class GetTeacherSettings implements UseCase<TeacherSettings, GetTeacherSettingsParams> {
  final TeacherSettingsRepository repository;

  const GetTeacherSettings(this.repository);

  @override
  Future<Either<Failure, TeacherSettings>> call(GetTeacherSettingsParams params) async {
    return await repository.getTeacherSettings(params.teacherId);
  }
}

/// 교사 설정 조회 유스케이스 파라미터
class GetTeacherSettingsParams extends Equatable {
  final String teacherId;

  const GetTeacherSettingsParams({
    required this.teacherId,
  });

  @override
  List<Object?> get props => [teacherId];
}