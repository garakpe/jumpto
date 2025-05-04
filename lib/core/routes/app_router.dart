import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/entities/user.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
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
    _currentUser = user;
    
    // 라우터 재구성 - 인증 상태에 따라 리디렉션
    if (_router != null) {
      _router!.refresh();
    }
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
        
        // 교사용 대시보드 화면 (신규 추가)
        GoRoute(
          path: '/teacher-dashboard',
          builder: (context, state) => const TeacherDashboardPage(),
        ),
      ],
    );
    
    return _router!;
  }
}