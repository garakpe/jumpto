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
  required String grade,
  required String classNum,
  required String studentNum,
  required String gender,
  String? initialPassword,
  required firebase_auth.FirebaseAuth firebaseAuth,
  required FirebaseFirestore firestore,
  required CloudFunctionsService cloudFunctionsService,
}) async {
  try {
    // 컬렉션 참조
    final usersCollection = firestore.collection('users');
    
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

    // Cloud Functions를 통해 학생 계정 생성
    try {
      final students = [{
        'grade': formattedGrade,
        'classNum': formattedClassNum,
        'studentNum': formattedStudentNum,
        'name': displayName,
        'gender': gender,
      }];
      
      // Cloud Functions를 호출하여 학생 계정 생성
      final result = await cloudFunctionsService.createBulkStudentAccounts(
        students: students,
        schoolCode: schoolCode,
        schoolName: schoolName,
        initialPassword: password,
      );
      
      if (result['success'] == true) {
        debugPrint('학생 계정 생성 성공');
        
        // 성공한 학생 정보 가져오기
        final successList = result['results']['success'] as List<dynamic>;
        
        // 생성된 학생이 있는지 확인
        if (successList.isEmpty) {
          throw ServerException(message: '학생 계정 생성에 실패했습니다.');
        }
        
        // 첫 번째(유일한) 생성된 학생 정보
        final successData = successList.first;
        
        // 사용자 데이터 반환
        return domain.User(
          id: successData['docId'],
          authUid: successData['authUid'],
          email: successData['email'],
          displayName: displayName,
          role: domain.UserRole.student,
          schoolCode: schoolCode,
          schoolName: schoolName,
          grade: formattedGrade,
          classNum: formattedClassNum,
          studentNum: formattedStudentNum,
          studentId: successData['studentId'],
          gender: gender,
        );
      } else {
        throw ServerException(message: '학생 계정 생성에 실패했습니다: ${result['message']}');
      }
    } catch (e) {
      debugPrint('Cloud Functions 호출 중 오류: $e');
      throw ServerException(message: '학생 계정 생성 중 오류가 발생했습니다: $e');
    }
  } catch (e) {
    debugPrint('학생 계정 생성 오류: $e');
    throw ServerException(message: '학생 계정 생성 실패: ${e.toString()}');
  }
}