import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/paps_record.dart';
import '../repositories/paps_repository.dart';

/// 학생의 팝스 측정 기록 조회 유스케이스
class GetStudentPapsRecords implements UseCase<List<PapsRecord>, StudentIdParams> {
  final PapsRepository repository;
  
  GetStudentPapsRecords(this.repository);
  
  @override
  Future<Either<Failure, List<PapsRecord>>> call(StudentIdParams params) async {
    return await repository.getStudentPapsRecords(params.studentId);
  }
}

/// 학생 ID 파라미터
class StudentIdParams extends Equatable {
  final String studentId;
  
  const StudentIdParams({required this.studentId});
  
  @override
  List<Object> get props => [studentId];
  
  @override
  String toString() => 'StudentIdParams(studentId: $studentId)';
}
