import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/school.dart';
import '../../domain/repositories/school_repository.dart';
import '../datasources/school_local_data_source.dart';

/// 학교 레포지토리 구현체
class SchoolRepositoryImpl implements SchoolRepository {
  final SchoolLocalDataSource localDataSource;

  SchoolRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, List<String>>> getRegions() async {
    try {
      final regions = await localDataSource.getRegions();
      return Right(regions);
    } catch (e) {
      return Left(CacheFailure(message: '지역 목록을 불러오는 중 오류가 발생했습니다.'));
    }
  }

  @override
  Future<Either<Failure, List<School>>> getSchoolsByRegion(String region) async {
    try {
      final schools = await localDataSource.getSchoolsByRegion(region);
      return Right(schools);
    } catch (e) {
      return Left(CacheFailure(message: '학교 목록을 불러오는 중 오류가 발생했습니다.'));
    }
  }

  @override
  Future<Either<Failure, List<School>>> searchSchools(String region, String query) async {
    try {
      final schools = await localDataSource.searchSchools(region, query);
      return Right(schools);
    } catch (e) {
      return Left(CacheFailure(message: '학교 검색 중 오류가 발생했습니다.'));
    }
  }
}
