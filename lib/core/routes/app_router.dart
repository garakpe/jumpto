import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// User 클래스의 정확한 임포트 경로와 실제 속성 이름을 확인하세요.
import '../../features/auth/domain/entities/user.dart';

import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../features/admin/presentation/pages/admin_login_page.dart';
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

class AppRouter {
  // 안전한 사용자 정보 상태 관리를 위한 클래스 변수
  static User? _currentUser;
  static GoRouter? _router;

  // 사용자 컨텍스트를 설정하는 메서드
  static void setCurrentUser(User? user) {
    try {
      // 이전 사용자 정보 로깅 (문제 발생 가능 부분)
      final prevUserDesc = _currentUser == null 
          ? "null" 
          : "User{id: ${_currentUser?.id}, displayName: ${_currentUser?.displayName}, isAdmin: ${_currentUser?.isAdmin}}";
      debugPrint('이전 사용자: $prevUserDesc');

      // 새 사용자 할당 전에 이전 참조 완전히 삭제
      _currentUser = null;
      
      // 새 사용자 정보 할당
      _currentUser = user;

      // 새 사용자 정보 로깅
      final newUserDesc = user == null 
          ? "null, null, isAdmin: null" 
          : "User{id: ${user.id}, displayName: ${user.displayName}, isAdmin: ${user.isAdmin}}";
      debugPrint('새 사용자 설정: $newUserDesc');

      // 로그아웃인 경우 라우터 새로고침 전에 약간의 지연
      if (user == null) {
        Future.delayed(const Duration(milliseconds: 50), () {
          _router?.refresh();
        });
      } else {
        _router?.refresh();
      }
    } catch (e) {
      debugPrint('사용자 설정 중 오류 발생: $e');
    }
  }

  // 관리자 경로인지 확인하는 헬퍼 메서드
  static bool _isAdminPath(String? path) {
    return path?.startsWith('/admin') ?? false;
  }

