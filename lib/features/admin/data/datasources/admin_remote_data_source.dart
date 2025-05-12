import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../../auth/domain/entities/user.dart' as domain;

/// 관리자 원격 데이터 소스 인터페이스
abstract class AdminRemoteDataSource {
  /// 관리자 로그인
  Future<domain.User> signInAdmin({
    required String username,
    required String password,
  });

  /// 승인 대기 중인 교사 목록 조회
  Future<List<domain.User>> getPendingTeachers();

  /// 교사 계정 승인
  Future<void> approveTeacher(String teacherId);

  /// 교사 계정 거부/삭제
  Future<void> rejectTeacher(String teacherId);

  /// 모든 교사 목록 조회
  Future<List<domain.User>> getAllTeachers();

  /// 관리자 로그아웃
  Future<void> signOut();
}

/// 관리자 원격 데이터 소스 구현체
class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  /// 사용자 컬렉션 참조
  CollectionReference get _usersCollection => _firestore.collection('users');

  AdminRemoteDataSourceImpl(this._firebaseAuth, this._firestore);

  @override
  Future<domain.User> signInAdmin({
    required String username,
    required String password,
  }) async {
    try {
      // 관리자 이메일은 username@admin.com 형식으로 저장
      final email = '$username@admin.com';

      // Firebase Auth로 로그인
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;

      // Firestore에서 사용자 정보 조회
      final userDoc = await _usersCollection.doc(uid).get();
      final userData = userDoc.data() as Map<String, dynamic>?;

      if (userData == null) {
        throw Exception('관리자 정보를 찾을 수 없습니다.');
      }

      // 관리자 역할 확인
      if (userData['role'] != 'admin') {
        await _firebaseAuth.signOut(); // 로그아웃
        throw Exception('관리자 권한이 없습니다.');
      }

      // 관리자 정보 반환
      return domain.User(
        id: uid,
        email: email,
        displayName: userData['displayName'] ?? '관리자',
        role: domain.UserRole.admin,
      );
    } catch (e) {
      print('관리자 로그인 오류: $e');
      rethrow;
    }
  }

  @override
  Future<List<domain.User>> getPendingTeachers() async {
    try {
      // 승인 대기 중인 교사 목록 조회
      final query =
          await _usersCollection
              .where('role', isEqualTo: 'teacher')
              .where('isApproved', isEqualTo: false)
              .get();

      // 결과 변환
      final List<domain.User> teachers = [];
      for (final doc in query.docs) {
        final data = doc.data() as Map<String, dynamic>;
        teachers.add(
          domain.User(
            id: doc.id,
            email: data['email'],
            displayName: data['displayName'],
            role: domain.UserRole.teacher,
            schoolCode: data['schoolCode'],
            phoneNumber: data['phoneNumber'],
            isApproved: false,
          ),
        );
      }

      return teachers;
    } catch (e) {
      print('승인 대기 중인 교사 목록 조회 오류: $e');
      rethrow;
    }
  }

  @override
  Future<void> approveTeacher(String teacherId) async {
    try {
      // 교사 계정 승인 (isApproved 필드 업데이트)
      await _usersCollection.doc(teacherId).update({'isApproved': true});
    } catch (e) {
      print('교사 계정 승인 오류: $e');
      rethrow;
    }
  }

  @override
  Future<void> rejectTeacher(String teacherId) async {
    try {
      // 먼저 해당 교사의 이메일 조회
      final userDoc = await _usersCollection.doc(teacherId).get();
      final userData = userDoc.data() as Map<String, dynamic>?;

      if (userData == null) {
        throw Exception('교사 정보를 찾을 수 없습니다.');
      }

      // 교사 계정 삭제
      await _usersCollection.doc(teacherId).delete();

      // 실제 Firebase Authentication 계정 삭제는 Admin SDK가 필요하므로
      // 여기서는 구현하지 않습니다. Cloud Functions 등을 통해 처리해야 합니다.
      // TODO: Firebase Admin SDK를 통한 계정 삭제 구현
    } catch (e) {
      print('교사 계정 거부/삭제 오류: $e');
      rethrow;
    }
  }

  @override
  Future<List<domain.User>> getAllTeachers() async {
    try {
      // 모든 교사 목록 조회
      final query =
          await _usersCollection.where('role', isEqualTo: 'teacher').get();

      // 결과 변환
      final List<domain.User> teachers = [];
      for (final doc in query.docs) {
        final data = doc.data() as Map<String, dynamic>;
        teachers.add(
          domain.User(
            id: doc.id,
            email: data['email'],
            displayName: data['displayName'],
            role: domain.UserRole.teacher,
            schoolCode: data['schoolCode'],
            phoneNumber: data['phoneNumber'],
            isApproved: data['isApproved'] ?? false,
          ),
        );
      }

      return teachers;
    } catch (e) {
      print('모든 교사 목록 조회 오류: $e');
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
