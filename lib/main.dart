import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  
  runApp(const MyApp());
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
