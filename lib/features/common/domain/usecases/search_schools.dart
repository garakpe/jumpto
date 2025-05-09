import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/school.dart';
import '../repositories/school_repository.dart';

/// 학교 검색 유스케이스
class SearchSchools implements UseCase<List<School>, SearchSchoolsParams> {
  final SchoolRepository repository;

  SearchSchools(this.repository);

  @override
  Future<Either<Failure, List<School>>> call(SearchSchoolsParams params) async {
    return await repository.searchSchools(params.region, params.query);
  }
}

/// 학교 검색에 필요한 파라미터
class SearchSchoolsParams extends Equatable {
  final String region;
  final String query;

  const SearchSchoolsParams({
    required this.region,
    required this.query,
  });

  @override
  List<Object?> get props => [region, query];
}
