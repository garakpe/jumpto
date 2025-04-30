import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Firebase Authentication 서비스
class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 현재 로그인한 사용자 가져오기
  User? get currentUser => _firebaseAuth.currentUser;

  /// 인증 상태 스트림
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// 이메일/비밀번호로 회원가입
  Future<UserCredential> signUpWithEmailPassword({
    required String email,
    required String password,
    required String displayName,
    required String role,
    String? schoolId,
  }) async {
    try {
      // 계정 생성
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // 사용자 정보 업데이트
      await userCredential.user?.updateDisplayName(displayName);
      
      // Firestore에 사용자 정보 저장
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': email,
          'displayName': displayName,
          'role': role,
          'schoolId': schoolId,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      
      return userCredential;
    } catch (e) {
      print('회원가입 오류: $e');
      rethrow;
    }
  }

  /// 이메일/비밀번호로 로그인
  Future<UserCredential> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('로그인 오류: $e');
      rethrow;
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  /// 비밀번호 재설정 이메일 전송
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  /// 비밀번호 변경
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('로그인 상태가 아닙니다.');
    }

    // 현재 비밀번호로 재인증
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    
    await user.reauthenticateWithCredential(credential);
    
    // 새 비밀번호로 업데이트
    await user.updatePassword(newPassword);
  }
}
