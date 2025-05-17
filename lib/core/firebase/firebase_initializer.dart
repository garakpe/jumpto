import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'firebase_data_seed.dart';

import '../../firebase_options.dart';

/// Firebase 초기화를 담당하는 클래스
class FirebaseInitializer {
  // 초기화 상태 추적
  static bool _isInitialized = false;
  
  /// Firebase 초기화 - 안정적인 순차 방식
  static Future<void> initialize() async {
    // 이미 초기화되었으면 중복 초기화 방지
    if (_isInitialized) {
      return;
    }
    
    try {
      // 기본 Firebase 옵션을 사용하여 초기화
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      
      debugPrint('Firebase가 성공적으로 초기화되었습니다.');
      
      // 개발 모드에서만 테스트 데이터 시드 실행 - 비동기 방식
      if (kDebugMode) {
        try {
          // 비동기로 시드 데이터 실행하여 성능 영향 최소화
          final firebaseDataSeed = FirebaseDataSeed(
            FirebaseAuth.instance,
            FirebaseFirestore.instance,
          );
          firebaseDataSeed.seedTestData().then((_) {
            debugPrint('테스트 데이터 시드가 완료되었습니다.');
          }).catchError((e) {
            debugPrint('테스트 데이터 시드 실패: $e');
          });
        } catch (e) {
          // 시드 오류는 액티비티에 영향을 주지 않음
          debugPrint('테스트 데이터 시드 호출 오류: $e');
        }
      }
      
      _isInitialized = true;
    } catch (e) {
      debugPrint('Firebase 초기화 중 오류 발생: $e');
      rethrow;
    }
  }
  
  /// 안정적인 방식으로 Firebase 초기화 검사
  static bool isInitialized() {
    return _isInitialized;
  }
}