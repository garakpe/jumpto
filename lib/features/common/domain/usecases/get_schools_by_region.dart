import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/school.dart';
import '../repositories/school_repository.dart';

/// 특정 지역 학교 목록 조회 유스케이스
class GetSchoolsByRegion implements UseCase<List<School>, RegionParams> {
  final SchoolRepository repository;

  GetSchoolsByRegion(this.repository);

  @override
  Future<Either<Failure, List<School>>> call(RegionParams params) async {
    return await repository.getSchoolsByRegion(params.region);
  }
}

/// 특정 지역 지정에 필요한 파라미터
class RegionParams extends Equatable {
  final String region;

  const RegionParams({required this.region});

  @override
  List<Object?> get props => [region];
}
