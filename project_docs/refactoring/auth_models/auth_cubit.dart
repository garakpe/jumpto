import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/routes/app_router.dart';
import '../../../domain/entities/admin.dart';
import '../../../domain/entities/base_user.dart';
import '../../../domain/entities/student.dart';
import '../../../domain/entities/teacher.dart';
import '../../../domain/usecases/approve_teacher.dart';
import '../../../domain/usecases/get_current_user.dart';
import '../../../domain/usecases/get_current_user_with_details.dart';
import '../../../domain/usecases/sign_in_admin.dart';
import '../../../domain/usecases/sign_in_student.dart';
import '../../../domain/usecases/sign_in_with_email_password.dart';
import '../../../domain/usecases/sign_out.dart';
import '../../../domain/usecases/sign_up_teacher.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final GetCurrentUser _getCurrentUser;
  final GetCurrentUserWithDetails _getCurrentUserWithDetails;
  final SignInWithEmailPassword _signInWithEmailPassword;
  final SignUpTeacher _signUpTeacher;
  final SignInStudent _signInStudent;
  final SignOut _signOut;
  final SignInAdmin _signInAdmin;
  final ApproveTeacher _approveTeacher;

  DateTime _lastAuthCheck = DateTime.now();
  static const _minCheckInterval = Duration(seconds: 2); // 최소 체크 간격 (2초)

  AuthCubit({
    required GetCurrentUser getCurrentUser,
    required GetCurrentUserWithDetails getCurrentUserWithDetails,
    required SignInWithEmailPassword signInWithEmailPassword,
    required SignUpTeacher signUpTeacher,
    required SignInStudent signInStudent,
    required SignOut signOut,
    required SignInAdmin signInAdmin,
    required ApproveTeacher approveTeacher,
  })  : _getCurrentUser = getCurrentUser,
        _getCurrentUserWithDetails = getCurrentUserWithDetails,
        _signInWithEmailPassword = signInWithEmailPassword,
        _signUpTeacher = signUpTeacher,
        _signInStudent = signInStudent,
        _signOut = signOut,
        _signInAdmin = signInAdmin,
        _approveTeacher = approveTeacher,
        super(AuthInitial());

  Future<void> checkAuthState() async {
    // 마지막 체크 이후 최소 간격이 지났는지 확인
    final now = DateTime.now();
    if (now.difference(_lastAuthCheck) < _minCheckInterval) {
      return; // 최소 간격이 지나지 않은 경우 무시
    }
    _lastAuthCheck = now;

    emit(AuthLoading());

    final user = await _getCurrentUser();
    if (user == null) {
      emit(AuthUnauthenticated());
      return;
    }

    // 사용자 세부 정보 조회
    final userDetailsResult = await _getCurrentUserWithDetails();
    
    userDetailsResult.fold(
      (failure) {
        // 세부 정보 조회 실패 시에는 기본 정보만으로 인증 상태 설정
        emit(AuthAuthenticated(
          baseUser: user, 
          userDetail: null,
        ));
        
        AppRouter.setCurrentUser(user);
      },
      (userDetail) {
        emit(AuthAuthenticated(
          baseUser: user,
          userDetail: userDetail,
        ));
        
        // 라우터에 현재 사용자 설정 (세부 정보가 있는 경우)
        if (userDetail is BaseUser) {
          AppRouter.setCurrentUser(user);
        } else {
          AppRouter.setCurrentUser(userDetail);
        }
      },
    );
  }

  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());

    final result = await _signInWithEmailPassword(
      SignInWithEmailPasswordParams(
        email: email,
        password: password,
      ),
    );

    result.fold(
      (failure) {
        emit(AuthError(message: failure.message));
      },
      (user) async {
        // 로그인 성공 시 세부 정보 조회
        final userDetailsResult = await _getCurrentUserWithDetails();
        
        userDetailsResult.fold(
          (detailFailure) {
            // 세부 정보 조회 실패 시에는 기본 정보만으로 인증 상태 설정
            emit(AuthAuthenticated(
              baseUser: user, 
              userDetail: null,
            ));
            
            AppRouter.setCurrentUser(user);
          },
          (userDetail) {
            emit(AuthAuthenticated(
              baseUser: user,
              userDetail: userDetail,
            ));
            
            // 라우터에 현재 사용자 설정 (세부 정보가 있는 경우)
            if (userDetail is BaseUser) {
              AppRouter.setCurrentUser(user);
            } else {
              AppRouter.setCurrentUser(userDetail);
            }
          },
        );
      },
    );
  }

  Future<void> signUpTeacher({
    required String email,
    required String password,
    required String displayName,
    required String schoolCode,
    required String schoolName,
    String? phoneNumber,
  }) async {
    emit(AuthLoading());

    final result = await _signUpTeacher(
      SignUpTeacherParams(
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
        emit(AuthError(message: failure.message));
      },
      (teacher) {
        emit(AuthAuthenticated(
          baseUser: teacher.baseUser, 
          userDetail: teacher,
        ));
        
        AppRouter.setCurrentUser(teacher);
      },
    );
  }

  Future<void> signInStudent({
    required String schoolName,
    required String studentId,
    required String password,
  }) async {
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
        emit(AuthError(message: failure.message));
      },
      (user) async {
        // 로그인 성공 시 세부 정보 조회
        final userDetailsResult = await _getCurrentUserWithDetails();
        
        userDetailsResult.fold(
          (detailFailure) {
            // 세부 정보 조회 실패 시에는 기본 정보만으로 인증 상태 설정
            emit(AuthAuthenticated(
              baseUser: user, 
              userDetail: null,
            ));
            
            AppRouter.setCurrentUser(user);
          },
          (userDetail) {
            emit(AuthAuthenticated(
              baseUser: user,
              userDetail: userDetail,
            ));
            
            // 라우터에 현재 사용자 설정 (세부 정보가 있는 경우)
            if (userDetail is BaseUser) {
              AppRouter.setCurrentUser(user);
            } else {
              AppRouter.setCurrentUser(userDetail);
            }
          },
        );
      },
    );
  }

  Future<void> signInAdmin({
    required String username,
    required String password,
  }) async {
    emit(AuthLoading());

    final result = await _signInAdmin(
      SignInAdminParams(
        username: username,
        password: password,
      ),
    );

    result.fold(
      (failure) {
        emit(AuthError(message: failure.message));
      },
      (admin) {
        emit(AuthAuthenticated(
          baseUser: admin.baseUser, 
          userDetail: admin,
        ));
        
        AppRouter.setCurrentUser(admin);
      },
    );
  }

  Future<void> approveTeacher(String teacherId) async {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      final result = await _approveTeacher(ApproveTeacherParams(teacherId));

      result.fold(
        (failure) {
          emit(AuthError(message: failure.message));
          emit(currentState); // 오류 후 이전 상태로 돌아감
        },
        (_) {
          // 성공 시 현재 상태 유지 (또는 필요시 업데이트)
          emit(currentState);
        },
      );
    }
  }

  Future<void> signOut() async {
    emit(AuthLoading());

    try {
      await _signOut(NoParams());
      emit(AuthUnauthenticated());
      AppRouter.clearCurrentUser();
    } catch (e) {
      emit(AuthError(message: '로그아웃 중 오류가 발생했습니다.'));
      // 오류 발생 시 현재 상태 유지 시도
      checkAuthState();
    }
  }
}
