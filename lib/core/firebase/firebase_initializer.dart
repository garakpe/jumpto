import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'firebase_data_seed.dart';

import '../../firebase_options.dart';

/// Firebase 초기화를 담당하는 클래스
class FirebaseInitializer {
  /// Firebase 초기화
  static Future<void> initialize() async {
    try {
      // 자동 생성된 옵션을 사용하여 Firebase 초기화
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      
      debugPrint('Firebase가 성공적으로 초기화되었습니다.');
      
      // 개발 모드에서만 테스트 데이터 시드 실행
      if (kDebugMode) {
        debugPrint('테스트 데이터 시드를 실행합니다...');
        final firebaseDataSeed = FirebaseDataSeed(
          FirebaseAuth.instance,
          FirebaseFirestore.instance,
        );
        await firebaseDataSeed.seedTestData();
      }
    } catch (e) {
      debugPrint('Firebase 초기화 중 오류 발생: $e');
      rethrow;
    }
  }
}
