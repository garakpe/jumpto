import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// 교사 회원가입 유스케이스
class RegisterTeacher implements UseCase<User, RegisterTeacherParams> {
  final AuthRepository repository;

  RegisterTeacher(this.repository);

  @override
  Future<Either<Failure, User>> call(RegisterTeacherParams params) async {
    return await repository.signUpTeacher(
      email: params.email,
      password: params.password,
      displayName: params.displayName,
      schoolCode: params.schoolCode,
      schoolName: params.schoolName,
      phoneNumber: params.phoneNumber,
    );
  }
}

/// 교사 회원가입에 필요한 파라미터
class RegisterTeacherParams extends Equatable {
  final String email;
  final String password;
  final String displayName;
  final String? schoolCode;
  final String? schoolName;
  final String? phoneNumber;

  const RegisterTeacherParams({
    required this.email,
    required this.password,
    required this.displayName,
    this.schoolCode,
    this.schoolName,
    this.phoneNumber,
  });

  @override
  List<Object?> get props => [
    email,
    password,
    displayName,
    schoolCode,
    schoolName,
    phoneNumber,
  ];

  @override
  String toString() =>
      'RegisterTeacherParams(email: $email, displayName: $displayName, schoolName: $schoolName)';
}
