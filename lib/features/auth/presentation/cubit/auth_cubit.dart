import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
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
    _initAuthState();
  }
  
  /// 초기 인증 상태 설정
  Future<void> _initAuthState() async {
    try {
      debugPrint('초기 인증 상태 확인 중...');
      emit(AuthLoading());
      await Future.delayed(const Duration(milliseconds: 200));
      emit(AuthUnauthenticated());
      // 약간의 지연 후 실제 인증 상태 확인
      Timer(const Duration(milliseconds: 300), () => checkAuthState());
    } catch (e) {
      debugPrint('초기 인증 상태 설정 오류: $e');
      emit(AuthUnauthenticated());
    }
  }

  /// 현재 인증 상태 확인
  Future<void> checkAuthState() async {
    try {
      emit(AuthLoading());

      final result = await _getCurrentUser(NoParams());

      result.fold(
        (failure) {
          debugPrint('인증 상태 확인 중 실패: ${failure.message}');
          emit(AuthError(_mapFailureToMessage(failure)));
          emit(AuthUnauthenticated());
        },
        (user) {
          if (user != null) {
            debugPrint('인증된 사용자: ${user.displayName}');
            
            // 로그아웃 직후에 호출되는 경우 등 특별 처리 
            if (state is AuthUnauthenticated) {
              Future.delayed(const Duration(milliseconds: 100), () {
                AppRouter.setCurrentUser(user);
                emit(AuthAuthenticated(user));
              });
            } else {
              AppRouter.setCurrentUser(user);
              emit(AuthAuthenticated(user));
            }
          } else {
            debugPrint('인증되지 않은 상태');
            AppRouter.setCurrentUser(null);
            emit(AuthUnauthenticated());
          }
        },
      );
    } catch (e) {
      debugPrint('인증 상태 확인 중 예외 발생: $e');
      emit(AuthError('인증 상태 확인 중 오류가 발생했습니다.'));
      emit(AuthUnauthenticated());
    }
  }

  /// 현재 사용자 정보 재로드
  Future<void> checkCurrentUser() async {
    try {
      // 현재 상태가 인증됨이 아닌 경우 실행하지 않음
      if (state is! AuthAuthenticated) {
        return;
      }

      emit(AuthLoading());

      final result = await _getCurrentUser(NoParams());

      result.fold(
        (failure) {
          debugPrint('사용자 정보 재로드 중 실패: ${failure.message}');
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
            debugPrint('사용자 정보 재로드 성공: ${user.displayName}');
            AppRouter.setCurrentUser(user);
            emit(AuthAuthenticated(user));
          } else {
            debugPrint('사용자 정보가 없음');
            AppRouter.setCurrentUser(null);
            emit(AuthUnauthenticated());
          }
        },
      );
    } catch (e) {
      debugPrint('사용자 정보 재로드 중 예외 발생: $e');
      emit(AuthError('사용자 정보 재로드 중 오류가 발생했습니다.'));
      if (state is AuthAuthenticated) {
        emit(AuthAuthenticated((state as AuthAuthenticated).user));
      } else {
        emit(AuthUnauthenticated());
      }
    }
  }

  /// 이메일/비밀번호로 로그인
  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      emit(AuthLoading());

      final result = await _signInWithEmailPassword(
        SignInParams(email: email, password: password),
      );

      result.fold(
        (failure) {
          debugPrint('이메일 로그인 실패: ${failure.message}');
          emit(AuthError(_mapFailureToMessage(failure)));
          emit(AuthUnauthenticated());
        },
        (user) {
          debugPrint('이메일 로그인 성공: ${user.displayName}');
          AppRouter.setCurrentUser(user);
          emit(AuthAuthenticated(user));
        },
      );
    } catch (e) {
      debugPrint('이메일 로그인 중 예외 발생: $e');
      emit(AuthError('로그인 중 오류가 발생했습니다.'));
      emit(AuthUnauthenticated());
    }
  }

  /// 교사 회원가입
  Future<void> registerTeacher({
    required String email,
    required String password,
    required String displayName,
    String? schoolCode,
    String? schoolName,
    String? phoneNumber,
  }) async {
    try {
      emit(AuthLoading());

      final result = await _registerTeacher(
        RegisterTeacherParams(
          email: email,
          password: password,
          displayName: displayName,
          schoolCode: schoolCode,
          schoolName: schoolName,
          phoneNumber: phoneNumber,
        ),
      );

      result.fold(
        (failure) {
          debugPrint('교사 회원가입 실패: ${failure.message}');
          emit(AuthError(_mapFailureToMessage(failure)));
          emit(AuthUnauthenticated());
        },
        (user) {
          debugPrint('교사 회원가입 성공: ${user.displayName}');
          AppRouter.setCurrentUser(user);
          emit(AuthAuthenticated(user));
        },
      );
    } catch (e) {
      debugPrint('교사 회원가입 중 예외 발생: $e');
      emit(AuthError('회원가입 중 오류가 발생했습니다.'));
      emit(AuthUnauthenticated());
    }
  }

  /// 학생 로그인
  Future<void> signInStudent({
    required String schoolName,
    required String studentId,
    required String password,
  }) async {
    try {
      emit(AuthLoading());

      final result = await _signInStudent(
        SignInStudentParams(
          schoolName: schoolName,
          studentId: studentId,
          password: password,
        ),
      );

      result.fold(
        (failure) {
          debugPrint('학생 로그인 실패: ${failure.message}');
          emit(AuthError(_mapFailureToMessage(failure)));
          emit(AuthUnauthenticated());
        },
        (user) {
          debugPrint('학생 로그인 성공: ${user.displayName}');
          AppRouter.setCurrentUser(user);
          emit(AuthAuthenticated(user));
        },
      );
    } catch (e) {
      debugPrint('학생 로그인 중 예외 발생: $e');
      emit(AuthError('로그인 중 오류가 발생했습니다.'));
      emit(AuthUnauthenticated());
    }
  }

  /// 로그아웃 - 완전히 새로 구현
  Future<void> signOut() async {
    try {
      debugPrint('로그아웃 시작');
      
      // 1. 먼저 명시적으로 AuthLoading 상태 전환
      emit(AuthLoading());
      
      // 2. AppRouter의 사용자 정보를 삭제하기 전에 현재 사용자의 복사본 저장
      final currentUserCopy = _currentUser;
      
      // 3. AppRouter의 사용자 정보 삭제 - 이후 리디렉션이 발생함
      AppRouter.setCurrentUser(null);
      
      // 4. 상태를 미인증 상태로 설정 - UI가 재구성됨
      emit(AuthUnauthenticated());
      
      // 5. 지연 시간 후 Firebase에서 실제 로그아웃 - 비동기 작업 
      await Future.delayed(const Duration(milliseconds: 300));
      
      // 6. 실제 Firebase 로그아웃 수행
      final result = await _signOut(NoParams());
      
      // 7. 완료 처리
      result.fold(
        (failure) {
          debugPrint('Firebase 로그아웃 실패: ${failure.message}');
          // (이미 UI는 로그아웃 상태로 변경되었으므로 사용자에게 오류를 표시하지 않음)
        },
        (_) {
          debugPrint('로그아웃 성공');
          // 이미 AuthUnauthenticated 상태로 변경됨
        },
      );
      
    } catch (e) {
      debugPrint('로그아웃 중 예외 발생: $e');
      // 오류가 발생해도 사용자 UI는 이미 로그아웃 상태로 변경됨
      emit(AuthUnauthenticated());
    }
  }
  
  /// _currentUser 체크를 위한 getter (유닛 테스트 및 안전 로직용)
  User? get _currentUser {
    if (state is AuthAuthenticated) {
      return (state as AuthAuthenticated).user;
    }
    return null;
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
