part of 'school_cubit.dart';

/// 학교 상태 기본 클래스
abstract class SchoolState extends Equatable {
  const SchoolState();
  
  @override
  List<Object> get props => [];
}

/// 초기 상태
class SchoolInitial extends SchoolState {}

/// 로딩 중 상태
class SchoolLoading extends SchoolState {}

/// 지역 목록 로드 완료 상태
class RegionsLoaded extends SchoolState {
  final List<String> regions;
  
  const RegionsLoaded({required this.regions});
  
  @override
  List<Object> get props => [regions];
}

/// 학교 목록 로드 완료 상태
class SchoolsLoaded extends SchoolState {
  final String region;
  final List<School> schools;
  final List<School> filteredSchools;
  final List<String> allRegions; // 전체 지역 목록
  
  const SchoolsLoaded({
    required this.region,
    required this.schools,
    required this.filteredSchools,
    this.allRegions = const [], // 기본값은 빈 리스트
  });
  
  @override
  List<Object> get props => [region, schools, filteredSchools, allRegions];
}

/// 오류 상태
class SchoolError extends SchoolState {
  final String message;
  
  const SchoolError({required this.message});
  
  @override
  List<Object> get props => [message];
}
