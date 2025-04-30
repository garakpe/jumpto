import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// 교사 회원가입 유스케이스
class RegisterTeacher implements UseCase<User, RegisterTeacherParams> {
  final AuthRepository repository;

  RegisterTeacher(this.repository);

  @override
  Future<Either<Failure, User>> call(RegisterTeacherParams params) async {
    return await repository.registerTeacher(
      params.email,
      params.password,
      params.name,
      params.schoolName,
    );
  }
}

/// 교사 회원가입 파라미터
class RegisterTeacherParams extends Equatable {
  final String email;
  final String password;
  final String name;
  final String schoolName;

  const RegisterTeacherParams({
    required this.email,
    required this.password,
    required this.name,
    required this.schoolName,
  });

  @override
  List<Object> get props => [email, password, name, schoolName];
}
