import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../domain/entities/user.dart' as domain;

/// 인증 원격 데이터 소스 인터페이스
abstract class AuthRemoteDataSource {
  /// 현재 인증된 사용자 가져오기
  Future<domain.User?> getCurrentUser();

  /// 이메일/비밀번호로 교사 회원가입
  Future<domain.User> signUpTeacher({
    required String email,
    required String password,
    required String displayName,
    String? schoolId,
    String? phoneNumber,
  });

  /// 학생 계정 생성 (교사에 의해)
  Future<domain.User> createStudentAccount({
    required String displayName,
    required String studentNum,
    required String classNum,
    required String gender,
    String? initialPassword,
  });

  /// 이메일/비밀번호로 로그인
  Future<domain.User> signInWithEmailPassword({
    required String email,
    required String password,
  });

  /// 학번/비밀번호로 학생 로그인
  Future<domain.User> signInStudent({
    required String schoolId,
    required String studentId,
    required String password,
  });

  /// 로그아웃
  Future<void> signOut();

  /// 비밀번호 재설정 이메일 전송
  Future<void> sendPasswordResetEmail(String email);

  /// 비밀번호 변경
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  });

  /// 학생 비밀번호 초기화 (교사에 의해)
  Future<void> resetStudentPassword({
    required String studentId,
    required String newPassword,
  });

  /// 인증 상태 스트림
  Stream<domain.User?> get authStateChanges;
}

