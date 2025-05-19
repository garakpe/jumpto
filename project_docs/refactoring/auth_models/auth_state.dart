part of 'auth_cubit.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthUnauthenticated extends AuthState {}

class AuthAuthenticated extends AuthState {
  final BaseUser baseUser;
  final dynamic userDetail; // Teacher, Student, Admin 또는 null

  const AuthAuthenticated({
    required this.baseUser,
    this.userDetail,
  });

  bool get isTeacher => baseUser.isTeacher;
  bool get isStudent => baseUser.isStudent;
  bool get isAdmin => baseUser.isAdmin;

  // 역할별 타입 변환 편의 메서드
  Student? get student => userDetail is Student ? userDetail as Student : null;
  Teacher? get teacher => userDetail is Teacher ? userDetail as Teacher : null;
  Admin? get admin => userDetail is Admin ? userDetail as Admin : null;

  // 교사의 승인 상태 확인
  bool get isApproved => teacher?.isApproved ?? false;

  @override
  List<Object?> get props => [baseUser, userDetail];
}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}
