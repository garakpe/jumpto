import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/school.dart';

/// 학교 정보 레포지토리 인터페이스
abstract class SchoolRepository {
  /// 지역 목록 조회
  /// 
  /// 시스템에 등록된 모든 지역(도/시) 목록을 반환합니다.
  Future<Either<Failure, List<String>>> getRegions();
  
  /// 특정 지역의 학교 목록 조회
  /// 
  /// [region] 지역에 있는 모든 학교 목록을 반환합니다.
  Future<Either<Failure, List<School>>> getSchoolsByRegion(String region);
  
  /// 학교 이름으로 검색
  /// 
  /// [region] 지역에서 [query]와 일치하는 학교 이름을 검색합니다.
  /// [query]가 비어있으면 해당 지역의 모든 학교를 반환합니다.
  Future<Either<Failure, List<School>>> searchSchools(String region, String query);
}
