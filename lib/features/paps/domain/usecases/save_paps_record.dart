import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/paps_record.dart';
import '../repositories/paps_repository.dart';

/// PAPS 측정 기록 저장 유스케이스
class SavePapsRecord implements UseCase<PapsRecord, SavePapsRecordParams> {
  final PapsRepository repository;

  SavePapsRecord(this.repository);

  @override
  Future<Either<Failure, PapsRecord>> call(SavePapsRecordParams params) async {
    return await repository.savePapsRecord(params.record);
  }
}

/// PAPS 기록 저장 파라미터
class SavePapsRecordParams extends Equatable {
  final PapsRecord record;

  const SavePapsRecordParams({
    required this.record,
  });

  @override
  List<Object> get props => [record];
}
