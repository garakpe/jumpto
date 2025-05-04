import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/teacher_settings.dart';

/// 교사 설정 레포지토리 인터페이스
abstract class TeacherSettingsRepository {
  /// 교사 ID로 교사 설정 조회
  /// 
  /// [teacherId] 교사 ID
  /// 
  /// 성공 시 [TeacherSettings] 반환, 실패 시 [Failure] 반환
  Future<Either<Failure, TeacherSettings>> getTeacherSettings(String teacherId);

  /// 교사 설정 저장
  /// 
  /// [settings] 저장할 교사 설정
  /// 
  /// 성공 시 [TeacherSettings] 반환, 실패 시 [Failure] 반환
  Future<Either<Failure, TeacherSettings>> saveTeacherSettings(TeacherSettings settings);
}