/// 인증 원격 데이터 소스 구현체
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  /// 사용자 컬렉션 참조
  CollectionReference get _usersCollection => _firestore.collection('users');

  /// 학생 컬렉션 참조
  CollectionReference get _studentsCollection =>
      _firestore.collection('students');

  AuthRemoteDataSourceImpl(this._firebaseAuth, this._firestore);

  @override
  Future<domain.User?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) {
      return null;
    }

    return _getUserData(firebaseUser.uid);
  }

  /// Firebase 인증 사용자 ID로 사용자 정보 가져오기
  /// Firebase 인증 사용자 ID로 사용자 정보 가져오기
  Future<domain.User?> _getUserData(String uid) async {
    try {
      // 사용자 컬렉션에서 조회
      final userDoc = await _usersCollection.doc(uid).get();
      final userData = userDoc.data() as Map<String, dynamic>?;

      if (userData == null) {
        return null;
      }

      // 사용자 데이터 파싱
      final role =
          userData['role'] == 'teacher'
              ? domain.UserRole.teacher
              : domain.UserRole.student;

      // isApproved 필드 추가
      final bool isApproved = userData['isApproved'] == true;

      return domain.User(
        id: uid,
        email: userData['email'],
        displayName: userData['displayName'],
        role: role,
        schoolId: userData['schoolId'],
        classNum: userData['classNum'],
        studentNum: userData['studentNum'],
        studentId: userData['studentId'],
        gender: userData['gender'],
        phoneNumber: userData['phoneNumber'],
        isApproved: isApproved, // isApproved 필드 추가
      );
    } catch (e) {
      print('사용자 데이터 가져오기 오류: $e');
      rethrow;
    }
  }

  @override
  Future<domain.User> signUpTeacher({
    required String email,
    required String password,
    required String displayName,
    String? schoolId,
    String? phoneNumber,
  }) async {
    try {
      // Firebase Auth로 계정 생성
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;

      // Firestore에 교사 정보 저장
      await _usersCollection.doc(uid).set({
        'email': email,
        'displayName': displayName,
        'role': 'teacher',
        'schoolId': schoolId,
        'phoneNumber': phoneNumber,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 사용자 데이터 반환
      return domain.User(
        id: uid,
        email: email,
        displayName: displayName,
        role: domain.UserRole.teacher,
        schoolId: schoolId,
        phoneNumber: phoneNumber,
      );
    } catch (e) {
      print('교사 회원가입 오류: $e');
      rethrow;
    }
  }

  @override
  Future<domain.User> createStudentAccount({
    required String displayName,
    required String studentNum,
    required String classNum,
    required String gender,
    String? initialPassword,
  }) async {
    try {
      // 현재 로그인한 교사 ID 가져오기
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw Exception('로그인이 필요합니다.');
      }

      final teacherId = currentUser.uid;

      // 교사 정보 가져오기
      final teacherDoc = await _usersCollection.doc(teacherId).get();
      final teacherData = teacherDoc.data() as Map<String, dynamic>;

      if (teacherData['role'] != 'teacher') {
        throw Exception('교사만 학생 계정을 생성할 수 있습니다.');
      }

      final schoolId = teacherData['schoolId'];

      // 비밀번호 설정 (기본값: 학번)
      final password = initialPassword ?? studentNum;

      // 학생 이메일 형식 (예: schoolId-classNum-studentNum@school.com)
      final studentEmail = '$schoolId-$classNum-$studentNum@school.com';

      // Firebase Auth로 학생 계정 생성
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: studentEmail,
        password: password,
      );

      final uid = userCredential.user!.uid;

      // Firestore에 학생 정보 저장
      await _usersCollection.doc(uid).set({
        'email': studentEmail,
        'displayName': displayName,
        'role': 'student',
        'schoolId': schoolId,
        'classNum': classNum,
        'studentNum': studentNum,
        'studentId': '$classNum$studentNum',
        'gender': gender,
        'teacherId': teacherId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 학생 컬렉션에도 정보 저장
      await _studentsCollection.doc(uid).set({
        'email': studentEmail,
        'displayName': displayName,
        'schoolId': schoolId,
        'classNum': classNum,
        'studentNum': studentNum,
        'studentId': '$classNum$studentNum',
        'gender': gender,
        'teacherId': teacherId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 사용자 데이터 반환
      return domain.User(
        id: uid,
        email: studentEmail,
        displayName: displayName,
        role: domain.UserRole.student,
        schoolId: schoolId,
        classNum: classNum,
        studentNum: studentNum,
        studentId: '$classNum$studentNum',
        gender: gender,
      );
    } catch (e) {
      print('학생 계정 생성 오류: $e');
      rethrow;
    }
  }

  @override
  Future<domain.User> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;
      final userData = await _getUserData(uid);

      if (userData == null) {
        throw Exception('사용자 정보를 찾을 수 없습니다.');
      }

      // 교사 계정인 경우 승인 여부 확인
      if (userData.role == domain.UserRole.teacher) {
        final userDoc = await _usersCollection.doc(uid).get();
        final userDocData = userDoc.data() as Map<String, dynamic>;

        if (userDocData['isApproved'] != true) {
          await _firebaseAuth.signOut();
          throw Exception('관리자의 승인이 필요합니다.');
        }
      }

      return userData;
    } catch (e) {
      print('이메일/비밀번호 로그인 오류: $e');
      rethrow;
    }
  }

  @override
  Future<domain.User> signInStudent({
    required String schoolId,
    required String studentId,
    required String password,
  }) async {
    try {
      // 학생 이메일 형식으로 변환
      // 실제 구현에서는 학급 정보도 필요할 수 있음
      final query =
          await _studentsCollection
              .where('schoolId', isEqualTo: schoolId)
              .where('studentId', isEqualTo: studentId)
              .get();

      if (query.docs.isEmpty) {
        throw Exception('학생 정보를 찾을 수 없습니다.');
      }

      final studentData = query.docs.first.data() as Map<String, dynamic>;
      final email = studentData['email'];

      // 이메일/비밀번호로 로그인
      return signInWithEmailPassword(email: email, password: password);
    } catch (e) {
      print('학생 로그인 오류: $e');
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw Exception('로그인이 필요합니다.');
      }

      // 재인증 필요
      final email = currentUser.email;
      if (email == null) {
        throw Exception('이메일 정보가 없습니다.');
      }

      final credential = firebase_auth.EmailAuthProvider.credential(
        email: email,
        password: oldPassword,
      );

      await currentUser.reauthenticateWithCredential(credential);

      // 비밀번호 변경
      await currentUser.updatePassword(newPassword);
    } catch (e) {
      print('비밀번호 변경 오류: $e');
      rethrow;
    }
  }

  @override
  Future<void> resetStudentPassword({
    required String studentId,
    required String newPassword,
  }) async {
    try {
      // 교사 권한 확인
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw Exception('로그인이 필요합니다.');
      }

      final teacherId = currentUser.uid;
      final teacherDoc = await _usersCollection.doc(teacherId).get();
      final teacherData = teacherDoc.data() as Map<String, dynamic>;

      if (teacherData['role'] != 'teacher') {
        throw Exception('교사만 학생 비밀번호를 초기화할 수 있습니다.');
      }

      // 학생 정보 확인
      final studentDoc = await _studentsCollection.doc(studentId).get();
      final studentData = studentDoc.data() as Map<String, dynamic>;

      if (studentData['teacherId'] != teacherId) {
        throw Exception('자신의 학급 학생만 비밀번호를 초기화할 수 있습니다.');
      }

      // 관리자 권한으로 비밀번호 초기화 (실제로는 Firebase Admin SDK가 필요)
      // 여기서는 사용자 인증 토큰을 사용한 서버 측 코드가 필요합니다
      throw UnimplementedError('Firebase Admin SDK가 필요한 기능입니다.');
    } catch (e) {
      print('학생 비밀번호 초기화 오류: $e');
      rethrow;
    }
  }

  @override
  Stream<domain.User?> get authStateChanges =>
      _firebaseAuth.authStateChanges().asyncMap(
        (firebaseUser) =>
            firebaseUser != null ? _getUserData(firebaseUser.uid) : null,
      );
}
