import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 최초 관리자 계정 생성 클래스
///
/// 앱 초기 실행 시 관리자 계정을 생성합니다.
/// 이미 생성되었다면 실행되지 않습니다.
class AdminSeed {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  
  /// 관리자 계정 생성 완료 여부 키
  static const String _adminCreatedKey = 'admin_created';
  
  AdminSeed(this._firebaseAuth, this._firestore);
  
  /// 관리자 계정 생성 실행
  Future<void> seedAdminUser() async {
    try {
      // 이미 생성되었는지 확인
      final prefs = await SharedPreferences.getInstance();
      final alreadyCreated = prefs.getBool(_adminCreatedKey) ?? false;
      
      if (alreadyCreated) {
        debugPrint('관리자 계정이 이미 생성되어 있습니다.');
        return;
      }
      
      // Firestore에서 관리자 계정 확인
      final adminQuery = await _firestore.collection('users')
          .where('role', isEqualTo: 'admin')
          .limit(1)
          .get();
      
      if (adminQuery.docs.isNotEmpty) {
        // 이미 관리자 계정이 있으면 플래그 설정 후 종료
        await prefs.setBool(_adminCreatedKey, true);
        debugPrint('관리자 계정이 이미 데이터베이스에 존재합니다.');
        return;
      }
      
      // 초기 관리자 계정 정보
      const adminUsername = 'admin';
      const adminPassword = 'admin123'; // 실제 운영 환경에서는 강력한 비밀번호 사용
      const adminEmail = 'admin@admin.com';
      
      // Firebase Auth로 관리자 계정 생성
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: adminEmail,
        password: adminPassword,
      );
      
      final uid = userCredential.user!.uid;
      
      // Firestore에 관리자 정보 저장
      await _firestore.collection('users').doc(uid).set({
        'email': adminEmail,
        'displayName': '관리자',
        'username': adminUsername,
        'role': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      // 관리자 계정 생성 완료 표시
      await prefs.setBool(_adminCreatedKey, true);
      
      // 관리자 계정 생성 후 로그아웃
      await _firebaseAuth.signOut();
      
      debugPrint('관리자 계정이 성공적으로 생성되었습니다.');
      debugPrint('관리자 로그인 정보: 아이디=$adminUsername, 비밀번호=$adminPassword');
    } catch (e) {
      debugPrint('관리자 계정 생성 오류: $e');
    }
  }
  
  /// 관리자 계정 생성 여부 확인
  Future<bool> isAdminCreated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_adminCreatedKey) ?? false;
  }
}