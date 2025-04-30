import 'package:firebase_core/firebase_core.dart';

/// Firebase 설정 클래스
/// 실제 값은 Firebase 프로젝트 생성 후 FirebaseOptions를 생성하여 업데이트 필요
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // 웹 플랫폼용 설정
    return const FirebaseOptions(
      apiKey: 'YOUR_API_KEY', // Firebase 콘솔에서 가져온 값으로 교체 필요
      appId: 'YOUR_APP_ID', // Firebase 콘솔에서 가져온 값으로 교체 필요
      messagingSenderId: 'YOUR_MESSAGING_SENDER_ID', // Firebase 콘솔에서 가져온 값으로 교체 필요
      projectId: 'YOUR_PROJECT_ID', // Firebase 콘솔에서 가져온 값으로 교체 필요
      authDomain: 'YOUR_AUTH_DOMAIN', // Firebase 콘솔에서 가져온 값으로 교체 필요
      storageBucket: 'YOUR_STORAGE_BUCKET', // Firebase 콘솔에서 가져온 값으로 교체 필요
    );
  }
}
