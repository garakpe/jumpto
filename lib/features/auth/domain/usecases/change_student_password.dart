import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/student_repository.dart';

/// 학생 비밀번호 변경 파라미터
class ChangeStudentPasswordParams extends Equatable {
  final String studentId;
  final String oldPassword;
  final String newPassword;

  const ChangeStudentPasswordParams({
    required this.studentId,
    required this.oldPassword,
    required this.newPassword,
  });

  @override
  List<Object> get props => [studentId, oldPassword, newPassword];
}

/// 학생 비밀번호 변경 유스케이스
///
/// 학생이 마이페이지에서 자신의 비밀번호를 변경하는 기능을 수행합니다.
class ChangeStudentPassword implements UseCase<void, ChangeStudentPasswordParams> {
  final StudentRepository repository;

  ChangeStudentPassword(this.repository);

  @override
  Future<Either<Failure, void>> call(ChangeStudentPasswordParams params) async {
    return await repository.resetStudentPassword(
      params.studentId,
      params.newPassword,
    );
  }
}
