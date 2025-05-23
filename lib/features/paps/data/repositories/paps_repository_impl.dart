import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/index.dart';
import '../../domain/repositories/paps_repository.dart';
import '../datasources/paps_local_data_source.dart';
import '../datasources/paps_remote_data_source.dart';

/// 팝스 레포지토리 구현체
class PapsRepositoryImpl implements PapsRepository {
  final PapsLocalDataSource _localDataSource;
  final PapsRemoteDataSource _remoteDataSource;

  /// 생성자
  PapsRepositoryImpl(this._localDataSource, this._remoteDataSource);

  @override
  Future<Either<Failure, PapsStandardsCollection>> getAllPapsStandards() async {
    try {
      final standards = await _localDataSource.getPapsStandards();
      return Right(standards);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PapsStandard?>> getPapsStandard({
    required SchoolLevel schoolLevel,
    required int gradeNumber,
    required Gender gender,
    required FitnessFactor fitnessFactor,
    required String eventName,
  }) async {
    try {
      final standards = await _localDataSource.getPapsStandards();
      
      final standard = standards.findStandard(
        schoolLevel: schoolLevel,
        gradeNumber: gradeNumber,
        gender: gender,
        fitnessFactor: fitnessFactor,
        eventName: eventName,
      );
      
      return Right(standard);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PapsRecord>> savePapsRecord(PapsRecord record) async {
    try {
      final savedRecord = await _remoteDataSource.savePapsRecord(record);
      return Right(savedRecord);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PapsRecord>>> getStudentPapsRecords(String studentId) async {
    try {
      final records = await _remoteDataSource.getStudentPapsRecords(studentId);
      return Right(records);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PapsRecord?>> getLatestStudentPapsRecord({
    required String studentId,
    required FitnessFactor fitnessFactor,
  }) async {
    try {
      final records = await _remoteDataSource.getStudentPapsRecords(studentId);
      
      // 특정 체력요인에 대한 기록만 필터링하고 날짜순으로 정렬
      final filteredRecords = records
          .where((record) => record.fitnessFactor == fitnessFactor)
          .toList()
        ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
      
      // 최신 기록 반환 (없으면 null)
      return Right(filteredRecords.isEmpty ? null : filteredRecords.first);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, List<PapsRecord>>>> getClassPapsRecords({
    required String teacherId,
    required String className,
  }) async {
    try {
      final records = await _remoteDataSource.getClassPapsRecords(
        teacherId: teacherId,
        className: className,
      );
      
      return Right(records);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
