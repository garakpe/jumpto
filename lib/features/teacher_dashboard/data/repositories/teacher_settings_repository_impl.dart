import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/teacher_settings.dart';
import '../../domain/repositories/teacher_settings_repository.dart';
import '../datasources/teacher_settings_remote_data_source.dart';
import '../models/teacher_settings_model.dart';

/// 교사 설정 레포지토리 구현체
class TeacherSettingsRepositoryImpl implements TeacherSettingsRepository {
  final TeacherSettingsRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  TeacherSettingsRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, TeacherSettings>> getTeacherSettings(String teacherId) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteSettings = await remoteDataSource.getTeacherSettings(teacherId);
        return Right(remoteSettings);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, TeacherSettings>> saveTeacherSettings(TeacherSettings settings) async {
    if (await networkInfo.isConnected) {
      try {
        final settingsModel = TeacherSettingsModel.fromDomain(settings);
        final savedSettings = await remoteDataSource.saveTeacherSettings(settingsModel);
        return Right(savedSettings);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}