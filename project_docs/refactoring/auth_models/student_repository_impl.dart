import 'package:dartz/dartz.dart';

import '../../../../../core/error/failures.dart';
import '../../domain/entities/student.dart';
import '../../domain/repositories/student_repository.dart';
import '../datasources/student_remote_data_source.dart';

class StudentRepositoryImpl implements StudentRepository {
  final StudentRemoteDataSource remoteDataSource;

  StudentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Student>>> getStudentsByTeacher(String teacherId) async {
    try {
      return await remoteDataSource.getStudentsByTeacher(teacherId);
    } catch (e) {
      return Left(ServerFailure(message: '학생 목록을 가져오는 중 오류가 발생했습니다.'));
    }
  }

  @override
  Future<Either<Failure, List<Student>>> uploadStudents({
    required List<Map<String, dynamic>> studentsData,
    required String teacherId,
    required String schoolCode,
    required String schoolName,
  }) async {
    try {
      return await remoteDataSource.uploadStudents(
        studentsData: studentsData,
        teacherId: teacherId,
        schoolCode: schoolCode,
        schoolName: schoolName,
      );
    } catch (e) {
      return Left(ServerFailure(message: '학생 업로드 중 오류가 발생했습니다.'));
    }
  }

  @override
  Future<Either<Failure, void>> changeStudentPassword({
    required String studentId,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      return await remoteDataSource.changeStudentPassword(
        studentId: studentId,
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
    } catch (e) {
      return Left(ServerFailure(message: '비밀번호 변경 중 오류가 발생했습니다.'));
    }
  }

  @override
  Future<Either<Failure, void>> updateStudentGender({
    required String studentId,
    required String gender,
  }) async {
    try {
      return await remoteDataSource.updateStudentGender(
        studentId: studentId,
        gender: gender,
      );
    } catch (e) {
      return Left(ServerFailure(message: '성별 정보 업데이트 중 오류가 발생했습니다.'));
    }
  }

  @override
  Future<Either<Failure, void>> resetStudentPassword(String studentId) async {
    try {
      return await remoteDataSource.resetStudentPassword(studentId);
    } catch (e) {
      return Left(ServerFailure(message: '비밀번호 초기화 중 오류가 발생했습니다.'));
    }
  }
}
