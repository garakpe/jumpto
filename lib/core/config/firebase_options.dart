import 'package:firebase_core/firebase_core.dart';

/// Firebase 설정 클래스
/// 실제 값은 Firebase 프로젝트 생성 후 FirebaseOptions를 생성하여 업데이트 필요
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // 웹 플랫폼용 설정
    return const FirebaseOptions(
      apiKey: "AIzaSyBlcpprW4AokEkqOyim8VpvT5wTJ4OEsD8",
      authDomain: "jumpto-web.firebaseapp.com",
      projectId: "jumpto-web",
      storageBucket: "jumpto-web.firebasestorage.app",
      messagingSenderId: "515477990903",
      appId: "1:515477990903:web:5f791725de93e3daf792f2",
    );
  }
}
