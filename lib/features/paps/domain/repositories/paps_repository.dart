import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/fitness_factor.dart';
import '../entities/gender.dart';
import '../entities/paps_record.dart';
import '../entities/paps_standard.dart';
import '../entities/paps_standards_collection.dart';
import '../entities/school_level.dart';

/// 팝스 관련 데이터 접근을 위한 레포지토리 인터페이스
abstract class PapsRepository {
  /// 모든 팝스 기준표 데이터 가져오기
  Future<Either<Failure, PapsStandardsCollection>> getAllPapsStandards();
  
  /// 특정 조건의 팝스 기준표 가져오기
  Future<Either<Failure, PapsStandard?>> getPapsStandard({
    required SchoolLevel schoolLevel,
    required int gradeNumber,
    required Gender gender,
    required FitnessFactor fitnessFactor,
    required String eventName,
  });
  
  /// 학생의 팝스 측정 기록 저장하기
  Future<Either<Failure, PapsRecord>> savePapsRecord(PapsRecord record);
  
  /// 학생의 모든 팝스 측정 기록 가져오기
  Future<Either<Failure, List<PapsRecord>>> getStudentPapsRecords(String studentId);
  
  /// 학생의 특정 체력요인에 대한 최신 팝스 측정 기록 가져오기
  Future<Either<Failure, PapsRecord?>> getLatestStudentPapsRecord({
    required String studentId, 
    required FitnessFactor fitnessFactor,
  });
  
  /// 특정 반의 모든 학생의 팝스 측정 기록 가져오기
  Future<Either<Failure, Map<String, List<PapsRecord>>>> getClassPapsRecords({
    required String teacherId,
    required String className,
  });
}
