import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// 이메일/비밀번호로 로그인하는 유스케이스
///
/// 주의: 이 파일은 sign_in_with_email_password.dart와 동일한 기능을 합니다.
/// 레거시 코드 호환성을 위해 유지됩니다.
class LoginWithEmailPassword implements UseCase<User, LoginParams> {
  final AuthRepository repository;

  LoginWithEmailPassword(this.repository);

  @override
  Future<Either<Failure, User>> call(LoginParams params) async {
    return await repository.signInWithEmailPassword(
      email: params.email,
      password: params.password,
    );
  }
}

/// 로그인 파라미터
class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}