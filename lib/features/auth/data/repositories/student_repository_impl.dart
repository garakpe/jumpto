import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/student.dart';
import '../../domain/repositories/student_repository.dart';
import '../datasources/student_remote_datasource.dart';
import '../models/student_model.dart';

/// 학생 레포지토리 구현체
class StudentRepositoryImpl implements StudentRepository {
  final StudentRemoteDataSource remoteDataSource;

  StudentRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<Student>>> getStudentsByTeacherId(String teacherId) async {
    try {
      final students = await remoteDataSource.getStudentsByTeacherId(teacherId);
      return Right(students);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: '학생 목록 조회 중 오류가 발생했습니다.'));
    }
  }

  @override
  Future<Either<Failure, List<Student>>> getStudentsBySchoolId(String schoolId) async {
    try {
      final students = await remoteDataSource.getStudentsBySchoolId(schoolId);
      return Right(students);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: '학교 학생 목록 조회 중 오류가 발생했습니다.'));
    }
  }

  @override
  Future<Either<Failure, List<Student>>> getStudentsByClass(String teacherId, String grade, String classNum) async {
    try {
      final students = await remoteDataSource.getStudentsByClass(teacherId, grade, classNum);
      return Right(students);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: '학급 학생 목록 조회 중 오류가 발생했습니다.'));
    }
  }

  @override
  Future<Either<Failure, Student>> createStudent(Student student) async {
    try {
      final studentModel = StudentModel.fromEntity(student);
      final createdStudent = await remoteDataSource.createStudent(studentModel);
      return Right(createdStudent);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: '학생 생성 중 오류가 발생했습니다.'));
    }
  }

  @override
  Future<Either<Failure, List<Student>>> uploadStudents(List<Student> students) async {
    try {
      final studentModels = students.map((e) => StudentModel.fromEntity(e)).toList();
      final createdStudents = await remoteDataSource.uploadStudents(studentModels);
      return Right(createdStudents);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: '학생 일괄 업로드 중 오류가 발생했습니다.'));
    }
  }

  @override
  Future<Either<Failure, Student>> updateStudent(Student student) async {
    try {
      final studentModel = StudentModel.fromEntity(student);
      final updatedStudent = await remoteDataSource.updateStudent(studentModel);
      return Right(updatedStudent);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: '학생 정보 업데이트 중 오류가 발생했습니다.'));
    }
  }

  @override
  Future<Either<Failure, void>> resetStudentPassword(String studentId, String newPassword) async {
    try {
      await remoteDataSource.resetStudentPassword(studentId, newPassword);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: '비밀번호 재설정 중 오류가 발생했습니다.'));
    }
  }

  @override
  Future<Either<Failure, Student>> getStudentById(String id) async {
    try {
      final student = await remoteDataSource.getStudentById(id);
      return Right(student);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: '학생 조회 중 오류가 발생했습니다.'));
    }
  }

  @override
  Future<Either<Failure, Student>> getStudentByStudentId(String studentId) async {
    try {
      final student = await remoteDataSource.getStudentByStudentId(studentId);
      return Right(student);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: '학생 조회 중 오류가 발생했습니다.'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteStudent(String id) async {
    try {
      await remoteDataSource.deleteStudent(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: '학생 삭제 중 오류가 발생했습니다.'));
    }
  }
  
  @override
  Future<Either<Failure, void>> updateStudentGender(String gender) async {
    try {
      await remoteDataSource.updateStudentGender(gender);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: '성별 업데이트 중 오류가 발생했습니다.'));
    }
  }
}
