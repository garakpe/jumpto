import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/sign_in_with_email_password.dart';
import 'features/paps/data/datasources/paps_local_data_source.dart';
import 'features/paps/data/datasources/paps_remote_data_source.dart';
import 'features/paps/data/repositories/paps_repository_impl.dart';
import 'features/paps/domain/repositories/paps_repository.dart';
import 'features/paps/domain/usecases/calculate_paps_grade.dart';
import 'features/paps/domain/usecases/load_paps_standards.dart';

/// 서비스 로케이터 인스턴스
final sl = GetIt.instance;

/// 의존성 주입 초기화
Future<void> initializeDependencies() async {
  // 외부 서비스
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  
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
  sl.registerLazySingleton<SignInWithEmailPassword>(
    () => SignInWithEmailPassword(sl()),
  );
  
  // BLoC/Cubit (추후 구현 예정)
}
