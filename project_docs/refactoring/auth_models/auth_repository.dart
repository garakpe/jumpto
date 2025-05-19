import 'package:dartz/dartz.dart';

import '../../../../../core/error/failures.dart';
import '../entities/admin.dart';
import '../entities/base_user.dart';
import '../entities/teacher.dart';

abstract class AuthRepository {
  /// 현재 인증된 사용자 정보를 가져온다.
  Future<BaseUser?> getCurrentUser();
  
  /// 현재 인증된 사용자의 세부 정보를 가져온다 (역할별로 다른 타입 반환).
  Future<Either<Failure, dynamic>> getCurrentUserWithDetails();

  /// 이메일/비밀번호로 교사 회원 가입
  Future<Either<Failure, Teacher>> signUpTeacher({
    required String email,
    required String password,
    required String displayName,
    required String schoolCode,
    required String schoolName,
    String? phoneNumber,
  });

  /// 이메일/비밀번호로 로그인 (교사용)
  Future<Either<Failure, BaseUser>> signInWithEmailPassword({
    required String email, 
    required String password,
  });

  /// 학교/학번으로 학생 로그인
  Future<Either<Failure, BaseUser>> signInStudent({
    required String schoolName, 
    required String studentId, 
    required String password,
  });

  /// 사용자 로그아웃
  Future<Either<Failure, void>> signOut();

  /// 관리자 로그인
  Future<Either<Failure, Admin>> signInAdmin({
    required String username,
    required String password,
  });

  /// 교사 계정 승인
  Future<Either<Failure, void>> approveTeacher(String teacherId);
}
