import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/entities/user.dart';
import '../repositories/admin_repository.dart';

/// 관리자 로그인 파라미터
class SignInAdminParams {
  final String username;
  final String password;
  
  SignInAdminParams({
    required this.username,
    required this.password,
  });
}

/// 관리자 로그인 유스케이스
class SignInAdmin implements UseCase<User, SignInAdminParams> {
  final AdminRepository repository;
  
  SignInAdmin(this.repository);
  
  @override
  Future<Either<Failure, User>> call(SignInAdminParams params) {
    return repository.signInAdmin(
      username: params.username,
      password: params.password,
    );
  }
}