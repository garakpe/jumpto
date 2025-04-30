import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// 현재 로그인된 사용자 정보를 가져오는 유스케이스
class GetCurrentUser implements UseCase<User?, NoParams> {
  final AuthRepository repository;
  
  GetCurrentUser(this.repository);
  
  @override
  Future<Either<Failure, User?>> call(NoParams params) async {
    return await repository.getCurrentUser();
  }
}
