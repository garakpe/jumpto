import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../../../core/firebase/cloud_functions_service.dart';
import '../../../../core/error/exceptions.dart';
import 'package:flutter/foundation.dart';

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
    String? schoolCode,
    String? schoolName,
    String? phoneNumber,
  });

  /// 학생 계정 생성 (교사에 의해)
  Future<domain.User> createStudentAccount({
    required String displayName, // 학생 이름
    required String grade, // 학년 (추가)
    required String classNum, // 반
    required String studentNum, // 번호
    required String gender, // 성별
    String? initialPassword, // 초기 비밀번호
  });

  /// 이메일/비밀번호로 로그인
  Future<domain.User> signInWithEmailPassword({
    required String email,
    required String password,
  });

  /// 학번/비밀번호로 학생 로그인
  Future<domain.User> signInStudent({
    required String schoolName,
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
  final CloudFunctionsService _cloudFunctionsService;

  /// 사용자 컬렉션 참조
  CollectionReference get _usersCollection => _firestore.collection('users');

  /// 학생 컬렉션 참조
  CollectionReference get _studentsCollection =>
      _firestore.collection('students');

  /// 학교 컬렉션 참조
  CollectionReference get _schoolsCollection =>
      _firestore.collection('schools');

  AuthRemoteDataSourceImpl(
    this._firebaseAuth,
    this._firestore,
    this._cloudFunctionsService,
  );

  @override
  Future<domain.User?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) {
      return null;
    }

    return _getUserData(firebaseUser.uid);
  }

  /// Firebase 인증 사용자 ID로 사용자 정보 가져오기
  Future<domain.User?> _getUserData(String uid) async {
    try {
      // 사용자 컬렉션에서 조회
      final userDoc = await _usersCollection.doc(uid).get();
      final userData = userDoc.data() as Map<String, dynamic>?;

      // users 컬렉션에 사용자 정보가 없으면 students 컬렉션에서 authUid로 조회 
      if (userData == null) {
        debugPrint('users 컬렉션에서 사용자($uid) 정보를 찾을 수 없음, students 컬렉션 조회');
        final studentQuery = await _firestore.collection('students')
            .where('authUid', isEqualTo: uid)
            .limit(1)
            .get();
            
        if (studentQuery.docs.isEmpty) {
          debugPrint('students 컬렉션에서도 authUid가 $uid인 학생을 찾을 수 없음');
          return null;
        }
        
        final studentData = studentQuery.docs.first.data() as Map<String, dynamic>;
        debugPrint('students 컬렉션에서 학생 정보 발견: ${studentQuery.docs.first.id}');
        
        // Students 데이터에서 User 객체로 변환
        return domain.User(
          id: uid,
          email: studentData['email'],
          displayName: studentData['name'],
          role: domain.UserRole.student,
          schoolCode: studentData['schoolCode'],
          schoolName: studentData['schoolName'],
          classNum: studentData['classNum'],
          studentNum: studentData['studentNum'],
          studentId: studentData['studentId'],
          gender: studentData['gender'],
        );
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
        schoolCode: userData['schoolCode'],
        schoolName: userData['schoolName'],
        classNum: userData['classNum'],
        studentNum: userData['studentNum'],
        studentId: userData['studentId'],
        gender: userData['gender'],
        phoneNumber: userData['phoneNumber'],
        isApproved: isApproved,
      );
    } catch (e) {
      debugPrint('사용자 데이터 가져오기 오류: $e');
      rethrow;
    }
  }

  @override
  Future<domain.User> signUpTeacher({
    required String email,
    required String password,
    required String displayName,
    String? schoolCode,
    String? schoolName,
    String? phoneNumber,
  }) async {
    try {
      // Firebase Auth로 계정 생성
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;

      // 학교 정보 검증
      if (schoolCode != null &&
          schoolCode.isNotEmpty &&
          schoolName != null &&
          schoolName.isNotEmpty) {
        // 학교 코드의 마지막 4자리만 사용
        String shortSchoolCode =
            schoolCode.length > 4
                ? schoolCode.substring(schoolCode.length - 4)
                : schoolCode.padLeft(4, '0');

        // 'schools' 컬렉션에 학교 정보가 있는지 확인
        final schoolsSnapshot =
            await _schoolsCollection
                .where('schoolName', isEqualTo: schoolName)
                .limit(1)
                .get();

        // 학교 정보가 없으면 새로 추가
        if (schoolsSnapshot.docs.isEmpty) {
          debugPrint(
            '학교 정보를 schools 컬렉션에 추가합니다: $schoolName (코드: $shortSchoolCode)',
          );
          await _schoolsCollection.add({
            'schoolName': schoolName,
            'schoolCode': shortSchoolCode,
            'address': '', // 필요 시 추가 정보 입력
            'type': '고등학교', // 기본값, 필요 시 수정
            'region': '서울', // 기본값, 필요 시 수정
            'createdAt': FieldValue.serverTimestamp(),
          });
          debugPrint('학교 정보가 성공적으로 추가되었습니다: $schoolName');
        } else {
          debugPrint('이미 schools 컬렉션에 학교 정보가 존재합니다: $schoolName');
        }

        // schoolCode를 짧은 버전으로 업데이트
        schoolCode = shortSchoolCode;
      }

      // Firestore에 교사 정보 저장
      await _usersCollection.doc(uid).set({
        'email': email,
        'displayName': displayName,
        'role': 'teacher',
        'schoolCode': schoolCode,
        'schoolName': schoolName,
        'phoneNumber': phoneNumber,
        'authUid': uid,
        'isApproved': false, // 기본적으로 승인되지 않은 상태
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 사용자 데이터 반환
      return domain.User(
        id: uid,
        email: email,
        displayName: displayName,
        role: domain.UserRole.teacher,
        schoolCode: schoolCode,
        schoolName: schoolName,
        phoneNumber: phoneNumber,
        isApproved: false, // 기본적으로 승인되지 않은 상태
      );
    } catch (e) {
      debugPrint('교사 회원가입 오류: $e');
      rethrow;
    }
  }

  /// AuthRemoteDataSourceImpl 클래스 내부에 구현될 createStudentAccount 메서드
  ///
  /// 이 코드를 AuthRemoteDataSourceImpl 클래스 내부로 복사/붙여넣기하세요.
  @override
  Future<domain.User> createStudentAccount({
    required String displayName,
    required String grade, // 학년 (추가)
    required String classNum,
    required String studentNum,
    required String gender,
    String? initialPassword,
  }) async {
    try {
      // 현재 로그인한 교사 ID 가져오기
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw ServerException(message: '로그인이 필요합니다.');
      }

      final teacherId = currentUser.uid;

      // 교사 정보 가져오기
      final teacherDoc = await _usersCollection.doc(teacherId).get();
      final teacherData = teacherDoc.data() as Map<String, dynamic>;

      if (teacherData['role'] != 'teacher') {
        throw ServerException(message: '교사만 학생 계정을 생성할 수 있습니다.');
      }

      String schoolCode = teacherData['schoolCode'] ?? '';
      final schoolName = teacherData['schoolName'] ?? '';

      // 학교 코드의 마지막 4자리만 사용
      if (schoolCode.length > 4) {
        schoolCode = schoolCode.substring(schoolCode.length - 4);
      } else {
        schoolCode = schoolCode.padLeft(4, '0');
      }

      // 학번 생성 (grade + classNum + studentNum)
      // 학년, 반, 번호가 단일 숫자인 경우 앞에 0 추가
      final formattedGrade = grade.padLeft(1, '0'); // 학년은 보통 1자리
      final formattedClassNum = classNum.padLeft(
        2,
        '0',
      ); // 반은 2자리로 표시 (01, 02 등)
      final formattedStudentNum = studentNum.padLeft(
        2,
        '0',
      ); // 번호는 2자리로 표시 (01, 02 등)

      final studentId = '$formattedGrade$formattedClassNum$formattedStudentNum';

      // 비밀번호 설정 (기본값: 123456)
      final password = initialPassword ?? '123456';

      // 학생 이메일 형식: "(연도 두자리)(학번)@school(학교코드 뒤 4자리).com"
      // 예: 가락고등학교 3학년 1반 1번 학생, 25년도 → 2530101@school3550.com
      final DateTime now = DateTime.now();
      final String currentYearSuffix = now.year.toString().substring(2);
      final studentEmail = '$currentYearSuffix$studentId@school$schoolCode.com';

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
        'schoolCode': schoolCode,
        'schoolName': schoolName,
        'grade': formattedGrade,
        'classNum': formattedClassNum,
        'studentNum': formattedStudentNum,
        'studentId': studentId,
        'gender': gender,
        'teacherId': teacherId,
        'authUid': uid,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 학생 콜렉션에도 정보 저장
      await _studentsCollection.doc(uid).set({
        'email': studentEmail,
        'name': displayName, // students 컬렉션에서는 'name' 필드 사용
        'schoolCode': schoolCode,
        'schoolName': schoolName,
        'grade': formattedGrade,
        'classNum': formattedClassNum,
        'studentNum': formattedStudentNum,
        'studentId': studentId,
        'gender': gender,
        'teacherId': teacherId,
        'authUid': uid,
        'password': password, // Cloud Function에서 필요
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'attendance': true, // 추가
      });

      // 사용자 데이터 반환
      return domain.User(
        id: uid,
        email: studentEmail,
        displayName: displayName,
        role: domain.UserRole.student,
        schoolCode: schoolCode,
        schoolName: schoolName,
        grade: formattedGrade,
        classNum: formattedClassNum,
        studentNum: formattedStudentNum,
        studentId: studentId,
        gender: gender,
      );
    } catch (e) {
      debugPrint('학생 계정 생성 오류: $e');
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
      debugPrint('Firebase Auth 로그인 성공, UID: $uid, 이메일: $email');
      
      // 학생 정보 조회 시도 - 여기에 디버깅 로그 추가
      debugPrint('Firestore에서 사용자 정보 조회 시도 (UID: $uid)');
      final userData = await _getUserData(uid);
      
      if (userData == null) {
        debugPrint('사용자 정보 조회 실패: userData는 null, UID: $uid');
        
        // 추가 디버그: users 컬렉션 확인
        final userDoc = await _firestore.collection('users').doc(uid).get();
        if (!userDoc.exists) {
          debugPrint('users 컬렉션에 문서가 없음: $uid');
        } else {
          debugPrint('users 컬렉션 문서 데이터: ${userDoc.data()}');
        }
        
        throw ServerException(message: '사용자 정보를 찾을 수 없습니다.');
      }

      // 교사 계정인 경우 승인 여부 확인
      if (userData.role == domain.UserRole.teacher) {
        final userDoc = await _usersCollection.doc(uid).get();
        final userDocData = userDoc.data() as Map<String, dynamic>;

        if (userDocData['isApproved'] != true) {
          await _firebaseAuth.signOut();
          throw ServerException(message: '관리자의 승인이 필요합니다.');
        }
      }

      return userData;
    } catch (e) {
      debugPrint('이메일/비밀번호 로그인 오류: $e');
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(message: '로그인에 실패했습니다: ${e.toString()}');
    }
  }

  @override
  Future<domain.User> signInStudent({
    required String schoolName,
    required String studentId,
    required String password,
  }) async {
    try {
      debugPrint('학생 로그인 시도: 학교=$schoolName, 학번=$studentId');

      // 1. 학교 이름 및 학번 트림 처리
      final trimmedSchoolName = schoolName.trim();
      final trimmedStudentId = studentId.trim();

      debugPrint('학교 이름 처리: "$trimmedSchoolName", 학번: "$trimmedStudentId"');

      // 2. 학생 로그인 이메일 조회 (새로 추가된 Cloud Function 사용)
      final email = await _cloudFunctionsService.getStudentLoginEmail(
        schoolName: trimmedSchoolName,
        studentId: trimmedStudentId,
      );
      
      debugPrint('학생 로그인 이메일 조회 성공: $email');

      // 3. Firebase Auth SDK를 사용하여 직접 로그인
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;
      debugPrint('Firebase 로그인 성공: $uid');

      // 4. Firestore에서 학생 상세 정보 조회
      final userData = await _getUserData(uid);
      if (userData == null) {
        debugPrint('학생 데이터를 찾을 수 없음');
        throw ServerException(message: '학생 정보를 찾을 수 없습니다.');
      }

      // 5. 학생 계정 확인
      if (userData.role != domain.UserRole.student) {
        debugPrint('계정이 학생이 아님');
        await _firebaseAuth.signOut();
        throw ServerException(message: '학생 계정이 아닙니다.');
      }

      // 6. 마지막 로그인 시간 업데이트 (선택 사항)
      try {
        final studentsSnapshot = await _studentsCollection
            .where('authUid', isEqualTo: uid)
            .limit(1)
            .get();
            
        if (studentsSnapshot.docs.isNotEmpty) {
          await studentsSnapshot.docs.first.reference.update({
            'lastLoginAt': FieldValue.serverTimestamp(),
          });
          debugPrint('마지막 로그인 시간 업데이트 완료');
        }
      } catch (e) {
        // 로그인 시간 업데이트 실패는 무시 (핵심 기능 아님)
        debugPrint('마지막 로그인 시간 업데이트 실패 (무시): $e');
      }

      return userData;
    } catch (e) {
      debugPrint('학생 로그인 오류: $e');
      if (e is ServerException) {
        rethrow;
      }
      
      // Firebase Auth 오류를 사용자 친화적 메시지로 변환
      if (e is firebase_auth.FirebaseAuthException) {
        String message = '로그인에 실패했습니다.';
        
        switch (e.code) {
          case 'user-not-found':
            message = '해당 학번으로 등록된 계정을 찾을 수 없습니다.';
            break;
          case 'wrong-password':
            message = '비밀번호가 일치하지 않습니다.';
            break;
          case 'too-many-requests':
            message = '로그인 시도가 너무 많습니다. 잠시 후 다시 시도해주세요.';
            break;
          case 'invalid-email':
            message = '이메일 형식이 올바르지 않습니다.';
            break;
          case 'user-disabled':
            message = '계정이 비활성화되었습니다. 관리자에게 문의하세요.';
            break;
          default:
            message = '로그인 중 오류가 발생했습니다: ${e.message}';
        }
        
        throw ServerException(message: message);
      }
      
      throw ServerException(message: '학생 로그인 중 오류가 발생했습니다: ${e.toString()}');
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
        throw ServerException(message: '로그인이 필요합니다.');
      }

      // 재인증 필요
      final email = currentUser.email;
      if (email == null) {
        throw ServerException(message: '이메일 정보가 없습니다.');
      }

      final credential = firebase_auth.EmailAuthProvider.credential(
        email: email,
        password: oldPassword,
      );

      await currentUser.reauthenticateWithCredential(credential);

      // 비밀번호 변경
      await currentUser.updatePassword(newPassword);
    } catch (e) {
      debugPrint('비밀번호 변경 오류: $e');
      throw ServerException(message: '비밀번호 변경에 실패했습니다: ${e.toString()}');
    }
  }

  @override
  Future<void> resetStudentPassword({
    required String studentId,
    required String newPassword,
  }) async {
    try {
      // Cloud Functions를 사용하여 학생 비밀번호 초기화
      await _cloudFunctionsService.resetStudentPassword(
        studentId: studentId,
        newPassword: newPassword,
      );
    } catch (e) {
      debugPrint('학생 비밀번호 초기화 오류: $e');
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(message: '비밀번호 초기화에 실패했습니다: ${e.toString()}');
    }
  }

  @override
  Stream<domain.User?> get authStateChanges =>
      _firebaseAuth.authStateChanges().asyncMap(
        (firebaseUser) =>
            firebaseUser != null ? _getUserData(firebaseUser.uid) : null,
      );
}
