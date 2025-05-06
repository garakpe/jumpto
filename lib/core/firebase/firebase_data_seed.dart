import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// 테스트 데이터 시드 클래스
///
/// 테스트에 필요한 기본 데이터를 Firebase에 추가하는 클래스
class FirebaseDataSeed {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  FirebaseDataSeed(this._auth, this._firestore);

  /// 테스트 데이터 시드
  Future<void> seedTestData() async {
    await _seedTestTeacher();
    await _seedTestStudent();
  }

  /// 테스트용 교사 계정 생성
  Future<void> _seedTestTeacher() async {
    const email = 'teacher@test.com';
    const password = 'teacher123';
    const displayName = '테스트 교사';

    try {
      // 이미 존재하는지 확인
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 이미 존재하면 즉시 로그아웃하고 리턴
      await _auth.signOut();
      print('테스트 교사 계정이 이미 존재합니다.');
      return;
    } catch (e) {
      // 존재하지 않으면 계정 생성
      if (e is FirebaseAuthException && e.code == 'user-not-found') {
        try {
          final userCredential = await _auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );

          // Firestore에 교사 정보 저장
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
                'email': email,
                'displayName': displayName,
                'isTeacher': true,
                'createdAt': FieldValue.serverTimestamp(),
              });

          // 로그아웃
          await _auth.signOut();
          print('테스트 교사 계정이 생성되었습니다.');
          return;
        } catch (e) {
          print('테스트 교사 계정 생성 실패: $e');
          return;
        }
      }
      print('테스트 교사 계정 확인 중 오류 발생: $e');
    }
  }

  /// 테스트용 학생 계정 생성
  Future<void> _seedTestStudent() async {
    const email = 'student1@school.com';
    const password = 'student123';
    const displayName = '테스트 학생';
    const schoolId = 'school1';
    const studentNum = '1';

    try {
      // 이미 존재하는지 확인
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 이미 존재하면 즉시 로그아웃하고 리턴
      await _auth.signOut();
      print('테스트 학생 계정이 이미 존재합니다.');
      return;
    } catch (e) {
      // 존재하지 않으면 계정 생성
      if (e is FirebaseAuthException && e.code == 'user-not-found') {
        try {
          final userCredential = await _auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );

          // Firestore에 학생 정보 저장
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
                'email': email,
                'displayName': displayName,
                'isTeacher': false,
                'schoolId': schoolId,
                'studentNum': studentNum,
                'grade': 1,
                'gender': 'male',
                'createdAt': FieldValue.serverTimestamp(),
              });

          // 학교 및 학생 맵핑 정보 저장
          await _firestore
              .collection('school_students')
              .doc('$schoolId-$studentNum')
              .set({
                'userId': userCredential.user!.uid,
                'schoolId': schoolId,
                'studentNum': studentNum,
                'email': email,
              });

          // 로그아웃
          await _auth.signOut();
          print('테스트 학생 계정이 생성되었습니다.');
          return;
        } catch (e) {
          print('테스트 학생 계정 생성 실패: $e');
          return;
        }
      }
      print('테스트 학생 계정 확인 중 오류 발생: $e');
    }
  }
}
