import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/school.dart';
import '../../domain/usecases/get_regions.dart';
import '../../domain/usecases/get_schools_by_region.dart';
import '../../domain/usecases/search_schools.dart';

part 'school_state.dart';

/// 학교 데이터 관리 Cubit
class SchoolCubit extends Cubit<SchoolState> {
  final GetRegions getRegions;
  final GetSchoolsByRegion getSchoolsByRegion;
  final SearchSchools searchSchools;

  SchoolCubit({
    required this.getRegions,
    required this.getSchoolsByRegion,
    required this.searchSchools,
  }) : super(SchoolInitial());

  /// 지역 목록 반환 (블록하지 않는 버전)
  Future<List<String>> getRegionsList() async {
    final result = await getRegions(NoParams());
    return result.fold(
      (failure) => [],
      (regions) => regions,
    );
  }

  /// 지역 목록 로드
  Future<void> loadRegions() async {
    emit(SchoolLoading());

    final result = await getRegions(NoParams());

    result.fold(
      (failure) => emit(SchoolError(message: _mapFailureToMessage(failure))),
      (regions) => emit(RegionsLoaded(regions: regions)),
    );
  }

  /// 특정 지역의 학교 목록 로드
  Future<void> loadSchoolsByRegion(String region) async {
    emit(SchoolLoading());

    // 학교 목록과 지역 목록을 모두 가져와야 함
    final schoolsResult = await getSchoolsByRegion(RegionParams(region: region));
    final regionsResult = await getRegions(NoParams());
    
    // 두 결과를 합쳐서 처리
    if (schoolsResult.isLeft() || regionsResult.isLeft()) {
      // 에러가 발생한 경우 - 학교 로드만 실패해도 에러 처리
      emit(SchoolError(message: _mapFailureToMessage(
        schoolsResult.fold(
          (failure) => failure, 
          (_) => regionsResult.fold((failure) => failure, (_) => CacheFailure(message: ''))
        )
      )));
    } else {
      // 둘 다 성공한 경우
      schoolsResult.fold(
        (failure) => emit(SchoolError(message: _mapFailureToMessage(failure))),
        (schools) => regionsResult.fold(
          (failure) => emit(SchoolError(message: _mapFailureToMessage(failure))),
          (regions) => emit(SchoolsLoaded(
            region: region,
            schools: schools,
            filteredSchools: schools,
            allRegions: regions, // 전체 지역 목록 전달
          )),
        ),
      );
    }
  }

  /// 학교 검색
  Future<void> searchSchoolsByName(String region, String query) async {
    if (state is! SchoolsLoaded) {
      await loadSchoolsByRegion(region);
    }

    final currentState = state as SchoolsLoaded;
    
    if (query.isEmpty) {
      emit(SchoolsLoaded(
        region: currentState.region,
        schools: currentState.schools,
        filteredSchools: currentState.schools,
        allRegions: currentState.allRegions, // 전체 지역 목록 유지
      ));
      return;
    }

    // 문자열 비교 시 대소문자 구분 없이 검색
    final filteredSchools = currentState.schools
        .where((school) => school.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    emit(SchoolsLoaded(
      region: currentState.region,
      schools: currentState.schools,
      filteredSchools: filteredSchools,
      allRegions: currentState.allRegions, // 전체 지역 목록 유지
    ));
  }

  /// 실패 타입에 따른 메시지 반환
  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return failure.message;
      case CacheFailure:
        return failure.message;
      default:
        return '알 수 없는 오류가 발생했습니다.';
    }
  }
}