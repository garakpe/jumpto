import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/student.dart';
import '../repositories/student_repository.dart';

/// 학생 일괄 업로드 유스케이스 파라미터
class UploadStudentsParams extends Equatable {
  final List<Student> students;

  const UploadStudentsParams({
    required this.students,
  });

  @override
  List<Object?> get props => [students];
}

/// 학생 일괄 업로드 유스케이스
///
/// 교사가 학생 정보를 일괄 업로드하는 기능을 수행합니다.
class UploadStudents implements UseCase<List<Student>, UploadStudentsParams> {
  final StudentRepository repository;

  UploadStudents(this.repository);

  @override
  Future<Either<Failure, List<Student>>> call(UploadStudentsParams params) {
    return repository.uploadStudents(params.students);
  }
}
