import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_data_source.dart';

/// 관리자 레포지토리 구현체
class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource _remoteDataSource;
  
  AdminRepositoryImpl(this._remoteDataSource);
  
  @override
  Future<Either<Failure, User>> signInAdmin({
    required String username,
    required String password,
  }) async {
    try {
      final user = await _remoteDataSource.signInAdmin(
        username: username,
        password: password,
      );
      return Right(user);
    } catch (e) {
      return Left(_handleError(e));
    }
  }
  
  @override
  Future<Either<Failure, List<User>>> getPendingTeachers() async {
    try {
      final teachers = await _remoteDataSource.getPendingTeachers();
      return Right(teachers);
    } catch (e) {
      return Left(_handleError(e));
    }
  }
  
  @override
  Future<Either<Failure, void>> approveTeacher(String teacherId) async {
    try {
      await _remoteDataSource.approveTeacher(teacherId);
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }
  
  @override
  Future<Either<Failure, void>> rejectTeacher(String teacherId) async {
    try {
      await _remoteDataSource.rejectTeacher(teacherId);
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }
  
  @override
  Future<Either<Failure, List<User>>> getAllTeachers() async {
    try {
      final teachers = await _remoteDataSource.getAllTeachers();
      return Right(teachers);
    } catch (e) {
      return Left(_handleError(e));
    }
  }
  
  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _remoteDataSource.signOut();
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }
  
  /// 오류 처리
  Failure _handleError(dynamic exception) {
    if (exception is firebase_auth.FirebaseAuthException) {
      return AuthFailure(
        message: _getAuthErrorMessage(exception.code),
        code: int.tryParse(exception.code) ?? 0,
      );
    } else {
      return UnknownFailure(message: exception.toString());
    }
  }
  
  /// Firebase Auth 오류 메시지
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'invalid-credential':
        return '로그인 정보가 올바르지 않습니다.';
      case 'user-not-found':
        return '사용자를 찾을 수 없습니다.';
      case 'wrong-password':
        return '잘못된 비밀번호입니다.';
      case 'invalid-email':
        return '유효하지 않은 이메일 형식입니다.';
      case 'user-disabled':
        return '비활성화된 계정입니다.';
      default:
        return '인증 오류가 발생했습니다 ($code)';
    }
  }
}