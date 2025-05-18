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
      await Future.delayed(const Duration(milliseconds: 100));
      
      // 초기 인증 상태 확인은 한 번만 실행
      final result = await _getCurrentUser(NoParams());
      
      result.fold(
        (failure) {
          debugPrint('초기 인증 상태 확인 실패: ${failure.message}');
          emit(AuthUnauthenticated());
          AppRouter.setCurrentUser(null);
        },
        (user) {
          if (user != null) {
            debugPrint('초기 인증된 사용자: ${user.displayName}');
            AppRouter.setCurrentUser(user);
            emit(AuthAuthenticated(user));
          } else {
            debugPrint('초기 인증되지 않은 상태');
            AppRouter.setCurrentUser(null);
            emit(AuthUnauthenticated());
          }
        },
      );
    } catch (e) {
      debugPrint('초기 인증 상태 설정 오류: $e');
      emit(AuthUnauthenticated());
      AppRouter.setCurrentUser(null);
    }
  }

  // 마지막 체크 타임스탬프
  DateTime? _lastAuthCheck;
  // 최소 체크 간격 (밀리초)
  static const _minCheckInterval = 2000;
  
  /// 현재 인증 상태 확인 - 최적화 버전
  Future<void> checkAuthState() async {
    // 이전 체크로부터 최소 시간이 지나지 않았다면 무시
    final now = DateTime.now();
    if (_lastAuthCheck != null && 
        now.difference(_lastAuthCheck!).inMilliseconds < _minCheckInterval) {
      debugPrint('인증 상태 체크 무시: 최근에 이미 확인함 (${now.difference(_lastAuthCheck!).inMilliseconds}ms 전)');
      return;
    }
    
    // 현재 상태가 이미 로딩 중이면 중복 체크 방지
    if (state is AuthLoading) {
      debugPrint('인증 상태 체크 무시: 이미 로딩 중');
      return;
    }
    
    _lastAuthCheck = now;
    
    try {
      emit(AuthLoading());

      final result = await _getCurrentUser(NoParams());

      result.fold(
        (failure) {
          debugPrint('인증 상태 확인 중 실패: ${failure.message}');
          emit(AuthError(_mapFailureToMessage(failure)));
          emit(AuthUnauthenticated());
          AppRouter.setCurrentUser(null);
        },
        (user) {
          // 현재 상태와 동일한지 확인하여 불필요한 상태 변경 방지
          if (user != null) {
            final bool isSameUser = (state is AuthAuthenticated) && 
                (state as AuthAuthenticated).user.id == user.id;
                
            if (isSameUser) {
              debugPrint('인증 상태 유지: 동일한 사용자 ${user.displayName}');
              emit(state); // 현재 상태 유지
            } else {
              debugPrint('인증 상태 변경: 사용자 ${user.displayName}');
              AppRouter.setCurrentUser(user);
              emit(AuthAuthenticated(user));
            }
          } else {
            final bool alreadyUnauthenticated = state is AuthUnauthenticated;
            
            if (alreadyUnauthenticated) {
              debugPrint('인증 상태 유지: 이미 인증되지 않은 상태');
              emit(state); // 현재 상태 유지
            } else {
              debugPrint('인증 상태 변경: 인증되지 않은 상태로 변경');
              AppRouter.setCurrentUser(null);
              emit(AuthUnauthenticated());
            }
          }
        },
      );
    } catch (e) {
      debugPrint('인증 상태 확인 중 예외 발생: $e');
      emit(AuthError('인증 상태 확인 중 오류가 발생했습니다.'));
      emit(AuthUnauthenticated());
      AppRouter.setCurrentUser(null);
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

  /// 로그아웃 - 안정성 강화 버전
  Future<void> signOut() async {
    try {
      debugPrint('로그아웃 시작');
      
      // 이미 로그아웃 상태인 경우 무시
      if (state is AuthUnauthenticated) {
        debugPrint('이미 로그아웃 상태, 작업 건너뜀');
        return;
      }
      
      // 1. 먼저 명시적으로 AuthLoading 상태 전환
      emit(AuthLoading());
      
      // 2. 먼저 Firebase Auth에서 로그아웃 수행 (중요: UI 변경 전에 실행)
      // 이렇게 하면 로그아웃이 실패해도 UI가 일관되게 유지됨
      final result = await _signOut(NoParams());
      
      // 로그아웃 결과 확인
      bool logoutSuccess = false;
      result.fold(
        (failure) {
          debugPrint('Firebase 로그아웃 실패: ${failure.message}');
          logoutSuccess = false;
        },
        (_) {
          debugPrint('Firebase 로그아웃 성공');
          logoutSuccess = true;
        },
      );
      
      // 3. 성공한 경우에만 AppRouter의 사용자 정보 삭제 및 UI 상태 변경
      if (logoutSuccess) {
        // AppRouter의 사용자 정보 삭제 (리디렉션 발생)
        AppRouter.setCurrentUser(null);
        
        // 상태를 미인증 상태로 설정 (UI 재구성)
        emit(AuthUnauthenticated());
        debugPrint('로그아웃 완료: UI 및 라우팅 상태 업데이트됨');
      } else {
        // 실패한 경우 이전 인증 상태 복원
        if (state is AuthLoading && _currentUser != null) {
          emit(AuthAuthenticated(_currentUser!));
          debugPrint('로그아웃 실패: 이전 인증 상태로 복원됨');
        } else {
          // 사용자 정보가 없는 경우 인증되지 않은 상태로 설정
          emit(AuthUnauthenticated());
          AppRouter.setCurrentUser(null);
          debugPrint('로그아웃 실패 처리: 인증되지 않은 상태로 설정');
        }
      }
    } catch (e) {
      debugPrint('로그아웃 중 예외 발생: $e');
      // 심각한 오류 발생 시 인증되지 않은 상태로 강제 전환
      // (일관성 있는 상태 유지를 위해)
      emit(AuthUnauthenticated());
      AppRouter.setCurrentUser(null);
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