  // 라우터 인스턴스 게터
  static GoRouter get router {
    // 라우터가 아직 초기화되지 않은 경우에만 생성
    _router ??= GoRouter(
      navigatorKey: GlobalKey<NavigatorState>(),
      initialLocation: '/splash',
      debugLogDiagnostics: true,
      
      // 리디렉션 로직
      redirect: (BuildContext context, GoRouterState state) {
        try {
          // 현재 경로 정보 (널 안전하게 처리)
          final String currentPath = state.fullPath ?? '/login';
          final String currentRouteName = state.name ?? state.path ?? 'unknown ($currentPath)';
          
          // 로그인 상태 확인 (널 안전)
          final bool isLoggedIn = _currentUser != null;
          
          // 사용자 정보 (널 안전)
          final String userProps = isLoggedIn 
              ? "id:${_currentUser!.id},role:${_currentUser!.role},approved:${_currentUser!.isApproved}"
              : "null";
          
          debugPrint('Router redirect: currentPath=$currentPath, currentRouteName=$currentRouteName, isLoggedIn=$isLoggedIn, userProps=$userProps');

          // 1. 스플래시 화면 예외 처리
          if (currentPath == '/splash') {
            debugPrint('리디렉션: Splash 화면 -> 조건 없음, 현재 경로 유지.');
            return null;
          }

          // 2. 관리자 경로 처리
          if (_isAdminPath(currentPath)) {
            if (currentPath == '/admin/dashboard') {
              if (isLoggedIn && _currentUser!.isAdmin) {
                // 관리자로 로그인한 경우 대시보드 접근 허용
                debugPrint('리디렉션: 관리자 대시보드 -> 접근 허용');
                return null;
              } else {
                // 관리자가 아니거나 로그인하지 않은 경우 로그인 페이지로 이동
                debugPrint('리디렉션: 관리자 대시보드 -> 관리자 로그인으로 이동');
                return '/admin/login';
              }
            }
            // 기타 관리자 경로는 그대로 유지
            debugPrint('리디렉션: 기타 관리자 경로 -> 조건 없음, 현재 경로 유지');
            return null;
          }

          // 3. 인증 화면 여부 확인 (로그인, 회원가입)
          final bool isGoingToAuth = currentPath == '/login' || currentPath == '/register';

          // 4. 로그아웃 상태일 때
          if (!isLoggedIn) {
            if (!isGoingToAuth) {
              // 인증 화면이 아닌 곳으로 가려고 할 때 로그인 페이지로 이동
              debugPrint('리디렉션: 로그아웃 상태 & 인증 화면 아님 -> 로그인 페이지로 이동');
              return '/login';
            } else {
              // 인증 화면으로 가려고 할 때는 그대로 유지
              debugPrint('리디렉션: 로그아웃 상태 & 인증 화면 -> 조건 없음, 현재 경로 유지');
              return null;
            }
          }

          // 5. 로그인 상태일 때
          
          // 인증 화면으로 가려고 할 때 콘텐츠 선택 페이지로 이동
          if (isGoingToAuth) {
            debugPrint('리디렉션: 로그인 상태 & 인증 화면 -> 콘텐츠 선택 페이지로 이동');
            return '/content-selection';
          }

          // 교사 승인 대기 상태 처리
          if (_currentUser!.isTeacher && !_currentUser!.isApproved) {
            if (currentPath != '/waiting-approval') {
              debugPrint('리디렉션: 교사 승인 대기 중 -> 승인 대기 페이지로 이동');
              return '/waiting-approval';
            }
          }

          // 권한 체크 - 학생 업로드 페이지
          if (currentPath == '/student-upload' && !_currentUser!.isTeacher) {
            debugPrint('리디렉션: 학생 업로드 -> 교사 권한 필요, 콘텐츠 선택 페이지로 이동');
            return '/content-selection';
          }

          // 권한 체크 - 학생 마이페이지
          if (currentPath == '/student-mypage' && !_currentUser!.isStudent) {
            debugPrint('리디렉션: 학생 마이페이지 -> 학생 권한 필요, 콘텐츠 선택 페이지로 이동');
            return '/content-selection';
          }

          // 조건에 맞지 않으면 현재 경로 유지
          debugPrint('리디렉션: 모든 조건 불일치 -> 조건 없음, 현재 경로 유지');
          return null;
          
        } catch (e) {
          // 리디렉션 중 오류 발생 시 로그인 페이지로 이동 (안전 장치)
          debugPrint('리디렉션 중 오류 발생: $e');
          return '/login';
        }
      },
      
      // 라우트 정의
      routes: [
        GoRoute(
          path: '/content-selection',
          name: 'content-selection',
          builder: (context, state) => const ContentSelectionPage(),
        ),
        GoRoute(
          path: '/splash',
          name: 'splash',
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/register',
          name: 'register',
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/paps-standards',
          name: 'paps-standards',
          builder: (context, state) => const PapsStandardsPage(),
        ),
        GoRoute(
          path: '/paps-measurement',
          name: 'paps-measurement',
          builder: (context, state) => const PapsMeasurementPage(),
        ),
        GoRoute(
          path: '/teacher-event-selection',
          name: 'teacher-event-selection',
          builder: (context, state) => const TeacherEventSelectionPage(),
        ),
        GoRoute(
          path: '/teacher-dashboard',
          name: 'teacher-dashboard',
          builder: (context, state) => const TeacherDashboardPage(),
        ),
        GoRoute(
          path: '/student-upload',
          name: 'student-upload',
          builder: (context, state) => const StudentUploadPage(),
        ),
        GoRoute(
          path: '/student-mypage',
          name: 'student-mypage',
          builder: (context, state) => const StudentMyPage(),
        ),
        GoRoute(
          path: '/waiting-approval',
          name: 'waiting-approval',
          builder: (context, state) => const WaitingApprovalPage(),
        ),
        GoRoute(
          path: '/admin/login',
          name: 'admin-login',
          builder: (context, state) => const AdminLoginPage(),
        ),
        GoRoute(
          path: '/admin/dashboard',
          name: 'admin-dashboard',
          builder: (context, state) => const AdminDashboardPage(),
        ),
      ],
    );
    
    return _router!;
  }
}
