import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/school_repository.dart';

/// 지역 목록 조회 유스케이스
class GetRegions implements UseCase<List<String>, NoParams> {
  final SchoolRepository repository;

  GetRegions(this.repository);

  @override
  Future<Either<Failure, List<String>>> call(NoParams params) async {
    return await repository.getRegions();
  }
}
