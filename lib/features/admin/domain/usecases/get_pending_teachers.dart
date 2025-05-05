import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/entities/user.dart';
import '../repositories/admin_repository.dart';

/// 승인 대기 중인 교사 목록 조회 유스케이스
class GetPendingTeachers implements UseCase<List<User>, NoParams> {
  final AdminRepository repository;
  
  GetPendingTeachers(this.repository);
  
  @override
  Future<Either<Failure, List<User>>> call(NoParams params) {
    return repository.getPendingTeachers();
  }
}