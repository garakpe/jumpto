import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// 학생 로그인을 위한 파라미터
class SignInStudentParams extends Equatable {
  final String schoolId;
  final String studentId;
  final String password;

  const SignInStudentParams({
    required this.schoolId,
    required this.studentId,
    required this.password,
  });

  @override
  List<Object?> get props => [schoolId, studentId, password];
}

/// 학생 로그인 유스케이스
class SignInStudent implements UseCase<User, SignInStudentParams> {
  final AuthRepository _repository;

  SignInStudent(this._repository);

  @override
  Future<Either<Failure, User>> call(SignInStudentParams params) {
    return _repository.signInStudent(
      schoolId: params.schoolId,
      studentId: params.studentId,
      password: params.password,
    );
  }
}
