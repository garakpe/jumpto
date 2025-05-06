import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../features/admin/presentation/pages/admin_login_page.dart';
import '../../features/auth/domain/entities/user.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/student_mypage.dart';
import '../../features/auth/presentation/pages/student_upload_page.dart';
import '../../features/auth/presentation/pages/waiting_approval_page.dart';
import '../../features/common/presentation/pages/content_selection_page.dart';
import '../../features/paps/presentation/pages/home_page.dart';
import '../../features/paps/presentation/pages/paps_measurement_page.dart';
import '../../features/paps/presentation/pages/paps_standards_page.dart';
import '../../features/paps/presentation/pages/teacher_event_selection_page.dart';
import '../../features/teacher_dashboard/presentation/pages/teacher_dashboard_page.dart';

/// 앱 라우팅 설정
class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  
  // 인증 상태
  static User? _currentUser;
  
  /// 인증 상태 설정
  static void setCurrentUser(User? user) {
    print('이전 사용자: $_currentUser');
    _currentUser = user;
    print('새 사용자 설정: ${user?.id}, ${user?.displayName}, isAdmin: ${user?.isAdmin}');
    
    // 라우터 재구성 - 인증 상태에 따라 리디렉션
    if (_router != null) {
      _router!.refresh();
    }
  }
  
  /// 관리자 로그인 여부
  static bool _isAdminPath(String path) {
    return path.startsWith('/admin');
  }
  
  /// 라우터 인스턴스
  static GoRouter? _router;
  
  /// 라우터 초기화 및 반환
  static GoRouter get router {
    _router ??= GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/splash',
      redirect: (context, state) {
        // 스플래시 화면은 항상 접근 가능
        if (state.fullPath == '/splash') {
          return null;
        }
        
        // 관리자 경로인 경우 일반 인증 여부 검사 제외
        if (_isAdminPath(state.fullPath!)) {
          // 관리자 대시보드로 가는 경우 로그인 여부 확인
          if (state.fullPath == '/admin/dashboard') {
            if (_currentUser == null || !_currentUser!.isAdmin) {
              print('관리자 권한 부족: $_currentUser');
              return '/admin/login';
            } else {
              print('관리자 접근 허용: ${_currentUser!.displayName}');
            }
          }
          return null; // 관리자 관련 경로는 기본 리디렉션 없음
        }
        
        // 인증 여부에 따른 리디렉션
        final bool isLoggedIn = _currentUser != null;
        final bool isGoingToAuth = state.fullPath == '/login' || state.fullPath == '/register';
        
        // 로그인하지 않은 경우 로그인 화면으로 리디렉션
        if (!isLoggedIn && !isGoingToAuth) {
          return '/login';
        }
        
        // 이미 로그인한 경우 인증 화면으로 가지 못하도록 콘텐츠 선택 화면으로 리디렉션
        if (isLoggedIn && isGoingToAuth) {
          return '/content-selection';
        }
        
        // 교사 승인 여부 확인
        if (isLoggedIn && _currentUser!.isTeacher && !_currentUser!.isApproved) {
          // 승인 대기 화면으로 리디렉션 (승인 대기 화면은 접근 가능)
          if (state.fullPath != '/waiting-approval') {
            return '/waiting-approval';
          }
        }
        
        // 학생 업로드 페이지는 교사만 접근 가능
        if (isLoggedIn && state.fullPath == '/student-upload' && !_currentUser!.isTeacher) {
          return '/content-selection';
        }
        
        // 학생 마이페이지는 학생만 접근 가능
        if (isLoggedIn && state.fullPath == '/student-mypage' && !_currentUser!.isStudent) {
          return '/content-selection';
        }
        
        // 기본적으로 리디렉션 없음
        return null;
      },
      routes: [
        // 콘텐츠 선택 화면
        GoRoute(
          path: '/content-selection',
          builder: (context, state) => const ContentSelectionPage(),
        ),
        // 스플래시 화면
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashPage(),
        ),
        
        // 인증 화면
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterPage(),
        ),
        
        // 홈 화면
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomePage(),
        ),
        
        // 팝스 기준표 화면
        GoRoute(
          path: '/paps-standards',
          builder: (context, state) => const PapsStandardsPage(),
        ),
        
        // 팝스 측정 화면
        GoRoute(
          path: '/paps-measurement',
          builder: (context, state) => const PapsMeasurementPage(),
        ),
        
        // 교사용 측정 종목 선택 화면
        GoRoute(
          path: '/teacher-event-selection',
          builder: (context, state) => const TeacherEventSelectionPage(),
        ),
        
        // 교사용 대시보드 화면
        GoRoute(
          path: '/teacher-dashboard',
          builder: (context, state) => const TeacherDashboardPage(),
        ),
        
        // 학생 업로드 화면 (추가)
        GoRoute(
          path: '/student-upload',
          builder: (context, state) => const StudentUploadPage(),
        ),
        
        // 학생 마이페이지 화면 (추가)
        GoRoute(
          path: '/student-mypage',
          builder: (context, state) => const StudentMyPage(),
        ),
        
        // 승인 대기 화면
        GoRoute(
          path: '/waiting-approval',
          builder: (context, state) => const WaitingApprovalPage(),
        ),
        
        // 관리자 로그인 화면 (숨겨진 URL)
        GoRoute(
          path: '/admin/login',
          builder: (context, state) => const AdminLoginPage(),
        ),
        
        // 관리자 대시보드 화면
        GoRoute(
          path: '/admin/dashboard',
          builder: (context, state) => const AdminDashboardPage(),
        ),
      ],
    );
    
    return _router!;
  }
}