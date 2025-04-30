import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/paps_record.dart';
import '../repositories/paps_repository.dart';

/// 학생의 PAPS 측정 기록 조회 유스케이스
class GetStudentPapsRecords implements UseCase<List<PapsRecord>, StudentPapsRecordsParams> {
  final PapsRepository repository;

  GetStudentPapsRecords(this.repository);

  @override
  Future<Either<Failure, List<PapsRecord>>> call(StudentPapsRecordsParams params) async {
    return await repository.getStudentPapsRecords(params.studentId);
  }
}

/// 학생 PAPS 기록 조회 파라미터
class StudentPapsRecordsParams extends Equatable {
  final String studentId;

  const StudentPapsRecordsParams({
    required this.studentId,
  });

  @override
  List<Object> get props => [studentId];
}
