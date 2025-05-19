import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:dartz/dartz.dart';

import '../../../../../core/error/exceptions.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/services/cloud_functions_service.dart';
import '../../../../../core/services/firebase_auth_service.dart';
import '../../../domain/entities/base_user.dart' as entities;
import '../../../domain/entities/teacher.dart' as entities;
import '../../../domain/entities/student.dart' as entities;
import '../../../domain/entities/admin.dart' as entities;
import '../models/base_user_model.dart';
import '../models/teacher_model.dart';
import '../models/student_model.dart';
import '../models/admin_model.dart';

abstract class AuthRemoteDataSource {
  /// 현재 인증된 사용자 정보를 가져온다.
  Future<BaseUserModel?> getCurrentUser();
  
  /// 세부 정보를 포함한 현재 인증된 사용자 정보를 가져온다.
  Future<Either<Failure, dynamic>> getCurrentUserWithDetails();

  /// 이메일/비밀번호로 교사 회원 가입
  Future<Either<Failure, TeacherModel>> signUpTeacher({
    required String email,
    required String password,
    required String displayName,
    required String schoolCode,
    required String schoolName,
    String? phoneNumber,
  });

  /// 이메일/비밀번호로 로그인 (교사용)
  Future<Either<Failure, BaseUserModel>> signInWithEmailPassword({
    required String email, 
    required String password,
  });

  /// 학교/학번으로 학생 로그인
  Future<Either<Failure, BaseUserModel>> signInStudent({
    required String schoolName, 
    required String studentId, 
    required String password,
  });

  /// 사용자 로그아웃
  Future<void> signOut();

  /// 관리자 로그인
  Future<Either<Failure, AdminModel>> signInAdmin({
    required String username,
    required String password,
  });

  /// 교사 계정 승인
  Future<Either<Failure, void>> approveTeacher(String teacherId);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuthService _firebaseAuthService;
  final FirebaseFirestore _firestore;
  final CloudFunctionsService _cloudFunctions;

  AuthRemoteDataSourceImpl({
    required FirebaseAuthService firebaseAuthService,
    required FirebaseFirestore firestore,
    required CloudFunctionsService cloudFunctions,
  })  : _firebaseAuthService = firebaseAuthService,
        _firestore = firestore,
        _cloudFunctions = cloudFunctions;

  @override
  Future<BaseUserModel?> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuthService.currentUser;
      if (firebaseUser == null) {
        return null;
      }

      // 기본 사용자 정보 가져오기 (users 컬렉션)
      final userData = await _getUserData(firebaseUser.uid);
      
      if (userData != null) {
        return BaseUserModel.fromJson({
          'id': firebaseUser.uid,
          'email': firebaseUser.email,
          'displayName': userData['displayName'] ?? '',
          'role': userData['role'] ?? 'student',
          'createdAt': userData['createdAt'] ?? Timestamp.now(),
          'updatedAt': userData['updatedAt'],
        });
      }

