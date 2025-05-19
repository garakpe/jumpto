import 'package:dartz/dartz.dart';

import '../../../../../core/error/failures.dart';
import '../../domain/entities/base_user.dart';
import '../../domain/entities/teacher.dart';
import '../../domain/entities/student.dart';
import '../../domain/entities/admin.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<BaseUser?> getCurrentUser() async {
    try {
      return await remoteDataSource.getCurrentUser();
    } catch (e) {
      print('AuthRepository getCurrentUser 에러: $e');
      return null;
    }
  }

  @override
  Future<Either<Failure, dynamic>> getCurrentUserWithDetails() async {
    try {
      final result = await remoteDataSource.getCurrentUserWithDetails();
      return result;
    } catch (e) {
      print('AuthRepository getCurrentUserWithDetails 에러: $e');
      return Left(ServerFailure(message: '사용자 정보를 가져오는 중 오류가 발생했습니다.'));
    }
  }

  @override
  Future<Either<Failure, Teacher>> signUpTeacher({
    required String email,
    required String password,
    required String displayName,
    required String schoolCode,
    required String schoolName,
    String? phoneNumber,
  }) async {
    try {
      return await remoteDataSource.signUpTeacher(
        email: email,
        password: password,
        displayName: displayName,
        schoolCode: schoolCode,
        schoolName: schoolName,
        phoneNumber: phoneNumber,
      );
    } catch (e) {
      return Left(ServerFailure(message: '회원가입 중 오류가 발생했습니다.'));
    }
  }

  @override
  Future<Either<Failure, BaseUser>> signInWithEmailPassword({
    required String email, 
    required String password,
  }) async {
    try {
      return await remoteDataSource.signInWithEmailPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      return Left(ServerFailure(message: '로그인 중 오류가 발생했습니다.'));
    }
  }

  @override
  Future<Either<Failure, BaseUser>> signInStudent({
    required String schoolName, 
    required String studentId, 
    required String password,
  }) async {
    try {
      return await remoteDataSource.signInStudent(
        schoolName: schoolName,
        studentId: studentId,
        password: password,
      );
    } catch (e) {
      return Left(ServerFailure(message: '학생 로그인 중 오류가 발생했습니다.'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: '로그아웃 중 오류가 발생했습니다.'));
    }
  }

  @override
  Future<Either<Failure, Admin>> signInAdmin({
    required String username,
    required String password,
  }) async {
    try {
      return await remoteDataSource.signInAdmin(
        username: username,
        password: password,
      );
    } catch (e) {
      return Left(ServerFailure(message: '관리자 로그인 중 오류가 발생했습니다.'));
    }
  }

  @override
  Future<Either<Failure, void>> approveTeacher(String teacherId) async {
    try {
      return await remoteDataSource.approveTeacher(teacherId);
    } catch (e) {
      return Left(ServerFailure(message: '교사 승인 중 오류가 발생했습니다.'));
    }
  }
}
