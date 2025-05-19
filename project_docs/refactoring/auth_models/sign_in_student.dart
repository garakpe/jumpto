import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/base_user.dart';
import '../repositories/auth_repository.dart';

class SignInStudent implements UseCase<Either<Failure, BaseUser>, SignInStudentParams> {
  final AuthRepository repository;

  SignInStudent(this.repository);

  @override
  Future<Either<Failure, BaseUser>> call(SignInStudentParams params) {
    return repository.signInStudent(
      schoolName: params.schoolName,
      studentId: params.studentId,
      password: params.password,
    );
  }
}

class SignInStudentParams extends Equatable {
  final String schoolName;
  final String studentId;
  final String password;

  const SignInStudentParams({
    required this.schoolName,
    required this.studentId,
    required this.password,
  });

  @override
  List<Object> get props => [schoolName, studentId, password];
}
