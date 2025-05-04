import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:universal_html/html.dart' as html;

import 'core/firebase/firebase_data_seed.dart';

import 'core/presentation/theme/app_theme.dart';
import 'core/routes/app_router.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/paps/presentation/cubit/paps_cubit.dart';
import 'firebase_options.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // 의존성 주입 초기화
  await di.initializeDependencies();
  
  // 테스트 데이터 시드 실행
  await di.sl<FirebaseDataSeed>().seedTestData();
  
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
      final response = await html.window.fetch('assets/data/paps_standards.json');
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
      final response = await html.window.fetch('/assets/data/paps_standards.json');
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
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // 인증 Cubit 제공
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(
            signInWithEmailPassword: di.sl(),
            getCurrentUser: di.sl(),
            registerTeacher: di.sl(),
            signInStudent: di.sl(),
          ),
        ),
        // 팝스 Cubit 제공
        BlocProvider<PapsCubit>(
          create: (context) => PapsCubit(
            getPapsStandards: di.sl(),
            calculatePapsGrade: di.sl(),
            savePapsRecord: di.sl(),
            getStudentPapsRecords: di.sl(),
          ),
        ),
      ],
      child: MaterialApp.router(
        title: '온라인 팝스',
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}