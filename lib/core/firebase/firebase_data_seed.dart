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
    await _seedSchools();
    await _seedTestTeacher();
    await _seedTestStudent();
  }

  /// 학교 데이터 시드
  Future<void> _seedSchools() async {
    try {
      // 학교 데이터 목록
      final List<Map<String, dynamic>> schools = [
        {
          'schoolName': '가락고등학교',
          'schoolCode': '3550',
          'address': '서울특별시 송파구 가락로 29',
          'type': '고등학교',
          'region': '서울',
        },
        {
          'schoolName': '명지고등학교',
          'schoolCode': '7020',
          'address': '서울특별시 서대문구 명지2길 56',
          'type': '고등학교',
          'region': '서울',
        },
        {
          'schoolName': '서울체육고등학교',
          'schoolCode': '7530',
          'address': '서울특별시 송파구 백제고분로 509',
          'type': '고등학교',
          'region': '서울',
        }
      ];

      // 배치 처리로 한번에 저장
      WriteBatch batch = _firestore.batch();
      
      // 각 학교별로 처리
      for (final school in schools) {
        // 이미 존재하는지 확인
        final querySnapshot = await _firestore
            .collection('schools')
            .where('schoolName', isEqualTo: school['schoolName'])
            .limit(1)
            .get();
        
        // 존재하지 않으면 추가
        if (querySnapshot.docs.isEmpty) {
          final docRef = _firestore.collection('schools').doc();
          batch.set(docRef, {
            ...school,
            'createdAt': FieldValue.serverTimestamp(),
          });
          print('학교 데이터 추가: ${school['schoolName']}');
        } else {
          print('학교 데이터 이미 존재: ${school['schoolName']}');
        }
      }
      
      // 배치 처리 실행
      await batch.commit();
      print('학교 데이터 시드 완료');
    } catch (e) {
      print('학교 데이터 시드 오류: $e');
    }
  }

  /// 테스트용 교사 계정 생성
  Future<void> _seedTestTeacher() async {
    const email = 'teacher@test.com';
    const password = 'teacher123';
    const displayName = '테스트 교사';
    const schoolName = '가락고등학교';
    const schoolCode = '3550';

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
                'role': 'teacher',
                'isApproved': true,
                'schoolName': schoolName,
                'schoolCode': schoolCode,
                'phoneNumber': '010-1234-5678',
                'authUid': userCredential.user!.uid,
                'createdAt': FieldValue.serverTimestamp(),
                'updatedAt': FieldValue.serverTimestamp(),
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
    const schoolCode = 'school1';
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
                'role': 'student',
                'schoolCode': schoolCode,
                'schoolName': '테스트 학교',
                'studentId': studentNum,
                'grade': '1',
                'classNum': '1',
                'studentNum': '1',
                'gender': '남',
                'authUid': userCredential.user!.uid,
                'createdAt': FieldValue.serverTimestamp(),
                'updatedAt': FieldValue.serverTimestamp(),
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
