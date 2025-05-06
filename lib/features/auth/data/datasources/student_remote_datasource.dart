import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../../../core/error/exceptions.dart';
import '../models/student_model.dart';

/// 학생 원격 데이터 소스 인터페이스
abstract class StudentRemoteDataSource {
  /// 교사 ID로 학생 목록 조회
  Future<List<StudentModel>> getStudentsByTeacherId(String teacherId);
  
  /// 학교 ID로 학생 목록 조회
  Future<List<StudentModel>> getStudentsBySchoolId(String schoolId);
  
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
}

/// 학생 원격 데이터 소스 구현체 (Firebase Firestore 사용)
class StudentRemoteDataSourceImpl implements StudentRemoteDataSource {
  final FirebaseFirestore _firestore;
  
  StudentRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;
  
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
  Future<List<StudentModel>> getStudentsBySchoolId(String schoolId) async {
    try {
      final querySnapshot = await _firestore
          .collection('students')
          .where('schoolId', isEqualTo: schoolId)
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
  Future<List<StudentModel>> uploadStudents(List<StudentModel> students) async {
    try {
      final batch = _firestore.batch();
      final createdStudents = <StudentModel>[];
      
      for (final student in students) {
        final docRef = _firestore.collection('students').doc();
        batch.set(docRef, student.toFirestore());
        
        // ID 부여된 학생 모델 생성
        final createdStudent = StudentModel(
          id: docRef.id,
          name: student.name,
          grade: student.grade,
          classNum: student.classNum,
          studentNum: student.studentNum,
          studentId: student.studentId,
          teacherId: student.teacherId,
          schoolId: student.schoolId,
          schoolName: student.schoolName,
          attendance: student.attendance,
          createdAt: student.createdAt,
          password: student.password,
        );
        createdStudents.add(createdStudent);
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
      // 학번으로 학생 문서 조회
      final querySnapshot = await _firestore
          .collection('students')
          .where('studentId', isEqualTo: studentId)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isEmpty) {
        throw ServerException(message: '학생을 찾을 수 없습니다.');
      }
      
      // 학생 문서 ID
      final studentDocId = querySnapshot.docs.first.id;
      
      // 비밀번호 업데이트 (실제 구현에서는 Firebase Authentication 사용)
      // 여기서는 Firestore에만 저장하는 예시
      await _firestore
          .collection('students')
          .doc(studentDocId)
          .update({'password': newPassword});
    } catch (e) {
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
}
