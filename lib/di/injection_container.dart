import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/firebase/admin_seed.dart';
import '../core/firebase/cloud_functions_service.dart';
import '../core/network/network_info.dart';
import '../core/usecases/usecase.dart';
import '../features/admin/data/datasources/admin_remote_data_source.dart';
import '../features/admin/data/repositories/admin_repository_impl.dart';
import '../features/admin/domain/repositories/admin_repository.dart';
import '../features/admin/domain/usecases/approve_teacher.dart';
import '../features/admin/domain/usecases/get_pending_teachers.dart';
import '../features/admin/domain/usecases/sign_in_admin.dart';
import '../features/admin/presentation/cubit/admin_cubit.dart';
import '../features/auth/data/datasources/auth_local_data_source.dart';
import '../features/auth/data/datasources/auth_remote_data_source.dart';
import '../features/auth/data/datasources/student_remote_datasource.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/data/repositories/student_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/repositories/student_repository.dart';
import '../features/auth/domain/usecases/get_current_user.dart';
import '../features/auth/domain/usecases/get_students_by_teacher.dart';
import '../features/auth/domain/usecases/register_teacher.dart';
import '../features/auth/domain/usecases/sign_in_student.dart';
import '../features/auth/domain/usecases/sign_in_with_email_password.dart';
import '../features/auth/domain/usecases/login_with_email_password.dart';
import '../features/auth/domain/usecases/sign_out.dart';
import '../features/auth/domain/usecases/update_student_gender.dart';
import '../features/auth/domain/usecases/upload_students.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/auth/presentation/cubit/student_cubit.dart';
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
import '../features/common/data/datasources/school_local_data_source.dart';
import '../features/common/data/repositories/school_repository_impl.dart';
import '../features/common/domain/repositories/school_repository.dart';
import '../features/common/domain/usecases/get_regions.dart';
import '../features/common/domain/usecases/get_schools_by_region.dart';
import '../features/common/domain/usecases/search_schools.dart';
import '../features/common/presentation/cubit/school_cubit.dart';

/// 서비스 로케이터 인스턴스
final sl = GetIt.instance;

/// 의존성 주입 초기화
Future<void> init() async {
  // 초기 관리자 계정 생성
  final adminSeed = AdminSeed(FirebaseAuth.instance, FirebaseFirestore.instance);
  await adminSeed.seedAdminUser();
  // External
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFunctions>(() => FirebaseFunctions.instance);
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerLazySingleton<CloudFunctionsService>(() => CloudFunctionsService(functions: sl()));
  
  // SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  
  // Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  
  // Features - Auth
  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl(), sl(), sl()),
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
  sl.registerLazySingleton(() => LoginWithEmailPassword(sl()));
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
  
  // Features - Students
  // Data Sources
  sl.registerLazySingleton<StudentRemoteDataSource>(
    () => StudentRemoteDataSourceImpl(
      firestore: sl(), 
      auth: sl(), 
      cloudFunctionsService: sl()
    ),
  );
  
  // Repositories
  sl.registerLazySingleton<StudentRepository>(
    () => StudentRepositoryImpl(remoteDataSource: sl()),
  );
  
  // Use Cases
  sl.registerLazySingleton(() => GetStudentsByTeacher(sl()));
  sl.registerLazySingleton(() => UploadStudents(sl()));
  sl.registerLazySingleton(() => UpdateStudentGender(sl()));
  
  // BLoC
  sl.registerFactory(
    () => StudentCubit(
      getStudentsByTeacher: sl(),
      uploadStudents: sl(),
      getCurrentUser: sl(),
      updateStudentGender: sl(),
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
  
  // Features - Common (School)
  // Data Sources
  sl.registerLazySingleton<SchoolLocalDataSource>(
    () => SchoolLocalDataSourceImpl(),
  );
  
  // Repositories
  sl.registerLazySingleton<SchoolRepository>(
    () => SchoolRepositoryImpl(sl()),
  );
  
  // Use Cases
  sl.registerLazySingleton(() => GetRegions(sl()));
  sl.registerLazySingleton(() => GetSchoolsByRegion(sl()));
  sl.registerLazySingleton(() => SearchSchools(sl()));
  
  // BLoC
  sl.registerFactory(
    () => SchoolCubit(
      getRegions: sl(),
      getSchoolsByRegion: sl(),
      searchSchools: sl(),
    ),
  );
  
  // Features - Admin
  // Data Sources
  sl.registerLazySingleton<AdminRemoteDataSource>(
    () => AdminRemoteDataSourceImpl(sl(), sl()),
  );
  
  // Repositories
  sl.registerLazySingleton<AdminRepository>(
    () => AdminRepositoryImpl(sl()),
  );
  
  // Use Cases
  sl.registerLazySingleton(() => SignInAdmin(sl()));
  sl.registerLazySingleton(() => GetPendingTeachers(sl()));
  sl.registerLazySingleton(() => ApproveTeacher(sl()));
  
  // BLoC
  sl.registerFactory(
    () => AdminCubit(
      signInAdmin: sl(),
      getPendingTeachers: sl(),
      approveTeacher: sl(),
      adminRepository: sl(),
    ),
  );
  
  // NoParams 인스턴스
  sl.registerLazySingleton<NoParams>(() => NoParams());
}