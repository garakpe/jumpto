import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/user.dart';

/// 관리자 상태
abstract class AdminState extends Equatable {
  const AdminState();
  
  @override
  List<Object?> get props => [];
}

/// 초기 상태
class AdminInitial extends AdminState {
  const AdminInitial();
}

/// 로딩 상태
class AdminLoading extends AdminState {
  const AdminLoading();
}

/// 인증 성공 상태
class AdminAuthenticated extends AdminState {
  final User admin;
  
  const AdminAuthenticated(this.admin);
  
  @override
  List<Object?> get props => [admin];
}

/// 교사 목록 로드 성공 상태
class TeachersLoaded extends AdminState {
  final List<User> teachers;
  
  const TeachersLoaded(this.teachers);
  
  @override
  List<Object?> get props => [teachers];
}

/// 교사 승인 완료 상태
class TeacherApproved extends AdminState {
  final String teacherId;
  
  const TeacherApproved(this.teacherId);
  
  @override
  List<Object?> get props => [teacherId];
}

/// 교사 거부 완료 상태
class TeacherRejected extends AdminState {
  final String teacherId;
  
  const TeacherRejected(this.teacherId);
  
  @override
  List<Object?> get props => [teacherId];
}

/// 오류 상태
class AdminError extends AdminState {
  final String message;
  
  const AdminError(this.message);
  
  @override
  List<Object?> get props => [message];
}