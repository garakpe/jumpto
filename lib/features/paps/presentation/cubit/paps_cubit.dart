import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/index.dart';
import '../../domain/usecases/calculate_paps_grade.dart';
import '../../domain/usecases/get_paps_standards.dart';
import '../../domain/usecases/get_student_paps_records.dart';
import '../../domain/usecases/save_paps_record.dart';

// PAPS 상태
abstract class PapsState extends Equatable {
  @override
  List<Object?> get props => [];
}

// 초기 상태
class PapsInitial extends PapsState {}

// 로딩 상태
class PapsLoading extends PapsState {}

// 기준표 로드 성공 상태
class PapsStandardsLoaded extends PapsState {
  final PapsStandard standard;
  
  PapsStandardsLoaded(this.standard);
  
  @override
  List<Object?> get props => [standard];
}

// 측정 결과 계산 성공 상태
class PapsMeasurementCalculated extends PapsState {
  final int grade;
  final int score;
  
  PapsMeasurementCalculated({
    required this.grade,
    required this.score,
  });
  
  @override
  List<Object?> get props => [grade, score];
}

// 측정 기록 저장 성공 상태
class PapsRecordSaved extends PapsState {
  final PapsRecord record;
  
  PapsRecordSaved(this.record);
  
  @override
  List<Object?> get props => [record];
}

// 학생 측정 기록 로드 성공 상태
class PapsStudentRecordsLoaded extends PapsState {
  final List<PapsRecord> records;
  
  PapsStudentRecordsLoaded(this.records);
  
  @override
  List<Object?> get props => [records];
}

// 오류 상태
class PapsError extends PapsState {
  final String message;
  
  PapsError(this.message);
  
  @override
  List<Object?> get props => [message];
}

/// 팝스 관련 상태 관리 Cubit
class PapsCubit extends Cubit<PapsState> {
  final GetPapsStandards _getPapsStandards;
  final CalculatePapsGrade _calculatePapsGrade;
  final SavePapsRecord _savePapsRecord;
  final GetStudentPapsRecords _getStudentPapsRecords;
  
  PapsCubit({
    required GetPapsStandards getPapsStandards,
    required CalculatePapsGrade calculatePapsGrade,
    required SavePapsRecord savePapsRecord,
    required GetStudentPapsRecords getStudentPapsRecords,
  }) : _getPapsStandards = getPapsStandards,
       _calculatePapsGrade = calculatePapsGrade,
       _savePapsRecord = savePapsRecord,
       _getStudentPapsRecords = getStudentPapsRecords,
       super(PapsInitial());
  
  /// 팝스 기준표 가져오기
  Future<void> loadPapsStandard({
    required SchoolLevel schoolLevel,
    required int gradeNumber,
    required Gender gender,
    required FitnessFactor fitnessFactor,
    required String eventName,
  }) async {
    emit(PapsLoading());
    
    final result = await _getPapsStandards(
      GetPapsStandardsParams(
        schoolLevel: schoolLevel,
        gradeNumber: gradeNumber,
        gender: gender,
        fitnessFactor: fitnessFactor,
        eventName: eventName,
      ),
    );
    
    result.fold(
      (failure) => emit(PapsError(_mapFailureToMessage(failure))),
      (standard) {
        if (standard != null) {
          emit(PapsStandardsLoaded(standard));
        } else {
          emit(PapsError('팝스 기준표를 찾을 수 없습니다.'));
        }
      },
    );
  }
  
  /// 측정값에 대한 등급 및 점수 계산
  Future<void> calculateGradeAndScore({
    required SchoolLevel schoolLevel,
    required int gradeNumber,
    required Gender gender,
    required FitnessFactor fitnessFactor,
    required String eventName,
    required double value,
  }) async {
    emit(PapsLoading());
    
    final result = await _calculatePapsGrade.calculate(
      schoolLevel: schoolLevel,
      gradeNumber: gradeNumber,
      gender: gender,
      fitnessFactor: fitnessFactor,
      eventName: eventName,
      value: value,
    );
    
    if (result != null) {
      emit(PapsMeasurementCalculated(
        grade: result['grade'] is int ? result['grade'] : 5,
        score: result['score'] as int,
      ));
    } else {
      emit(PapsError('기준표에 해당하는 등급과 점수를 계산할 수 없습니다.'));
    }
  }
  
  /// 측정 기록 저장
  Future<void> savePapsRecord(PapsRecord record) async {
    emit(PapsLoading());
    
    final result = await _savePapsRecord(PapsRecordParams(record: record));
    
    result.fold(
      (failure) => emit(PapsError(_mapFailureToMessage(failure))),
      (savedRecord) => emit(PapsRecordSaved(savedRecord)),
    );
  }
  
  /// 학생 측정 기록 가져오기
  Future<void> getStudentRecords(String studentId) async {
    emit(PapsLoading());
    
    final result = await _getStudentPapsRecords(StudentIdParams(studentId: studentId));
    
    result.fold(
      (failure) => emit(PapsError(_mapFailureToMessage(failure))),
      (records) => emit(PapsStudentRecordsLoaded(records)),
    );
  }
  
  /// 실패 유형에 따른 오류 메시지 반환
  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return '서버 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.';
      case CacheFailure:
        return '로컬 데이터 로드 중 오류가 발생했습니다.';
      case NetworkFailure:
        return '네트워크 연결을 확인해 주세요.';
      default:
        return '알 수 없는 오류가 발생했습니다.';
    }
  }
}
