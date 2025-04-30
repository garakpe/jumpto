import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/paps_record.dart';
import '../repositories/paps_repository.dart';

/// 팝스 측정 기록 저장 유스케이스
class SavePapsRecord implements UseCase<PapsRecord, PapsRecordParams> {
  final PapsRepository repository;
  
  SavePapsRecord(this.repository);
  
  @override
  Future<Either<Failure, PapsRecord>> call(PapsRecordParams params) async {
    return await repository.savePapsRecord(params.record);
  }
}

/// 팝스 측정 기록 파라미터
class PapsRecordParams extends Equatable {
  final PapsRecord record;
  
  const PapsRecordParams({required this.record});
  
  @override
  List<Object> get props => [record];
  
  @override
  String toString() => 'PapsRecordParams(record: $record)';
}
