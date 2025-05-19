import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/teacher.dart';
import '../repositories/auth_repository.dart';

class SignUpTeacher implements UseCase<Either<Failure, Teacher>, SignUpTeacherParams> {
  final AuthRepository repository;

  SignUpTeacher(this.repository);

  @override
  Future<Either<Failure, Teacher>> call(SignUpTeacherParams params) {
    return repository.signUpTeacher(
      email: params.email,
      password: params.password,
      displayName: params.displayName,
      schoolCode: params.schoolCode,
      schoolName: params.schoolName,
      phoneNumber: params.phoneNumber,
    );
  }
}

class SignUpTeacherParams extends Equatable {
  final String email;
  final String password;
  final String displayName;
  final String schoolCode;
  final String schoolName;
  final String? phoneNumber;

  const SignUpTeacherParams({
    required this.email,
    required this.password,
    required this.displayName,
    required this.schoolCode,
    required this.schoolName,
    this.phoneNumber,
  });

  @override
  List<Object?> get props => [email, password, displayName, schoolCode, schoolName, phoneNumber];
}
