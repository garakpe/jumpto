import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/firebase/cloud_functions_service.dart';
import '../models/student_model.dart';

/// 학생 원격 데이터 소스 인터페이스
abstract class StudentRemoteDataSource {
  /// 교사 ID로 학생 목록 조회
  Future<List<StudentModel>> getStudentsByTeacherId(String teacherId);
  
  /// 학교 코드로 학생 목록 조회
  Future<List<StudentModel>> getStudentsBySchoolCode(String schoolCode);
  
  /// 학급(교사ID, 학년, 반)으로 학생 목록 조회
  Future<List<StudentModel>> getStudentsByClass(String teacherId, String grade, String classNum);
  
  /// 학생 생성
  Future<StudentModel> createStudent(StudentModel student);
  
  /// 학생 일괄 생성
  Future<List<StudentModel>> uploadStudents(List<StudentModel> students);
  
  /// 학생 정보 업데이트
  Future<StudentModel> updateStudent(StudentModel student);
  
  /// 학생 비밀번호 재설정
  Future<void> resetStudentPassword(String studentId, String newPassword);
  
  /// ID로 학생 조회
  Future<StudentModel> getStudentById(String id);
  
  /// 학번으로 학생 조회
  Future<StudentModel> getStudentByStudentId(String studentId);
  
  /// 학생 삭제
  Future<void> deleteStudent(String id);
  
  /// 학생 성별 업데이트
  Future<void> updateStudentGender(String gender);
}

/// 학생 원격 데이터 소스 구현체 (Firebase Firestore 사용)
class StudentRemoteDataSourceImpl implements StudentRemoteDataSource {
  final FirebaseFirestore _firestore;
  final firebase_auth.FirebaseAuth _auth;
  final CloudFunctionsService _cloudFunctionsService;
  
  StudentRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
    required firebase_auth.FirebaseAuth auth,
    required CloudFunctionsService cloudFunctionsService,
  }) : _firestore = firestore, 
       _auth = auth,
       _cloudFunctionsService = cloudFunctionsService;
  
  @override
  Future<List<StudentModel>> getStudentsByTeacherId(String teacherId) async {
    try {
      final querySnapshot = await _firestore
          .collection('students')
          .where('teacherId', isEqualTo: teacherId)
          .get();
      
      return querySnapshot.docs
          .map((doc) => StudentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException(message: '학생 목록 조회 실패: $e');
    }
  }
  
  @override
  Future<List<StudentModel>> getStudentsBySchoolCode(String schoolCode) async {
    try {
      final querySnapshot = await _firestore
          .collection('students')
          .where('schoolCode', isEqualTo: schoolCode)
          .get();
      
      return querySnapshot.docs
          .map((doc) => StudentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException(message: '학생 목록 조회 실패: $e');
    }
  }
  
  @override
  Future<List<StudentModel>> getStudentsByClass(String teacherId, String grade, String classNum) async {
    try {
      final querySnapshot = await _firestore
          .collection('students')
          .where('teacherId', isEqualTo: teacherId)
          .where('grade', isEqualTo: grade)
          .where('classNum', isEqualTo: classNum)
          .get();
      
      return querySnapshot.docs
          .map((doc) => StudentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException(message: '학급 학생 목록 조회 실패: $e');
    }
  }
  
  @override
  Future<StudentModel> createStudent(StudentModel student) async {
    try {
      // Firestore에 학생 정보 저장
      final docRef = await _firestore.collection('students').add(student.toFirestore());
      
      // 저장된 학생 정보 다시 조회
      final docSnapshot = await docRef.get();
      return StudentModel.fromFirestore(docSnapshot);
    } catch (e) {
      throw ServerException(message: '학생 생성 실패: $e');
    }
  }
  
  @override
  /// 학생 일괄 업로드 - Firebase Authentication 계정 생성 포함
  Future<List<StudentModel>> uploadStudents(List<StudentModel> students) async {
    try {
      final createdStudents = <StudentModel>[];
      final batch = _firestore.batch();
      
      // 학생 데이터 준비
      final updatedStudents = <StudentModel>[];
      
      // 현재 로그인한 교사 정보 가져오기
      String teacherSchoolName = '';
      String teacherSchoolCode = '';
      try {
        final currentUser = _auth.currentUser;
        if (currentUser != null) {
          final teacherDoc = await _firestore
              .collection('users')
              .where('authUid', isEqualTo: currentUser.uid)
              .limit(1)
              .get();
          
          if (teacherDoc.docs.isNotEmpty) {
            final teacherData = teacherDoc.docs.first.data();
            teacherSchoolName = teacherData['schoolName'] ?? '';
            teacherSchoolCode = teacherData['schoolCode'] ?? '';
            debugPrint('교사 학교 정보: $teacherSchoolName (코드: $teacherSchoolCode)');
          }
        }
      } catch (e) {
        debugPrint('교사 정보 가져오기 오류: $e');
      }
      
      // 학생 수정 (학교명 및 이메일 형식 수정)
      for (final student in students) {
        // 항상 학교 코드의 마지막 4자리만 사용
        String shortSchoolCode = '';
        if (teacherSchoolCode.isNotEmpty) {
          // 교사 정보에서 학교 코드 가져오기
          shortSchoolCode = teacherSchoolCode.length > 4 
              ? teacherSchoolCode.substring(teacherSchoolCode.length - 4) 
              : teacherSchoolCode.padLeft(4, '0');
        } else if (student.schoolCode.isNotEmpty) {
          // 학생 정보에서 학교 코드 가져오기
          shortSchoolCode = student.schoolCode.length > 4 
              ? student.schoolCode.substring(student.schoolCode.length - 4) 
              : student.schoolCode.padLeft(4, '0');
        } else {
          // 기본값 설정
          shortSchoolCode = '0000';
        }
        
        // 이메일 생성 - 일관된 형식 사용
        final DateTime now = DateTime.now();
        final String currentYearSuffix = now.year.toString().substring(2);
        final String email = '$currentYearSuffix${student.studentId}@school$shortSchoolCode.com'; // 학교코드의 뒤 4자리만 사용
        
        // 학교명은 교사 정보에서 가져오기
        final String schoolName = teacherSchoolName.isNotEmpty ? teacherSchoolName : student.schoolName;
        
        // 수정된 학생 모델 생성
        final updatedStudent = StudentModel(
          id: student.id,
          authUid: student.authUid,
          email: email,
          name: student.name,
          grade: student.grade,
          classNum: student.classNum,
          studentNum: student.studentNum,
          studentId: student.studentId,
          teacherId: student.teacherId,
          schoolCode: shortSchoolCode, // 짧은 학교 코드 사용
          schoolName: schoolName,
          attendance: student.attendance,
          createdAt: student.createdAt,
          // 항상 6자리 이상 비밀번호 사용하여 Firebase 인증 요구사항 충족
          password: '123456', 
          gender: student.gender,
        );
        
        updatedStudents.add(updatedStudent);
      }
      
      // 학생 정보 로그 출력
      for (final student in updatedStudents) {
        debugPrint('학생 정보: 이름=${student.name}, 이메일=${student.email}, 학번=${student.studentId}, 학교=${student.schoolName}, 학교코드=${student.schoolCode}');
      }
      
      for (final student in updatedStudents) {
        debugPrint('처리 중인 학생: ${student.name}, 이메일: ${student.email}');
        
        if (student.email == null) {
          throw ServerException(message: '이메일이 없습니다: ${student.name}');
        }
        
        // 이메일 유효성 검사
        final email = student.email!.trim();
        if (!email.contains('@') || !email.contains('.')) {
          throw ServerException(message: '유효하지 않은 이메일 형식: $email (학생: ${student.name})');
        }
        
        // Firebase Auth 계정 생성 시 비밀번호 유효성 확인
        final String studentPassword = '123456'; // 고정된 초기 비밀번호 (Cloud Functions에서 필요)
        
        debugPrint('새 학생 계정 만들기: ${student.name}, 이메일: $email, 학교: ${student.schoolName}');
        
        // 1. Firebase Authentication 계정 생성
        firebase_auth.UserCredential userCredential;
        try {
          userCredential = await _auth.createUserWithEmailAndPassword(
            email: email,
            password: studentPassword, // 고정된 초기 비밀번호 사용
          );
          debugPrint('Auth 계정 생성 성공: $email');
        } catch (authError) {
          // 자세한 에러 로깅
          debugPrint('Auth 계정 생성 오류: $authError (학생: ${student.name}, 이메일: $email)');
          
          // Firebase 오류 코드에 따른 세분화된 처리
          if (authError is firebase_auth.FirebaseAuthException) {
            final code = authError.code;
            if (code == 'email-already-in-use') {
              debugPrint('이미 사용 중인 이메일입니다. 기존 계정을 찾아서 사용합니다.');
              try {
                // 기존 계정에 로그인해서 UID 가져오기
                final existingUser = await _auth.fetchSignInMethodsForEmail(email);
                if (existingUser.isNotEmpty) {
                  // 이 경우 계정은 존재하지만 우리가 UID를 모름
                  // Cloud Function으로 처리하거나 다른 방법으로 UID 획득 필요
                  debugPrint('기존 계정 존재: ${existingUser.join(', ')}');
                  continue; // 이 학생은 건너뜀
                }
              } catch (e) {
                debugPrint('기존 계정 확인 오류: $e');
              }
            } else {
              // 다른 Firebase Auth 오류 처리
              debugPrint('Firebase Auth 오류: ${authError.code} - ${authError.message}');
            }
          }
          continue; // 이 학생은 건너뜀 (배치 작업 계속)
        }
        
        // 2. Authentication UID 가져오기
        final authUid = userCredential.user!.uid;
        
        // 3. Firestore 문서 참조 생성
        final docRef = _firestore.collection('students').doc();
        
        // 4. authUid와 email이 포함된 학생 모델 생성
        final studentWithAuth = StudentModel(
          id: docRef.id,
          authUid: authUid,
          email: email,
          name: student.name,
          grade: student.grade,
          classNum: student.classNum,
          studentNum: student.studentNum,
          studentId: student.studentId,
          teacherId: student.teacherId,
          schoolCode: student.schoolCode,
          schoolName: student.schoolName,
          attendance: student.attendance,
          createdAt: student.createdAt,
          // 중요: Cloud Function 트리거를 위해 반드시 password 필드 포함
          password: studentPassword, 
          gender: student.gender,
        );
        
        // 5. Firestore에 학생 정보 저장 (배치에 추가)
        // toFirestore() 메서드가 모든 필수 필드를 포함하는지 확인
        final firestoreData = studentWithAuth.toFirestore();
        
        // 필수 필드 검증 - 로그 디버깅
        debugPrint('학생 Firestore 데이터 확인: ${firestoreData.keys.join(', ')}');
        if (!firestoreData.containsKey('email') || !firestoreData.containsKey('password')) {
          debugPrint('경고: 필수 필드(email 또는 password)가 누락됨');
          
          // 필수 필드가 누락된 경우 직접 추가
          if (!firestoreData.containsKey('email')) {
            firestoreData['email'] = email;
          }
          if (!firestoreData.containsKey('password')) {
            firestoreData['password'] = studentPassword;
          }
        }
        
        batch.set(docRef, firestoreData);
        
        // 6. 생성된 학생 저장
        createdStudents.add(studentWithAuth);
      }
      
      // 배치 요청 실행
      await batch.commit();
      return createdStudents;
    } catch (e, stackTrace) {
      debugPrint('학생 일괄 업로드 실패: $e');
      debugPrint('Stack trace: $stackTrace');
      throw ServerException(message: '학생 일괄 업로드 실패: $e');
    }
  }
  
  @override
  Future<StudentModel> updateStudent(StudentModel student) async {
    try {
      await _firestore
          .collection('students')
          .doc(student.id)
          .update(student.toFirestore());
      
      // 업데이트된 학생 정보 다시 조회
      final docSnapshot = await _firestore.collection('students').doc(student.id).get();
      return StudentModel.fromFirestore(docSnapshot);
    } catch (e) {
      throw ServerException(message: '학생 정보 업데이트 실패: $e');
    }
  }
  
  @override
  Future<void> resetStudentPassword(String studentId, String newPassword) async {
    try {
      // CloudFunctionsService를 통해 Cloud Functions 호출
      await _cloudFunctionsService.resetStudentPassword(
        studentId: studentId,
        newPassword: newPassword,
      );
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(message: '비밀번호 재설정 실패: $e');
    }
  }
  
  @override
  Future<StudentModel> getStudentById(String id) async {
    try {
      final docSnapshot = await _firestore.collection('students').doc(id).get();
      
      if (!docSnapshot.exists) {
        throw ServerException(message: '학생을 찾을 수 없습니다.');
      }
      
      return StudentModel.fromFirestore(docSnapshot);
    } catch (e) {
      throw ServerException(message: '학생 조회 실패: $e');
    }
  }
  
  @override
  Future<StudentModel> getStudentByStudentId(String studentId) async {
    try {
      final querySnapshot = await _firestore
          .collection('students')
          .where('studentId', isEqualTo: studentId)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isEmpty) {
        throw ServerException(message: '학생을 찾을 수 없습니다.');
      }
      
      return StudentModel.fromFirestore(querySnapshot.docs.first);
    } catch (e) {
      throw ServerException(message: '학생 조회 실패: $e');
    }
  }
  
  @override
  Future<void> deleteStudent(String id) async {
    try {
      await _firestore.collection('students').doc(id).delete();
    } catch (e) {
      throw ServerException(message: '학생 삭제 실패: $e');
    }
  }
  
  @override
  Future<void> updateStudentGender(String gender) async {
    try {
      // CloudFunctionsService를 통해 Cloud Functions 호출
      await _cloudFunctionsService.updateStudentGender(gender: gender);
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(message: '성별 업데이트 실패: $e');
    }
  }
}