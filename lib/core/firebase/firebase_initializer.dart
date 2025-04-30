import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

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
      
      print('Firebase가 성공적으로 초기화되었습니다.');
    } catch (e) {
      print('Firebase 초기화 중 오류 발생: $e');
      rethrow;
    }
  }
}
