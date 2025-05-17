import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:universal_html/html.dart' as html;

import 'core/firebase/firebase_initializer.dart';
import 'core/presentation/theme/app_theme.dart';
import 'core/routes/app_router.dart';
import 'features/admin/presentation/cubit/admin_cubit.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/cubit/student_cubit.dart';
import 'features/common/presentation/cubit/school_cubit.dart';
import 'features/paps/presentation/cubit/paps_cubit.dart';
import 'features/teacher_dashboard/presentation/cubit/teacher_settings_cubit.dart';
import 'di/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화 (업데이트됨)
  await FirebaseInitializer.initialize();

  // 의존성 주입 초기화
  await di.init();

  // 웹 환경에서 PAPS 기준표 미리 로드
  if (kIsWeb) {
    await _preloadPapsStandards();
  }

  runApp(const MyApp());
}

/// 웹 환경에서 팝스 기준표 데이터를 미리 로드하는 함수
Future<void> _preloadPapsStandards() async {
  try {
    // 미리 로드된 데이터가 있는지 확인
    final cachedData = html.window.localStorage['paps_standards_cache'];
    if (cachedData != null && cachedData.isNotEmpty) {
      print('캐싱된 팝스 기준표 데이터가 있어 사용합니다.');
      return;
    }

    // 각 경로를 시도하면서 처음 성공하는 경로의 데이터를 캐싱
    try {
      final response = await html.window.fetch(
        'assets/data/paps_standards.json',
      );
      if (response.ok) {
        final text = await response.text();
        html.window.localStorage['paps_standards_cache'] = text;
        print('팝스 기준표 데이터를 성공적으로 미리 로드했습니다.');
        return;
      }
    } catch (e) {
      print('첫 번째 경로 미리 로드 실패: $e');
    }

    try {
      final response = await html.window.fetch(
        '/assets/data/paps_standards.json',
      );
      if (response.ok) {
        final text = await response.text();
        html.window.localStorage['paps_standards_cache'] = text;
        print('팝스 기준표 데이터를 두 번째 경로에서 성공적으로 미리 로드했습니다.');
        return;
      }
    } catch (e) {
      print('두 번째 경로 미리 로드 실패: $e');
    }

    try {
      final response = await html.window.fetch('paps_standards.json');
      if (response.ok) {
        final text = await response.text();
        html.window.localStorage['paps_standards_cache'] = text;
        print('팝스 기준표 데이터를 세 번째 경로에서 성공적으로 미리 로드했습니다.');
        return;
      }
    } catch (e) {
      print('세 번째 경로 미리 로드 실패: $e');
    }

    print('모든 미리 로드 시도가 실패했습니다. LoadPapsStandards 클래스에서 폴백 데이터를 사용할 것입니다.');
  } catch (e) {
    print('팝스 기준표 미리 로드 중 오류 발생: $e');
  }
}

/// 앱의 루트 위젯
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  // 앱 생명주기 감지를 위한 옵저버 등록
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // 마지막 앱 다시 활성화 시간
  DateTime? _lastResumeTime;
  // 최소 체크 간격 (밀리초)
  static const _minResumeCheckInterval = 5000; // 5초
  
  // 앱 생명주기 변경 감지 - 최적화 버전
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // 앱이 다시 포그라운드로 돌아왔을 때
    if (state == AppLifecycleState.resumed) {
      // 지나치게 자주 호출되지 않도록 시간 제한 검사
      final now = DateTime.now();
      if (_lastResumeTime != null && 
          now.difference(_lastResumeTime!).inMilliseconds < _minResumeCheckInterval) {
        debugPrint('앱 활성화 인증 상태 체크 무시: 최근에 이미 체크함');
        return;
      }
      
      _lastResumeTime = now;
      debugPrint('앱이 다시 활성화됨 - 인증 상태 확인');
      
      // 인증 상태 다시 확인
      final authCubit = di.sl<AuthCubit>();
      authCubit.checkAuthState();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // BlocProvider들은 생성 순서가 중요할 수 있음
        // 인증 Cubit 제공 (가장 먼저)
        BlocProvider<AuthCubit>(
          create: (context) => di.sl<AuthCubit>(),
          lazy: false, // 앱 실행 시 즉시 생성
        ),
        
        // 팝스 Cubit 제공
        BlocProvider<PapsCubit>(
          create: (context) => di.sl<PapsCubit>(),
        ),
        
        // 교사 설정 Cubit 제공
        BlocProvider<TeacherSettingsCubit>(
          create: (context) => di.sl<TeacherSettingsCubit>(),
        ),
        
        // 관리자 Cubit 제공
        BlocProvider<AdminCubit>(
          create: (context) => di.sl<AdminCubit>(),
        ),
        
        // 학생 Cubit 제공
        BlocProvider<StudentCubit>(
          create: (context) => di.sl<StudentCubit>(),
        ),
        
        // 학교 선택 Cubit 제공
        BlocProvider<SchoolCubit>(
          create: (context) => di.sl<SchoolCubit>(),
        ),
      ],
      child: MaterialApp.router(
        title: '온라인 팝스',
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          // 에러 핸들링 위젯 추가
          return Material(
            type: MaterialType.transparency,
            child: ErrorHandler(
              child: child ?? const SizedBox.shrink(),
            ),
          );
        },
      ),
    );
  }
}

/// 앱 전역 에러 핸들러
class ErrorHandler extends StatelessWidget {
  final Widget child;
  
  const ErrorHandler({super.key, required this.child});
  
  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      onError: (error, stack) {
        debugPrint('앱 에러 발생: $error');
        debugPrint('스택 트레이스: $stack');
        
        // 오류 발생 시 BlocProvider에 접근하면 더 큰 문제가 될 수 있으므로,
        // 단순히 기본 오류 위젯 표시
      },
      child: child,
    );
  }
}

/// 에러 경계 위젯
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Function(Object error, StackTrace stackTrace)? onError;
  
  const ErrorBoundary({super.key, required this.child, this.onError});
  
  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  bool _hasError = false;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _hasError = false;
  }
  
  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      // 오류 발생 시 기본 복구 UI
      return Material(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              const SizedBox(height: 16),
              const Text(
                '오류가 발생했습니다.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('앱에 예기치 않은 문제가 발생했습니다.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _hasError = false;
                  });
                },
                child: const Text('다시 시도'),
              )
            ],
          ),
        ),
      );
    }
    
    return widget.child;
  }
  
  @override
  void catchError(Object error, StackTrace stackTrace) {
    setState(() {
      _hasError = true;
    });
    
    if (widget.onError != null) {
      widget.onError!(error, stackTrace);
    }
  }
}
