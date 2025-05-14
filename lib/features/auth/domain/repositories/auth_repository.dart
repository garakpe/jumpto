import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user.dart';

/// 인증 레포지토리 인터페이스
abstract class AuthRepository {
  /// 현재 인증된 사용자 가져오기
  Future<Either<Failure, User?>> getCurrentUser();

  /// 이메일/비밀번호로 교사 회원가입
  Future<Either<Failure, User>> signUpTeacher({
    required String email,
    required String password,
    required String displayName,
    String? schoolCode,
    String? schoolName,
    String? phoneNumber,
  });

  /// 학생 계정 생성 (교사에 의해)
  Future<Either<Failure, User>> createStudentAccount({
    required String displayName,
    required String grade,       // 학년 추가
    required String classNum,
    required String studentNum,
    required String gender,
    String? initialPassword,
  });

  /// 이메일/비밀번호로 로그인
  Future<Either<Failure, User>> signInWithEmailPassword({
    required String email,
    required String password,
  });

  /// 학번/비밀번호로 학생 로그인
  Future<Either<Failure, User>> signInStudent({
    required String schoolName,
    required String studentId,
    required String password,
  });

  /// 로그아웃
  Future<Either<Failure, void>> signOut();

  /// 비밀번호 재설정 이메일 전송
  Future<Either<Failure, void>> sendPasswordResetEmail(String email);

  /// 비밀번호 변경
  Future<Either<Failure, void>> changePassword({
    required String oldPassword,
    required String newPassword,
  });

  /// 학생 비밀번호 초기화 (교사에 의해)
  Future<Either<Failure, void>> resetStudentPassword({
    required String studentId,
    required String newPassword,
  });

  /// 인증 상태 스트림
  Stream<User?> get authStateChanges;
}
