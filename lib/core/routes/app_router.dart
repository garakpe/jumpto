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
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static User? _currentUser;

  static void setCurrentUser(User? user) {
    // User 클래스에 displayName, id, isAdmin 속성이 실제 존재하는지 확인 필요
    final prevUserDesc =
        _currentUser == null
            ? "null"
            : "User{id: ${_currentUser?.id}, displayName: ${_currentUser?.displayName}, isAdmin: ${_currentUser?.isAdmin}}";
    print('이전 사용자: $prevUserDesc');

    _currentUser = user;

    final newUserDesc =
        user == null
            ? "null, null, isAdmin: null"
            : "User{id: ${user.id}, displayName: ${user.displayName}, isAdmin: ${user.isAdmin}}";
    print('새 사용자 설정: $newUserDesc');

    _router?.refresh();
  }

  static bool _isAdminPath(String? path) {
    return path?.startsWith('/admin') ?? false;
  }

  static GoRouter? _router;

  static GoRouter get router {
    _router ??= GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/splash',
      debugLogDiagnostics: true,
      redirect: (BuildContext context, GoRouterState state) {
        final String? currentPath = state.fullPath;
        final String currentRouteName =
            state.name ??
            state.path ??
            'unknown ($currentPath)'; // 경로가 null일 경우 대비
        final User? user = _currentUser;
        final bool isLoggedIn = user != null;

        print(
          'Router redirect: currentPath=$currentPath, currentRouteName=$currentRouteName, isLoggedIn=$isLoggedIn, userProps=${user == null ? "null" : "id:${user.id},role:${user.role},approved:${user.isApproved}"}',
        );

        if (currentPath == '/splash') {
          print('리디렉션: Splash 화면 -> 조건 없음, 현재 경로 유지.');
          return null;
        }

        // 관리자 경로 처리
        if (_isAdminPath(currentPath)) {
          if (currentPath == '/admin/dashboard') {
            if (isLoggedIn && user.isAdmin) {
              // User 클래스에 'isAdmin' bool getter 필요
              print('리디렉션: 관리자 대시보드 -> 접근 허용 (${user.displayName}).');
              return null;
            } else {
              print(
                '리디렉션: 관리자 대시보드 -> 권한 부족/로그인 안됨. 관리자 로그인으로 이동. User: $user',
              );
              return '/admin/login';
            }
          }
          print('리디렉션: 기타 관리자 경로 ($currentPath) -> 조건 없음, 현재 경로 유지.');
          return null;
        }

        // 일반 사용자 경로 처리
        final bool isGoingToAuth =
            currentPath == '/login' || currentPath == '/register';

        if (!isLoggedIn) {
          // 로그아웃 상태
          if (!isGoingToAuth) {
            print('리디렉션: 로그아웃 상태 & 인증 화면 아님 ($currentPath) -> 로그인 페이지로 이동.');
            return '/login';
          } else {
            // 로그아웃 상태 & 인증 화면으로 가는 중 (예: /login, /register)
            print(
              '리디렉션: 로그아웃 상태 & 인증 화면으로 이동 중 ($currentPath) -> 조건 없음, 현재 경로 유지.',
            );
            return null; // 현재 경로(로그인 또는 회원가입) 유지
          }
        }

        // --- 이하 isLoggedIn 이 true 인 (로그인한) 경우 ---
        final loggedInUser = user; // 이제 loggedInUser는 non-nullable

        if (isGoingToAuth) {
          print(
            '리디렉션: 로그인 상태 & 인증 화면으로 이동 시도 ($currentPath) -> 콘텐츠 선택 페이지로 이동.',
          );
          return '/content-selection';
        }

        // User 클래스에 isTeacher (bool), isApproved (bool), isStudent (bool) getter/속성 필요
        if (loggedInUser.isTeacher && !loggedInUser.isApproved) {
          if (currentPath != '/waiting-approval') {
            print(
              '리디렉션: 교사 승인 대기 중 (${loggedInUser.displayName}) -> 승인 대기 페이지로 이동.',
            );
            return '/waiting-approval';
          }
        }

        if (currentPath == '/student-upload' && !loggedInUser.isTeacher) {
          print('리디렉션: 학생 업로드 ($currentPath) -> 교사 권한 필요. 콘텐츠 선택 페이지로 이동.');
          return '/content-selection';
        }

        if (currentPath == '/student-mypage' && !loggedInUser.isStudent) {
          print('리디렉션: 학생 마이페이지 ($currentPath) -> 학생 권한 필요. 콘텐츠 선택 페이지로 이동.');
          return '/content-selection';
        }

        print('리디렉션: 모든 조건 불일치 ($currentPath) -> 조건 없음, 현재 경로 유지.');
        return null;
      },
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
