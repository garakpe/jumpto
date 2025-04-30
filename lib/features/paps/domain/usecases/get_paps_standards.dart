import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/paps_standard.dart';
import '../repositories/paps_repository.dart';

/// 특정 학년, 성별에 맞는 PAPS 기준표 조회 유스케이스
class GetPapsStandards implements UseCase<List<PapsStandard>, PapsStandardsParams> {
  final PapsRepository repository;

  GetPapsStandards(this.repository);

  @override
  Future<Either<Failure, List<PapsStandard>>> call(PapsStandardsParams params) async {
    return await repository.getPapsStandardsByGradeAndGender(params.grade, params.gender);
  }
}

/// PAPS 기준표 조회 파라미터
class PapsStandardsParams extends Equatable {
  final String grade; // 학년
  final String gender; // 성별

  const PapsStandardsParams({
    required this.grade,
    required this.gender,
  });

  @override
  List<Object> get props => [grade, gender];
}
