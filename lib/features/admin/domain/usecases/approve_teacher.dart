import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/admin_repository.dart';

/// 교사 계정 승인 파라미터
class ApproveTeacherParams {
  final String teacherId;
  
  ApproveTeacherParams({required this.teacherId});
}

/// 교사 계정 승인 유스케이스
class ApproveTeacher implements UseCase<void, ApproveTeacherParams> {
  final AdminRepository repository;
  
  ApproveTeacher(this.repository);
  
  @override
  Future<Either<Failure, void>> call(ApproveTeacherParams params) {
    return repository.approveTeacher(params.teacherId);
  }
}