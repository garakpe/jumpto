import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase 초기화를 담당하는 클래스
class FirebaseInitializer {
  /// Firebase 초기화
  static Future<void> initialize() async {
    try {
      // Web 환경에서의 Firebase 초기화 설정
      if (kIsWeb) {
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: "REPLACE_WITH_API_KEY",
            authDomain: "REPLACE_WITH_AUTH_DOMAIN",
            projectId: "REPLACE_WITH_PROJECT_ID",
            storageBucket: "REPLACE_WITH_STORAGE_BUCKET",
            messagingSenderId: "REPLACE_WITH_MESSAGING_SENDER_ID",
            appId: "REPLACE_WITH_APP_ID",
            measurementId: "REPLACE_WITH_MEASUREMENT_ID"
          ),
        );
      } else {
        // 기본 설정으로 초기화 (Firebase CLI로 생성된 설정 파일 사용)
        await Firebase.initializeApp();
      }
      
      print('Firebase가 성공적으로 초기화되었습니다.');
    } catch (e) {
      print('Firebase 초기화 중 오류 발생: $e');
      rethrow;
    }
  }
}
