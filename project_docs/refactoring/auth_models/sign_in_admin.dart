import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/admin.dart';
import '../repositories/auth_repository.dart';

class SignInAdmin implements UseCase<Either<Failure, Admin>, SignInAdminParams> {
  final AuthRepository repository;

  SignInAdmin(this.repository);

  @override
  Future<Either<Failure, Admin>> call(SignInAdminParams params) {
    return repository.signInAdmin(
      username: params.username,
      password: params.password,
    );
  }
}

class SignInAdminParams extends Equatable {
  final String username;
  final String password;

  const SignInAdminParams({
    required this.username,
    required this.password,
  });

  @override
  List<Object> get props => [username, password];
}
