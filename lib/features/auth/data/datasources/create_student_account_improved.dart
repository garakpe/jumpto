import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../../../core/firebase/cloud_functions_service.dart';
import '../../../../core/error/exceptions.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/user.dart' as domain;

/// 학생 계정 생성 함수 - 개선된 버전
/// 
/// 클린 아키텍처 기반 고품질 코드 제공
Future<domain.User> createStudentAccount({
  required String displayName,
  required String grade,        // 학년 매개변수 추가
  required String classNum,
  required String studentNum,
  required String gender,
  String? initialPassword,
  required firebase_auth.FirebaseAuth firebaseAuth,
  required FirebaseFirestore firestore,
}) async {
  try {
    // 컬렉션 참조
    final usersCollection = firestore.collection('users');
    final studentsCollection = firestore.collection('students');
    
    // 현재 로그인한 교사 ID 가져오기
    final currentUser = firebaseAuth.currentUser;
    if (currentUser == null) {
      throw ServerException(message: '로그인이 필요합니다.');
    }

    final teacherId = currentUser.uid;

    // 교사 정보 가져오기
    final teacherDoc = await usersCollection.doc(teacherId).get();
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
    final formattedClassNum = classNum.padLeft(2, '0'); // 반은 2자리로 표시 (01, 02 등)
    final formattedStudentNum = studentNum.padLeft(2, '0'); // 번호는 2자리로 표시 (01, 02 등)
    
    final studentId = '$formattedGrade$formattedClassNum$formattedStudentNum';

    // 비밀번호 설정 (기본값: 123456, Firebase 요구사항 충족을 위한 6자리 이상)
    final password = initialPassword ?? '123456';

    // 학생 이메일 형식: "(연도 두자리)(학번)@school(학교코드 뒤 4자리).com"
    // 예: 가락고등학교 3학년 1반 1번 학생, 25년도 → 2530101@school3550.com
    final DateTime now = DateTime.now();
    final String currentYearSuffix = now.year.toString().substring(2);
    final studentEmail = '$currentYearSuffix$studentId@school$schoolCode.com';

    // Firebase Auth로 학생 계정 생성
    final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
      email: studentEmail,
      password: password,
    );

    final uid = userCredential.user!.uid;

    // Firestore에 학생 정보 저장
    await usersCollection.doc(uid).set({
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
    await studentsCollection.doc(uid).set({
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
    throw ServerException(message: '학생 계정 생성 실패: ${e.toString()}');
  }
}
