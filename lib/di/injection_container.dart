import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/network/network_info.dart';
import '../core/usecases/usecase.dart';
import '../features/auth/data/datasources/auth_local_data_source.dart';
import '../features/auth/data/datasources/auth_remote_data_source.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/get_current_user.dart';
import '../features/auth/domain/usecases/register_teacher.dart';
import '../features/auth/domain/usecases/sign_in_student.dart';
import '../features/auth/domain/usecases/sign_in_with_email_password.dart';
import '../features/auth/domain/usecases/sign_out.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/paps/data/datasources/paps_local_data_source.dart';
import '../features/paps/data/datasources/paps_remote_data_source.dart';
import '../features/paps/data/repositories/paps_repository_impl.dart';
import '../features/paps/domain/repositories/paps_repository.dart';
import '../features/paps/domain/usecases/calculate_paps_grade.dart';
import '../features/paps/domain/usecases/get_paps_standards.dart';
import '../features/paps/domain/usecases/get_student_paps_records.dart';
import '../features/paps/domain/usecases/load_paps_standards.dart';
import '../features/paps/domain/usecases/save_paps_record.dart';
import '../features/paps/presentation/cubit/paps_cubit.dart';
import '../features/teacher_dashboard/data/datasources/teacher_settings_remote_data_source.dart';
import '../features/teacher_dashboard/data/repositories/teacher_settings_repository_impl.dart';
import '../features/teacher_dashboard/domain/repositories/teacher_settings_repository.dart';
import '../features/teacher_dashboard/domain/usecases/get_teacher_settings.dart';
import '../features/teacher_dashboard/domain/usecases/save_teacher_settings.dart';
import '../features/teacher_dashboard/presentation/cubit/teacher_settings_cubit.dart';

/// 서비스 로케이터 인스턴스
final sl = GetIt.instance;

/// 의존성 주입 초기화
Future<void> init() async {
  // External
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  
  // SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  
  // Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  
  // Features - Auth
  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl(), sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );
  
  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl()),
  );
  
  // Use Cases
  sl.registerLazySingleton(() => SignInWithEmailPassword(sl()));
  sl.registerLazySingleton(() => SignInStudent(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => RegisterTeacher(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  
  // BLoC
  sl.registerFactory(
    () => AuthCubit(
      signInWithEmailPassword: sl(),
      signInStudent: sl(),
      getCurrentUser: sl(),
      registerTeacher: sl(),
      signOut: sl(),
    ),
  );
  
  // Features - PAPS
  // Data Sources
  sl.registerLazySingleton<PapsLocalDataSource>(
    () => PapsLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<PapsRemoteDataSource>(
    () => PapsRemoteDataSourceImpl(sl()),
  );
  
  // Repositories
  sl.registerLazySingleton<PapsRepository>(
    () => PapsRepositoryImpl(sl(), sl()),
  );
  
  // Use Cases
  sl.registerLazySingleton(() => LoadPapsStandards());
  sl.registerLazySingleton(() => GetPapsStandards(sl()));
  sl.registerLazySingleton(() => CalculatePapsGrade(sl()));
  sl.registerLazySingleton(() => SavePapsRecord(sl()));
  sl.registerLazySingleton(() => GetStudentPapsRecords(sl()));
  
  // BLoC
  sl.registerFactory(
    () => PapsCubit(
      loadPapsStandards: sl(),
      getPapsStandards: sl(),
      calculatePapsGrade: sl(),
      savePapsRecord: sl(),
      getStudentPapsRecords: sl(),
    ),
  );
  
  // Features - Teacher Dashboard
  // Data Sources
  sl.registerLazySingleton<TeacherSettingsRemoteDataSource>(
    () => TeacherSettingsRemoteDataSourceImpl(firestore: sl()),
  );
  
  // Repositories
  sl.registerLazySingleton<TeacherSettingsRepository>(
    () => TeacherSettingsRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  
  // Use Cases
  sl.registerLazySingleton(() => GetTeacherSettings(sl()));
  sl.registerLazySingleton(() => SaveTeacherSettings(sl()));
  
  // BLoC
  sl.registerFactory(
    () => TeacherSettingsCubit(
      getTeacherSettings: sl(),
      saveTeacherSettings: sl(),
    ),
  );
  
  // NoParams 인스턴스
  sl.registerLazySingleton<NoParams>(() => NoParams());
}