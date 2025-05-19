import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/base_user.dart';
import '../repositories/auth_repository.dart';

class SignInWithEmailPassword implements UseCase<Either<Failure, BaseUser>, SignInWithEmailPasswordParams> {
  final AuthRepository repository;

  SignInWithEmailPassword(this.repository);

  @override
  Future<Either<Failure, BaseUser>> call(SignInWithEmailPasswordParams params) {
    return repository.signInWithEmailPassword(
      email: params.email,
      password: params.password,
    );
  }
}

class SignInWithEmailPasswordParams extends Equatable {
  final String email;
  final String password;

  const SignInWithEmailPasswordParams({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}
