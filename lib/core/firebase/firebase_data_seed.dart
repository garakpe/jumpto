import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Firebase 데이터 시드 클래스
/// 
/// 앱 초기 실행 시 테스트용 계정 및 데이터를 생성하는 클래스
class FirebaseDataSeed {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  
  FirebaseDataSeed(this._auth, this._firestore);
  
  /// 테스트용 데이터 시드 생성
  Future<void> seedTestData() async {
    try {
      await _createTeacherAccount();
      await _createStudentAccount();
      print('테스트 데이터 시드 생성 완료');
    } catch (e) {
      print('테스트 데이터 시드 생성 실패: $e');
    }
  }
  
  /// 교사 계정 생성
  Future<void> _createTeacherAccount() async {
    const email = 'teacher@test.com';
    const password = 'teacher123';
    const displayName = '테스트 교사';
    const schoolId = 'school1';
    
    try {
      // 이미 존재하는지 확인
      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      
      if (userQuery.docs.isNotEmpty) {
        print('교사 계정이 이미 존재합니다.');
        return;
      }
      
      // Firebase Auth에 계정 생성
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final uid = userCredential.user!.uid;
      
      // Firestore에 교사 정보 저장
      await _firestore.collection('users').doc(uid).set({
        'email': email,
        'displayName': displayName,
        'role': 'teacher',
        'schoolId': schoolId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      print('교사 계정 생성 완료: $email');
    } catch (e) {
      if (e is FirebaseAuthException && e.code == 'email-already-in-use') {
        // Auth에는 존재하지만 Firestore에는 없는 경우
        try {
          final userCredential = await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          
          final uid = userCredential.user!.uid;
          
          // Firestore 데이터가 있는지 확인
          final userDoc = await _firestore.collection('users').doc(uid).get();
          
          if (!userDoc.exists) {
            // Firestore에 교사 정보 저장
            await _firestore.collection('users').doc(uid).set({
              'email': email,
              'displayName': displayName,
              'role': 'teacher',
              'schoolId': schoolId,
              'createdAt': FieldValue.serverTimestamp(),
            });
            
            print('교사 계정의 Firestore 데이터 생성 완료: $email');
          }
        } catch (signInError) {
          print('교사 계정 생성 중 오류 발생: $signInError');
        }
      } else {
        print('교사 계정 생성 중 오류 발생: $e');
      }
    }
  }
  
  /// 학생 계정 생성
  Future<void> _createStudentAccount() async {
    const email = 'student1@school.com';
    const password = 'student123';
    const displayName = '테스트 학생';
    const schoolId = 'school1';
    const className = '1';
    const studentNumber = '1';
    const gender = '남';
    
    try {
      // 이미 존재하는지 확인
      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      
      if (userQuery.docs.isNotEmpty) {
        print('학생 계정이 이미 존재합니다.');
        return;
      }
      
      // Firebase Auth에 계정 생성
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final uid = userCredential.user!.uid;
      
      // 교사 ID 가져오기 (있으면)
      String? teacherId;
      final teacherQuery = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'teacher')
          .where('schoolId', isEqualTo: schoolId)
          .limit(1)
          .get();
      
      if (teacherQuery.docs.isNotEmpty) {
        teacherId = teacherQuery.docs.first.id;
      }
      
      // Firestore에 학생 정보 저장
      await _firestore.collection('users').doc(uid).set({
        'email': email,
        'displayName': displayName,
        'role': 'student',
        'schoolId': schoolId,
        'classId': className,
        'studentNumber': studentNumber,
        'gender': gender,
        'teacherId': teacherId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      // 학생 컬렉션에도 정보 저장
      await _firestore.collection('students').doc(uid).set({
        'email': email,
        'displayName': displayName,
        'schoolId': schoolId,
        'classId': className,
        'studentNumber': studentNumber,
        'gender': gender,
        'teacherId': teacherId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      print('학생 계정 생성 완료: $email');
    } catch (e) {
      if (e is FirebaseAuthException && e.code == 'email-already-in-use') {
        // Auth에는 존재하지만 Firestore에는 없는 경우
        try {
          final userCredential = await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          
          final uid = userCredential.user!.uid;
          
          // Firestore 데이터가 있는지 확인
          final userDoc = await _firestore.collection('users').doc(uid).get();
          
          if (!userDoc.exists) {
            // 교사 ID 가져오기 (있으면)
            String? teacherId;
            final teacherQuery = await _firestore
                .collection('users')
                .where('role', isEqualTo: 'teacher')
                .where('schoolId', isEqualTo: schoolId)
                .limit(1)
                .get();
            
            if (teacherQuery.docs.isNotEmpty) {
              teacherId = teacherQuery.docs.first.id;
            }
            
            // Firestore에 학생 정보 저장
            await _firestore.collection('users').doc(uid).set({
              'email': email,
              'displayName': displayName,
              'role': 'student',
              'schoolId': schoolId,
              'classId': className,
              'studentNumber': studentNumber,
              'gender': gender,
              'teacherId': teacherId,
              'createdAt': FieldValue.serverTimestamp(),
            });
            
            // 학생 컬렉션에도 정보 저장
            await _firestore.collection('students').doc(uid).set({
              'email': email,
              'displayName': displayName,
              'schoolId': schoolId,
              'classId': className,
              'studentNumber': studentNumber,
              'gender': gender,
              'teacherId': teacherId,
              'createdAt': FieldValue.serverTimestamp(),
            });
            
            print('학생 계정의 Firestore 데이터 생성 완료: $email');
          }
        } catch (signInError) {
          print('학생 계정 생성 중 오류 발생: $signInError');
        }
      } else {
        print('학생 계정 생성 중 오류 발생: $e');
      }
    }
  }
}
