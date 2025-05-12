import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

/// 인증 레포지토리 구현체
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final user = await _remoteDataSource.getCurrentUser();
      return Right(user);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, User>> signUpTeacher({
    required String email,
    required String password,
    required String displayName,
    String? schoolCode,
    String? phoneNumber,
  }) async {
    try {
      final user = await _remoteDataSource.signUpTeacher(
        email: email,
        password: password,
        displayName: displayName,
        schoolCode: schoolCode,
        phoneNumber: phoneNumber,
      );
      return Right(user);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, User>> createStudentAccount({
    required String displayName,
    required String studentNum,
    required String classNum,
    required String gender,
    String? initialPassword,
  }) async {
    try {
      final user = await _remoteDataSource.createStudentAccount(
        displayName: displayName,
        studentNum: studentNum,
        classNum: classNum,
        gender: gender,
        initialPassword: initialPassword,
      );
      return Right(user);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _remoteDataSource.signInWithEmailPassword(
        email: email,
        password: password,
      );
      return Right(user);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, User>> signInStudent({
    required String schoolName,
    required String studentId,
    required String password,
  }) async {
    try {
      final user = await _remoteDataSource.signInStudent(
        schoolName: schoolName,
        studentId: studentId,
        password: password,
      );
      return Right(user);
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

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    try {
      await _remoteDataSource.sendPasswordResetEmail(email);
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await _remoteDataSource.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, void>> resetStudentPassword({
    required String studentId,
    required String newPassword,
  }) async {
    try {
      await _remoteDataSource.resetStudentPassword(
        studentId: studentId,
        newPassword: newPassword,
      );
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Stream<User?> get authStateChanges => _remoteDataSource.authStateChanges;

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
      case 'email-already-in-use':
        return '이미 사용 중인 이메일입니다.';
      case 'invalid-email':
        return '유효하지 않은 이메일 형식입니다.';
      case 'user-disabled':
        return '비활성화된 계정입니다.';
      case 'user-not-found':
        return '사용자를 찾을 수 없습니다.';
      case 'wrong-password':
        return '잘못된 비밀번호입니다.';
      case 'weak-password':
        return '비밀번호가 너무 약합니다.';
      case 'operation-not-allowed':
        return '이 작업은 허용되지 않습니다.';
      case 'requires-recent-login':
        return '보안 작업을 위해 최근 로그인이 필요합니다.';
      default:
        return '인증 오류가 발생했습니다 ($code)';
    }
  }
}
