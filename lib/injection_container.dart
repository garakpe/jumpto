import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import 'core/firebase/firebase_auth_service.dart';
import 'core/firebase/firebase_data_seed.dart';
import 'core/firebase/firebase_firestore_service.dart';
import 'core/usecases/usecase.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/get_current_user.dart';
import 'features/auth/domain/usecases/register_teacher.dart';
import 'features/auth/domain/usecases/sign_in_with_email_password.dart';
import 'features/auth/domain/usecases/sign_in_student.dart';
import 'features/paps/data/datasources/paps_local_data_source.dart';
import 'features/paps/data/datasources/paps_remote_data_source.dart';
import 'features/paps/data/repositories/paps_repository_impl.dart';
import 'features/paps/domain/repositories/paps_repository.dart';
import 'features/paps/domain/usecases/calculate_paps_grade.dart';
import 'features/paps/domain/usecases/get_paps_standards.dart';
import 'features/paps/domain/usecases/get_student_paps_records.dart';
import 'features/paps/domain/usecases/load_paps_standards.dart';
import 'features/paps/domain/usecases/save_paps_record.dart';

/// 서비스 로케이터 인스턴스
final sl = GetIt.instance;

/// 의존성 주입 초기화
Future<void> initializeDependencies() async {
  // 외부 서비스
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  
  // Firebase 서비스
  sl.registerLazySingleton<FirebaseAuthService>(() => FirebaseAuthService());
  sl.registerLazySingleton<FirebaseFirestoreService>(() => FirebaseFirestoreService());
  sl.registerLazySingleton<FirebaseDataSeed>(() => FirebaseDataSeed(sl(), sl()));
  
  // Data sources
  sl.registerLazySingleton<PapsLocalDataSource>(
    () => PapsLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<PapsRemoteDataSource>(
    () => PapsRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl(), sl()),
  );
  
  // Repositories
  sl.registerLazySingleton<PapsRepository>(
    () => PapsRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl()),
  );
  
  // Use cases
  sl.registerLazySingleton<LoadPapsStandards>(
    () => LoadPapsStandards(),
  );
  sl.registerLazySingleton<CalculatePapsGrade>(
    () => CalculatePapsGrade(sl()),
  );
  sl.registerLazySingleton<GetPapsStandards>(
    () => GetPapsStandards(sl()),
  );
  sl.registerLazySingleton<GetStudentPapsRecords>(
    () => GetStudentPapsRecords(sl()),
  );
  sl.registerLazySingleton<SavePapsRecord>(
    () => SavePapsRecord(sl()),
  );
  sl.registerLazySingleton<SignInWithEmailPassword>(
    () => SignInWithEmailPassword(sl()),
  );
  sl.registerLazySingleton<GetCurrentUser>(
    () => GetCurrentUser(sl()),
  );
  sl.registerLazySingleton<RegisterTeacher>(
    () => RegisterTeacher(sl()),
  );
  sl.registerLazySingleton<SignInStudent>(
    () => SignInStudent(sl()),
  );
  
  // NoParams 인스턴스
  sl.registerLazySingleton<NoParams>(() => NoParams());
}