      // users 컬렉션에 정보가 없는 경우 (이전 버전 호환성)
      return BaseUserModel.fromFirebaseUser(
        firebaseUser.uid,
        firebaseUser.email,
        displayName: firebaseUser.displayName ?? '사용자',
        role: entities.UserRole.student,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      print('AuthRemoteDataSource getCurrentUser 에러: $e');
      return null;
    }
  }

  @override
  Future<Either<Failure, dynamic>> getCurrentUserWithDetails() async {
    try {
      final baseUser = await getCurrentUser();
      if (baseUser == null) {
        return Left(AuthFailure(message: '로그인된 사용자가 없습니다.'));
      }

      // 사용자 역할에 따라 세부 정보 컬렉션에서 추가 정보 가져오기
      if (baseUser.isAdmin) {
        final adminData = await _firestore
            .collection('admins_details')
            .doc(baseUser.id)
            .get();
            
        if (adminData.exists) {
          return Right(AdminModel.fromFirestore(adminData, baseUser));
        }
        
        // 기본 관리자 정보 생성
        return Right(AdminModel(baseUser: baseUser, level: 1));
      }
      
      if (baseUser.isTeacher) {
        final teacherData = await _firestore
            .collection('teachers_details')
            .doc(baseUser.id)
            .get();
            
        if (teacherData.exists) {
          return Right(TeacherModel.fromFirestore(teacherData, baseUser));
        }
        
        // users 컬렉션에서 학교 정보 가져오기 (이전 버전 호환성)
        final userData = await _getUserData(baseUser.id);
        return Right(TeacherModel(
          baseUser: baseUser,
          schoolCode: userData?['schoolCode'] ?? '',
          schoolName: userData?['schoolName'] ?? '',
          phoneNumber: userData?['phoneNumber'],
          isApproved: userData?['isApproved'] ?? false,
        ));
      }
      
      if (baseUser.isStudent) {
        final studentData = await _firestore
            .collection('students_details')
            .doc(baseUser.id)
            .get();
            
        if (studentData.exists) {
          return Right(StudentModel.fromFirestore(studentData, baseUser));
        }
        
        // students 컬렉션에서 학생 정보 찾기 (이전 버전 호환성)
        final legacyStudentQuery = await _firestore
            .collection('students')
            .where('authUid', isEqualTo: baseUser.id)
            .limit(1)
            .get();
            
        if (legacyStudentQuery.docs.isNotEmpty) {
          final legacyData = legacyStudentQuery.docs.first.data();
          return Right(StudentModel(
            baseUser: baseUser,
            grade: legacyData['grade'] ?? '',
            classNum: legacyData['classNum'] ?? '',
            studentNum: legacyData['studentNum'] ?? '',
            studentId: legacyData['studentId'] ?? '',
            teacherId: legacyData['teacherId'] ?? '',
            schoolCode: legacyData['schoolCode'] ?? '',
            schoolName: legacyData['schoolName'] ?? '',
            attendance: legacyData['attendance'] ?? true,
            gender: legacyData['gender'],
          ));
        }
        
        // 학생 정보가 없는 경우 기본 BaseUser 반환
        return Right(baseUser);
      }
      
      // 기본적으로 BaseUser 반환
      return Right(baseUser);
    } catch (e) {
      print('AuthRemoteDataSource getCurrentUserWithDetails 에러: $e');
      return Left(ServerFailure(message: '사용자 정보를 가져오는 중 오류가 발생했습니다: $e'));
    }
  }

  @override
  Future<Either<Failure, TeacherModel>> signUpTeacher({
    required String email,
    required String password,
    required String displayName,
    required String schoolCode,
    required String schoolName,
    String? phoneNumber,
  }) async {
    try {
      // Firebase Auth에 사용자 생성
      final userCredential = await _firebaseAuthService.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = userCredential.user;
      if (user == null) {
        return Left(AuthFailure(message: '회원가입 중 오류가 발생했습니다.'));
      }
      
      // 기본 사용자 정보 생성 (users 컬렉션)
      final baseUser = BaseUserModel.fromFirebaseUser(
        user.uid,
        email,
        displayName: displayName,
        role: entities.UserRole.teacher,
        createdAt: DateTime.now(),
      );
      
      await _firestore.collection('users').doc(user.uid).set(baseUser.toJson());
      
      // 교사 세부 정보 생성 (teachers_details 컬렉션)
      final teacherModel = TeacherModel(
        baseUser: baseUser,
        phoneNumber: phoneNumber,
        isApproved: false, // 기본적으로 승인 대기 상태
        schoolCode: schoolCode,
        schoolName: schoolName,
      );
      
      await _firestore
          .collection('teachers_details')
          .doc(user.uid)
          .set(teacherModel.toFirestore());
      
      return Right(teacherModel);
    } on firebase_auth.FirebaseAuthException catch (e) {
      String message = '회원가입 중 오류가 발생했습니다.';
      
      switch (e.code) {
        case 'email-already-in-use':
          message = '이미 사용 중인 이메일입니다.';
          break;
        case 'weak-password':
          message = '비밀번호가 너무 약합니다.';
          break;
        case 'invalid-email':
          message = '유효하지 않은 이메일 형식입니다.';
          break;
      }
      
      return Left(AuthFailure(message: message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(message: '회원가입 중 오류가 발생했습니다: $e'));
    }
  }

  @override
  Future<Either<Failure, BaseUserModel>> signInWithEmailPassword({
    required String email, 
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuthService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = userCredential.user;
      if (user == null) {
        return Left(AuthFailure(message: '로그인 중 오류가 발생했습니다.'));
      }
      
      // 기본 사용자 정보 가져오기
      final userData = await _getUserData(user.uid);
      if (userData == null) {
        return Left(AuthFailure(message: '사용자 정보를 찾을 수 없습니다.'));
      }
      
      return Right(BaseUserModel.fromJson({
        'id': user.uid,
        'email': user.email,
        'displayName': userData['displayName'] ?? '',
        'role': userData['role'] ?? 'teacher',
        'createdAt': userData['createdAt'] ?? Timestamp.now(),
        'updatedAt': userData['updatedAt'],
      }));
    } on firebase_auth.FirebaseAuthException catch (e) {
      String message = '로그인 중 오류가 발생했습니다.';
      
      switch (e.code) {
        case 'user-not-found':
        case 'wrong-password':
          message = '이메일 또는 비밀번호가 올바르지 않습니다.';
          break;
        case 'invalid-email':
          message = '유효하지 않은 이메일 형식입니다.';
          break;
        case 'user-disabled':
          message = '비활성화된 계정입니다.';
          break;
      }
      
      return Left(AuthFailure(message: message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(message: '로그인 중 오류가 발생했습니다: $e'));
    }
  }

  @override
  Future<Either<Failure, BaseUserModel>> signInStudent({
    required String schoolName, 
    required String studentId, 
    required String password,
  }) async {
    try {
      // 학생 이메일 주소 조회
      final emailResult = await _cloudFunctions.getStudentLoginEmail(
        schoolName: schoolName,
        studentId: studentId,
      );
      
      if (emailResult.isLeft()) {
        return Left(emailResult.fold(
          (failure) => failure,
          (_) => ServerFailure(message: '학생 이메일 조회 중 오류가 발생했습니다.'),
        ));
      }
      
      final email = emailResult.fold(
        (_) => '',
        (email) => email as String,
      );
      
      if (email.isEmpty) {
        return Left(AuthFailure(message: '해당 학교와 학번의 학생을 찾을 수 없습니다.'));
      }
      
      // 조회된 이메일로 로그인 시도
      return signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      return Left(ServerFailure(message: '학생 로그인 중 오류가 발생했습니다: $e'));
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuthService.signOut();
  }

  @override
  Future<Either<Failure, AdminModel>> signInAdmin({
    required String username,
    required String password,
  }) async {
    try {
      // 관리자 계정 검증
      final adminDoc = await _firestore
          .collection('admins')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();
      
      if (adminDoc.docs.isEmpty) {
        return Left(AuthFailure(message: '관리자 계정을 찾을 수 없습니다.'));
      }
      
      final adminData = adminDoc.docs.first.data();
      
      // 비밀번호 검증
      if (adminData['password'] != password) {
        return Left(AuthFailure(message: '비밀번호가 올바르지 않습니다.'));
      }
      
      // 관리자 기본 정보 생성
      final baseUser = BaseUserModel.fromFirebaseUser(
        adminDoc.docs.first.id,
        adminData['email'] ?? '',
        displayName: adminData['displayName'] ?? '관리자',
        role: entities.UserRole.admin,
        createdAt: adminData['createdAt'] != null
            ? (adminData['createdAt'] as Timestamp).toDate()
            : DateTime.now(),
        updatedAt: adminData['updatedAt'] != null
            ? (adminData['updatedAt'] as Timestamp).toDate()
            : null,
      );
      
      // 관리자 세부 정보 조회
      final adminDetailsDoc = await _firestore
          .collection('admins_details')
          .doc(adminDoc.docs.first.id)
          .get();
          
      if (adminDetailsDoc.exists) {
        return Right(AdminModel.fromFirestore(adminDetailsDoc, baseUser));
      }
      
      // 관리자 세부 정보가 없는 경우 기본 AdminModel 반환
      return Right(AdminModel(
        baseUser: baseUser,
        level: adminData['level'] ?? 1,
      ));
    } catch (e) {
      return Left(ServerFailure(message: '관리자 로그인 중 오류가 발생했습니다: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> approveTeacher(String teacherId) async {
    try {
      // 먼저 해당 교사가 존재하는지 확인
      final teacherDoc = await _firestore
          .collection('users')
          .doc(teacherId)
          .get();
          
      if (!teacherDoc.exists) {
        return Left(ServerFailure(message: '해당 교사를 찾을 수 없습니다.'));
      }
      
      // teachers_details 컬렉션에서 해당 교사의 승인 상태 변경
      await _firestore
          .collection('teachers_details')
          .doc(teacherId)
          .update({
        'isApproved': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: '교사 승인 중 오류가 발생했습니다: $e'));
    }
  }

  /// 사용자 기본 정보를 가져오는 내부 메서드
  Future<Map<String, dynamic>?> _getUserData(String uid) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(uid).get();
      
      if (docSnapshot.exists) {
        return docSnapshot.data();
      }
      
      return null;
    } catch (e) {
      print('_getUserData 에러: $e');
      return null;
    }
  }
}
