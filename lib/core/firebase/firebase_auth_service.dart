import 'package:firebase_auth/firebase_auth.dart';

/// Firebase 인증 서비스
///
/// Firebase Authentication과 상호작용하는 서비스
class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 현재 로그인된 사용자 가져오기
  User? get currentUser => _auth.currentUser;

  /// 이메일/비밀번호로 로그인
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// 이메일/비밀번호로 회원가입
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// 로그아웃
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// 인증 상태 변경 스트림
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}