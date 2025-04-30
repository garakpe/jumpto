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
  
  // 인증 상태 스트림 구독
  StreamSubscription? _authStateSubscription;
  
  AuthCubit({
    required SignInWithEmailPassword signInWithEmailPassword,
    required GetCurrentUser getCurrentUser,
    required RegisterTeacher registerTeacher,
  }) : _signInWithEmailPassword = signInWithEmailPassword,
       _getCurrentUser = getCurrentUser,
       _registerTeacher = registerTeacher,
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
  }) async {
    emit(AuthLoading());
    
    final result = await _registerTeacher(
      RegisterTeacherParams(
        email: email,
        password: password,
        displayName: displayName,
        schoolId: schoolId,
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
    
    // 로그아웃 로직 추가 예정
    AppRouter.setCurrentUser(null);
    emit(AuthUnauthenticated());
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
        return failure.message;
      case ServerFailure:
        return '서버 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.';
      case NetworkFailure:
        return '네트워크 연결을 확인해 주세요.';
      default:
        return '알 수 없는 오류가 발생했습니다.';
    }
  }
}
