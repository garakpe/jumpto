import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_functions/cloud_functions.dart';

import '../../../../core/error/exceptions.dart';
import '../models/student_model.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/firebase/cloud_functions_service.dart';

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
      
      for (final student in students) {
        debugPrint('Processing student: ${student.name}, Email: ${student.email}');
        
        if (student.email == null || student.password == null) {
          throw ServerException(message: '이메일 또는 비밀번호가 없습니다.');
        }
        
        // 1. Firebase Authentication 계정 생성
        firebase_auth.UserCredential userCredential;
        try {
          userCredential = await _auth.createUserWithEmailAndPassword(
            email: student.email!,
            password: student.password!,
          );
          debugPrint('Created Auth account for: ${student.email}');
        } catch (authError) {
          // 이미 존재하는 이메일인 경우, 로깅하고 건너뛬 (배치 작업 계속)
          debugPrint('Error creating auth account: $authError');
          continue;
        }
        
        // 2. Authentication UID 가져오기
        final authUid = userCredential.user!.uid;
        
        // 3. Firestore 문서 참조 생성
        final docRef = _firestore.collection('students').doc();
        
        // 4. authUid와 email이 포함된 학생 모델 생성
        final studentWithAuth = StudentModel(
          id: docRef.id,
          authUid: authUid,
          email: student.email,
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
          gender: student.gender,
        );
        
        // 5. Firestore에 학생 정보 저장 (배치에 추가)
        batch.set(docRef, studentWithAuth.toFirestore());
        
        // 6. 생성된 학생 저장
        createdStudents.add(studentWithAuth);
      }
      
      // 배치 요청 실행
      await batch.commit();
      return createdStudents;
    } catch (e) {
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
