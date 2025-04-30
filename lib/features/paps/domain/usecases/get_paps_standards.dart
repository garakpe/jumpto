import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/fitness_factor.dart';
import '../entities/gender.dart';
import '../entities/paps_standard.dart';
import '../entities/school_level.dart';
import '../repositories/paps_repository.dart';

/// 팝스 기준표 조회 유스케이스
class GetPapsStandards implements UseCase<PapsStandard?, GetPapsStandardsParams> {
  final PapsRepository repository;
  
  GetPapsStandards(this.repository);
  
  @override
  Future<Either<Failure, PapsStandard?>> call(GetPapsStandardsParams params) async {
    return await repository.getPapsStandard(
      schoolLevel: params.schoolLevel,
      gradeNumber: params.gradeNumber,
      gender: params.gender,
      fitnessFactor: params.fitnessFactor,
      eventName: params.eventName,
    );
  }
}

/// 팝스 기준표 조회 파라미터
class GetPapsStandardsParams extends Equatable {
  final SchoolLevel schoolLevel;
  final int gradeNumber;
  final Gender gender;
  final FitnessFactor fitnessFactor;
  final String eventName;
  
  const GetPapsStandardsParams({
    required this.schoolLevel,
    required this.gradeNumber,
    required this.gender,
    required this.fitnessFactor,
    required this.eventName,
  });
  
  @override
  List<Object> get props => [
    schoolLevel, 
    gradeNumber, 
    gender, 
    fitnessFactor, 
    eventName
  ];
  
  @override
  String toString() => 'GetPapsStandardsParams(schoolLevel: $schoolLevel, grade: $gradeNumber, gender: $gender, fitnessFactor: $fitnessFactor, event: $eventName)';
}
