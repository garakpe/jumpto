import 'package:dartz/dartz.dart';

import '../../../../../core/error/failures.dart';
import '../entities/student.dart';

abstract class StudentRepository {
  /// 교사가 담당하는 학생 목록 조회
  Future<Either<Failure, List<Student>>> getStudentsByTeacher(String teacherId);

  /// 학생 일괄 업로드 (Excel/CSV)
  Future<Either<Failure, List<Student>>> uploadStudents({
    required List<Map<String, dynamic>> studentsData,
    required String teacherId,
    required String schoolCode,
    required String schoolName,
  });

  /// 학생 비밀번호 변경
  Future<Either<Failure, void>> changeStudentPassword({
    required String studentId,
    required String oldPassword,
    required String newPassword,
  });

  /// 학생 성별 업데이트
  Future<Either<Failure, void>> updateStudentGender({
    required String studentId,
    required String gender,
  });

  /// 학생 비밀번호 초기화 (교사 기능)
  Future<Either<Failure, void>> resetStudentPassword(String studentId);
}
