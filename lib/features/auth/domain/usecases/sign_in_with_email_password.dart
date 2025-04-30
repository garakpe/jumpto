import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// 이메일/비밀번호로 로그인하는 유스케이스
class SignInWithEmailPassword implements UseCase<User, SignInParams> {
  final AuthRepository repository;

  SignInWithEmailPassword(this.repository);

  @override
  Future<Either<Failure, User>> call(SignInParams params) async {
    return await repository.signInWithEmailPassword(
      email: params.email,
      password: params.password,
    );
  }
}

/// 로그인 파라미터
class SignInParams extends Equatable {
  final String email;
  final String password;

  const SignInParams({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
  
  @override
  String toString() => 'SignInParams(email: $email)';
}
