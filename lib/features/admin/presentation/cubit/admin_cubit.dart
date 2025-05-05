import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/repositories/admin_repository.dart';
import '../../domain/usecases/approve_teacher.dart';
import '../../domain/usecases/get_pending_teachers.dart';
import '../../domain/usecases/sign_in_admin.dart';
import 'admin_state.dart';

/// 관리자 Cubit
class AdminCubit extends Cubit<AdminState> {
  final SignInAdmin _signInAdmin;
  final GetPendingTeachers _getPendingTeachers;
  final ApproveTeacher _approveTeacher;
  final AdminRepository _adminRepository;
  
  AdminCubit({
    required SignInAdmin signInAdmin,
    required GetPendingTeachers getPendingTeachers,
    required ApproveTeacher approveTeacher,
    required AdminRepository adminRepository,
  }) : _signInAdmin = signInAdmin,
       _getPendingTeachers = getPendingTeachers,
       _approveTeacher = approveTeacher,
       _adminRepository = adminRepository,
       super(const AdminInitial());
  
  /// 관리자 로그인
  Future<void> signInAdmin(String username, String password) async {
    emit(const AdminLoading());
    
    final params = SignInAdminParams(
      username: username,
      password: password,
    );
    
    final result = await _signInAdmin(params);
    emit(result.fold(
      (failure) => AdminError(failure.message),
      (admin) => AdminAuthenticated(admin),
    ));
  }
  
  /// 승인 대기 중인 교사 목록 조회
  Future<void> getPendingTeachers() async {
    emit(const AdminLoading());
    
    final result = await _getPendingTeachers(NoParams());
    emit(result.fold(
      (failure) => AdminError(failure.message),
      (teachers) => TeachersLoaded(teachers),
    ));
  }
  
  /// 모든 교사 목록 조회
  Future<void> getAllTeachers() async {
    emit(const AdminLoading());
    
    final result = await _adminRepository.getAllTeachers();
    emit(result.fold(
      (failure) => AdminError(failure.message),
      (teachers) => TeachersLoaded(teachers),
    ));
  }
  
  /// 교사 계정 승인
  Future<void> approveTeacher(String teacherId) async {
    emit(const AdminLoading());
    
    final params = ApproveTeacherParams(teacherId: teacherId);
    final result = await _approveTeacher(params);
    
    result.fold(
      (failure) => emit(AdminError(failure.message)),
      (_) {
        emit(TeacherApproved(teacherId));
        getPendingTeachers(); // 목록 갱신
      },
    );
  }
  
  /// 교사 계정 거부/삭제
  Future<void> rejectTeacher(String teacherId) async {
    emit(const AdminLoading());
    
    final result = await _adminRepository.rejectTeacher(teacherId);
    
    result.fold(
      (failure) => emit(AdminError(failure.message)),
      (_) {
        emit(TeacherRejected(teacherId));
        getPendingTeachers(); // 목록 갱신
      },
    );
  }
  
  /// 관리자 로그아웃
  Future<void> signOut() async {
    emit(const AdminLoading());
    
    final result = await _adminRepository.signOut();
    
    result.fold(
      (failure) => emit(AdminError(failure.message)),
      (_) => emit(const AdminInitial()),
    );
  }
}