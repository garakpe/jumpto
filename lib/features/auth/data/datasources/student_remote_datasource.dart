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
  Future<List<StudentModel>> getStudentsByClass(
    String teacherId,
    String grade,
    String classNum,
  );

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
      final querySnapshot =
          await _firestore
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
      final querySnapshot =
          await _firestore
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
  Future<List<StudentModel>> getStudentsByClass(
    String teacherId,
    String grade,
    String classNum,
  ) async {
    try {
      final querySnapshot =
          await _firestore
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
      final docRef = await _firestore
          .collection('students')
          .add(student.toFirestore());

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

      // 현재 로그인한 교사 정보 가져오기
      String teacherSchoolName = '';
      String teacherSchoolCode = '';
      try {
        final currentUser = _auth.currentUser;
        if (currentUser != null) {
          final teacherDoc =
              await _firestore
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

      // 학생 정보 로그 출력
      for (final student in students) {
        debugPrint(
          '학생 정보: 이름=${student.name}, 학번=${student.studentId}, 학교=${student.schoolName}',
        );
      }

      // Cloud Functions를 통해 학생 계정 일괄 생성
      try {
        debugPrint('학생 계정 일괄 생성 시도 (${students.length}명)');

        // 학생 목록을 Cloud Functions에 맞는 형식으로 변환
        final studentsList =
            students
                .map(
                  (student) => {
                    'grade': student.grade,
                    'classNum': student.classNum,
                    'studentNum': student.studentNum,
                    'name': student.name,
                    'gender': student.gender,
                  },
                )
                .toList();

        // 학교 코드 처리는 서버에서 수행하미로 미리 처리할 필요 없음
        // 서버에서 학교 정보 처리 시 일관성 보장
        String shortSchoolCode = teacherSchoolCode;

        // Cloud Functions를 호출하여 학생 계정 일괄 생성
        final result = await _cloudFunctionsService.createBulkStudentAccounts(
          students: students,
          schoolCode: shortSchoolCode,
          schoolName: teacherSchoolName,
          initialPassword: '123456', // 고정 초기 비밀번호
        );

        if (result['success'] == true) {
          debugPrint('학생 계정 일괄 생성 성공: ${result['message']}');

          // 성공한 학생 목록을 처리
          final successList = result['results']['success'] as List<dynamic>;

          for (final successData in successList) {
            // Cloud Functions에서 반환한 정보로 StudentModel 생성
            final studentModel = StudentModel(
              id: successData['docId'],
              authUid: successData['authUid'],
              email: successData['email'],
              name: successData['name'],
              studentId: successData['studentId'],
              grade:
                  students
                      .firstWhere(
                        (s) => s.name == successData['name'],
                        orElse: () => students.first,
                      )
                      .grade,
              classNum:
                  students
                      .firstWhere(
                        (s) => s.name == successData['name'],
                        orElse: () => students.first,
                      )
                      .classNum,
              studentNum:
                  students
                      .firstWhere(
                        (s) => s.name == successData['name'],
                        orElse: () => students.first,
                      )
                      .studentNum,
              teacherId: _auth.currentUser?.uid ?? '',
              schoolCode: shortSchoolCode,
              schoolName: teacherSchoolName,
              attendance: true,
              gender:
                  students
                      .firstWhere(
                        (s) => s.name == successData['name'],
                        orElse: () => students.first,
                      )
                      .gender,
              createdAt: DateTime.now(),
            );

            createdStudents.add(studentModel);
          }

          // 실패한 학생 목록을 로그로 기록
          final failureList = result['results']['failure'] as List<dynamic>;
          for (final failureData in failureList) {
            debugPrint('학생 생성 실패: ${failureData['error']}');
          }
        } else {
          throw ServerException(message: '학생 일괄 생성 실패: ${result['message']}');
        }
      } catch (e) {
        debugPrint('Cloud Functions 호출 중 오류: $e');
        throw ServerException(message: '학생 계정 생성 중 오류가 발생했습니다: $e');
      }

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
      final docSnapshot =
          await _firestore.collection('students').doc(student.id).get();
      return StudentModel.fromFirestore(docSnapshot);
    } catch (e) {
      throw ServerException(message: '학생 정보 업데이트 실패: $e');
    }
  }

  @override
  Future<void> resetStudentPassword(
    String studentId,
    String newPassword,
  ) async {
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
      final querySnapshot =
          await _firestore
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
