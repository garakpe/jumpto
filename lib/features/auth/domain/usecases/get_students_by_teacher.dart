import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/student.dart';
import '../repositories/student_repository.dart';

/// 교사별 학생 목록 조회 파라미터
class GetStudentsByTeacherParams extends Equatable {
  final String teacherId;

  const GetStudentsByTeacherParams({
    required this.teacherId,
  });

  @override
  List<Object?> get props => [teacherId];
}

/// 교사별 학생 목록 조회 유스케이스
///
/// 특정 교사가 관리하는 학생 목록을 조회합니다.
class GetStudentsByTeacher implements UseCase<List<Student>, GetStudentsByTeacherParams> {
  final StudentRepository repository;

  GetStudentsByTeacher(this.repository);

  @override
  Future<Either<Failure, List<Student>>> call(GetStudentsByTeacherParams params) {
    return repository.getStudentsByTeacherId(params.teacherId);
  }
}
