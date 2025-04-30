import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 싱글톤 GetIt 인스턴스
final sl = GetIt.instance;

/// 의존성 주입 초기화
/// 모든 서비스, 리포지토리, 유스케이스, BLoC 등록
Future<void> init() async {
  //! External
  // Firebase
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  
  //! Features - Auth
  // Data Sources
  
  // Repositories
  
  // Use Cases
  
  // BLoC
  
  //! Features - PAPS
  // Data Sources
  
  // Repositories
  
  // Use Cases
  
  // BLoC
  
  //! Core
}
