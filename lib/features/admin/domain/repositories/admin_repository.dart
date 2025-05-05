import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/user.dart';

/// 관리자 레포지토리 인터페이스
abstract class AdminRepository {
  /// 관리자 로그인
  Future<Either<Failure, User>> signInAdmin({
    required String username,
    required String password,
  });
  
  /// 승인 대기 중인 교사 목록 조회
  Future<Either<Failure, List<User>>> getPendingTeachers();
  
  /// 교사 계정 승인
  Future<Either<Failure, void>> approveTeacher(String teacherId);
  
  /// 교사 계정 거부/삭제
  Future<Either<Failure, void>> rejectTeacher(String teacherId);
  
  /// 모든 교사 목록 조회
  Future<Either<Failure, List<User>>> getAllTeachers();
  
  /// 관리자 로그아웃
  Future<Either<Failure, void>> signOut();
}