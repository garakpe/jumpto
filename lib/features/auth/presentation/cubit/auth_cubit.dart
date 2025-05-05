import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/register_teacher.dart';
import '../../domain/usecases/sign_in_with_email_password.dart';
import '../../domain/usecases/sign_in_student.dart';
import '../../domain/usecases/sign_out.dart';

// Auth 상태
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

// 초기 상태
class AuthInitial extends AuthState {}

// 로딩 상태
class AuthLoading extends AuthState {}

// 인증됨 상태
class AuthAuthenticated extends AuthState {
  final User user;
  
  AuthAuthenticated(this.user);
  
  @override
  List<Object?> get props => [user];
}

// 인증되지 않음 상태
class AuthUnauthenticated extends AuthState {}

// 오류 상태
class AuthError extends AuthState {
  final String message;
  
  AuthError(this.message);
  
  @override
  List<Object?> get props => [message];
}

/// 인증 상태 관리 Cubit
class AuthCubit extends Cubit<AuthState> {
  final SignInWithEmailPassword _signInWithEmailPassword;
  final GetCurrentUser _getCurrentUser;
  final RegisterTeacher _registerTeacher;
  final SignInStudent _signInStudent;
  final SignOut _signOut;
  
  // 인증 상태 스트림 구독
  StreamSubscription? _authStateSubscription;
  
  AuthCubit({
    required SignInWithEmailPassword signInWithEmailPassword,
    required GetCurrentUser getCurrentUser,
    required RegisterTeacher registerTeacher,
    required SignInStudent signInStudent,
    required SignOut signOut,
  }) : _signInWithEmailPassword = signInWithEmailPassword,
       _getCurrentUser = getCurrentUser,
       _registerTeacher = registerTeacher,
       _signInStudent = signInStudent,
       _signOut = signOut,
       super(AuthInitial()) {
    checkAuthState();
  }
  
  /// 현재 인증 상태 확인
  Future<void> checkAuthState() async {
    emit(AuthLoading());
    
    final result = await _getCurrentUser(NoParams());
    
    result.fold(
      (failure) {
        emit(AuthError(_mapFailureToMessage(failure)));
        emit(AuthUnauthenticated());
      },
      (user) {
        if (user != null) {
          AppRouter.setCurrentUser(user);
          emit(AuthAuthenticated(user));
        } else {
          emit(AuthUnauthenticated());
        }
      },
    );
  }
  
  /// 현재 사용자 정보 재로드
  Future<void> checkCurrentUser() async {
    // 현재 상태가 인증됨이 아닌 경우 실행하지 않음
    if (state is! AuthAuthenticated) {
      return;
    }
    
    emit(AuthLoading());
    
    final result = await _getCurrentUser(NoParams());
    
    result.fold(
      (failure) {
        emit(AuthError(_mapFailureToMessage(failure)));
        // 상태 유지
        if (state is AuthAuthenticated) {
          emit(AuthAuthenticated((state as AuthAuthenticated).user));
        } else {
          emit(AuthUnauthenticated());
        }
      },
      (user) {
        if (user != null) {
          AppRouter.setCurrentUser(user);
          emit(AuthAuthenticated(user));
        } else {
          emit(AuthUnauthenticated());
        }
      },
    );
  }
  
  /// 이메일/비밀번호로 로그인
  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    
    final result = await _signInWithEmailPassword(
      SignInParams(email: email, password: password),
    );
    
    result.fold(
      (failure) {
        emit(AuthError(_mapFailureToMessage(failure)));
        emit(AuthUnauthenticated());
      },
      (user) {
        AppRouter.setCurrentUser(user);
        emit(AuthAuthenticated(user));
      },
    );
  }
  
  /// 교사 회원가입
  Future<void> registerTeacher({
    required String email,
    required String password,
    required String displayName,
    String? schoolId,
    String? phoneNumber,
  }) async {
    emit(AuthLoading());
    
    final result = await _registerTeacher(
      RegisterTeacherParams(
        email: email,
        password: password,
        displayName: displayName,
        schoolId: schoolId,
        phoneNumber: phoneNumber,
      ),
    );
    
    result.fold(
      (failure) {
        emit(AuthError(_mapFailureToMessage(failure)));
        emit(AuthUnauthenticated());
      },
      (user) {
        AppRouter.setCurrentUser(user);
        emit(AuthAuthenticated(user));
      },
    );
  }
  
  /// 학생 로그인
  Future<void> signInStudent({
    required String schoolId,
    required String studentNumber,
    required String password,
  }) async {
    emit(AuthLoading());
    
    final result = await _signInStudent(
      SignInStudentParams(
        schoolId: schoolId,
        studentNumber: studentNumber,
        password: password,
      ),
    );
    
    result.fold(
      (failure) {
        emit(AuthError(_mapFailureToMessage(failure)));
        emit(AuthUnauthenticated());
      },
      (user) {
        AppRouter.setCurrentUser(user);
        emit(AuthAuthenticated(user));
      },
    );
  }

  /// 로그아웃
  Future<void> signOut() async {
    emit(AuthLoading());
    
    final result = await _signOut(NoParams());
    
    result.fold(
      (failure) {
        emit(AuthError(_mapFailureToMessage(failure)));
      },
      (_) {
        AppRouter.setCurrentUser(null);
        emit(AuthUnauthenticated());
      },
    );
  }
  
  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
  
  /// 실패 유형에 따른 오류 메시지 반환
  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case AuthFailure:
        return (failure as AuthFailure).message;
      case ServerFailure:
        return (failure as ServerFailure).message;
      case NetworkFailure:
        return (failure as NetworkFailure).message;
      case CacheFailure:
        return (failure as CacheFailure).message;
      case UnknownFailure:
        return (failure as UnknownFailure).message;
      default:
        return '알 수 없는 오류가 발생했습니다.';
    }
  }
}