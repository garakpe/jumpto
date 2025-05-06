import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_functions/cloud_functions.dart';

import '../../../../core/error/exceptions.dart';
import '../models/student_model.dart';
import 'package:flutter/foundation.dart';

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
  
  /// 학생 성별 업데이트
  Future<void> updateStudentGender(String gender);
}

/// 학생 원격 데이터 소스 구현체 (Firebase Firestore 사용)
class StudentRemoteDataSourceImpl implements StudentRemoteDataSource {
  final FirebaseFirestore _firestore;
  final firebase_auth.FirebaseAuth _auth;
  
  StudentRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
    required firebase_auth.FirebaseAuth auth,
  }) : _firestore = firestore, _auth = auth;
  
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
          schoolId: student.schoolId,
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
      // 학번으로 학생 문서 조회
      final querySnapshot = await _firestore
          .collection('students')
          .where('studentId', isEqualTo: studentId)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isEmpty) {
        throw ServerException(message: '학생을 찾을 수 없습니다.');
      }
      
      final studentDoc = querySnapshot.docs.first;
      final studentData = studentDoc.data();
      
      // 인증 UID 가져오기
      final authUid = studentData['authUid'];
      if (authUid == null) {
        throw ServerException(message: '학생의 인증 정보를 찾을 수 없습니다.');
      }
      
      // 이메일 가져오기
      final email = studentData['email'];
      if (email == null) {
        throw ServerException(message: '학생의 이메일 정보를 찾을 수 없습니다.');
      }
      
      try {
        // 관리자 권한이 없으니 현재 로그인한 유저로 임시 로그인 후 비밀번호 변경
        // 관리자 서버 API를 사용할 수 있다면 그 경우 Cloud Functions 사용하는 것이 좋음
        final currentUser = _auth.currentUser;
        if (currentUser == null) {
          throw ServerException(message: '로그인되지 않은 상태입니다.');
        }
        
        // 임시 토큰 받기 - 학생 에이전트로 전환을 위해
        final credential = firebase_auth.EmailAuthProvider.credential(
          email: email,
          password: newPassword, // 이미 비밀번호를 알고 있다고 가정 (마스터 접근 권한)
        );
        
        // 지금은 예외가 발생할 것이지만, Firebase Admin SDK로 대체해야 함
        try {
          await _auth.signInWithCredential(credential);
          await _auth.currentUser?.updatePassword(newPassword);
          // 원래 사용자로 다시 로그인
          await _auth.signInWithEmailAndPassword(
            email: currentUser.email!,
            password: currentUser.email!, // 원래 비밀번호를 알 수 없으니 오류 발생할 것임
          );
        } catch (signInError) {
          // 예상대로 실패하고, 관리자 권한으로 관리해야 함을 로그로 남김
          debugPrint('학생 인증 각동 실패 (관리자 권한 필요): $signInError');
        }
        
        // Firestore에 업데이트 시간 기록
        await _firestore
            .collection('students')
            .doc(studentDoc.id)
            .update({
              'updatedAt': FieldValue.serverTimestamp(),
              // 실제 비밀번호는 저장하지 않고 Auth에서 관리
            });
        
        // 이 기능은 실제 프로덕션에서는 Cloud Functions를 통해 구현해야 함
        throw UnimplementedError('비밀번호 초기화는 Firebase Admin SDK나 Cloud Functions를 통해 구현해야 합니다.');
      } catch (authError) {
        throw ServerException(message: '인증 오류: $authError');
      }
    } catch (e) {
      if (e is UnimplementedError) {
        throw ServerException(message: e.toString());
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
      // Cloud Functions 서비스 호출 (사용자 권한 검증 등은 Cloud Functions에서 처리)
      final functions = FirebaseFunctions.instance;
      final callable = functions.httpsCallable('updateStudentGender');
      
      final result = await callable.call({
        'gender': gender,
      });
      
      if (result.data['success'] != true) {
        throw ServerException(message: result.data['message'] ?? '성별 업데이트 실패');
      }
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(message: '성별 업데이트 실패: $e');
    }
  }
}
