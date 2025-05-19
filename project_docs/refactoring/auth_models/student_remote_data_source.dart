import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:excel/excel.dart';

import '../../../../../core/error/exceptions.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/services/cloud_functions_service.dart';
import '../../../domain/entities/base_user.dart';
import '../../../domain/entities/student.dart' as entities;
import '../models/base_user_model.dart';
import '../models/student_model.dart';

abstract class StudentRemoteDataSource {
  /// 교사가 담당하는 학생 목록 조회
  Future<Either<Failure, List<StudentModel>>> getStudentsByTeacher(String teacherId);

  /// 학생 일괄 업로드 (Excel/CSV)
  Future<Either<Failure, List<StudentModel>>> uploadStudents({
    required List<Map<String, dynamic>> studentsData,
    required String teacherId,
    required String schoolCode,
    required String schoolName,
  });

  /// 학생 비밀번호 변경
  Future<Either<Failure, void>> changeStudentPassword({
    required String studentId,
    required String oldPassword,
    required String newPassword,
  });

  /// 학생 성별 업데이트
  Future<Either<Failure, void>> updateStudentGender({
    required String studentId,
    required String gender,
  });

  /// 학생 비밀번호 초기화 (교사 기능)
  Future<Either<Failure, void>> resetStudentPassword(String studentId);
}

class StudentRemoteDataSourceImpl implements StudentRemoteDataSource {
  final FirebaseFirestore _firestore;
  final CloudFunctionsService _cloudFunctions;

  StudentRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
    required CloudFunctionsService cloudFunctions,
  })  : _firestore = firestore,
        _cloudFunctions = cloudFunctions;

  @override
  Future<Either<Failure, List<StudentModel>>> getStudentsByTeacher(String teacherId) async {
    try {
      final studentsQuery = await _firestore
          .collection('students_details')
          .where('teacherId', isEqualTo: teacherId)
          .get();

      List<StudentModel> students = [];

      for (var doc in studentsQuery.docs) {
        // 각 학생의 기본 사용자 정보 가져오기
        final baseUserDoc = await _firestore
            .collection('users')
            .doc(doc.id)
            .get();
            
        if (baseUserDoc.exists) {
          final baseUserData = baseUserDoc.data()!;
          
          // BaseUserModel 생성
          final baseUser = BaseUserModel.fromJson({
            'id': doc.id,
            'email': baseUserData['email'],
            'displayName': baseUserData['displayName'] ?? '',
            'role': 'student',
            'createdAt': baseUserData['createdAt'] ?? Timestamp.now(),
            'updatedAt': baseUserData['updatedAt'],
          });
          
          // StudentModel 생성
          students.add(StudentModel.fromFirestore(doc, baseUser));
        } else {
          // 예전 구조와의 호환성을 위해 기본 사용자 정보가 없는 경우 처리
          final data = doc.data();
          final baseUser = BaseUserModel.fromFirebaseUser(
            doc.id,
            data['email'] ?? '',
            displayName: data['name'] ?? '',
            role: UserRole.student,
            createdAt: data['createdAt'] != null
                ? (data['createdAt'] as Timestamp).toDate()
                : DateTime.now(),
            updatedAt: data['updatedAt'] != null
                ? (data['updatedAt'] as Timestamp).toDate()
                : null,
          );
          
          students.add(StudentModel.fromFirestore(doc, baseUser));
        }
      }

      return Right(students);
    } catch (e) {
      return Left(ServerFailure(message: '학생 목록을 가져오는 중 오류가 발생했습니다: $e'));
    }
  }

  @override
  Future<Either<Failure, List<StudentModel>>> uploadStudents({
    required List<Map<String, dynamic>> studentsData,
    required String teacherId,
    required String schoolCode,
    required String schoolName,
  }) async {
    try {
      // Cloud Function을 통해 학생 계정 일괄 생성
      final result = await _cloudFunctions.createBulkStudentAccounts(
        studentsData: studentsData,
        teacherId: teacherId,
        schoolCode: schoolCode,
        schoolName: schoolName,
      );

      if (result.isLeft()) {
        return Left(result.fold(
          (failure) => failure,
          (_) => ServerFailure(message: '학생 계정 생성 중 오류가 발생했습니다.'),
        ));
      }

      // 생성된 학생 계정 목록 반환
      return getStudentsByTeacher(teacherId);
    } catch (e) {
      return Left(ServerFailure(message: '학생 업로드 중 오류가 발생했습니다: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> changeStudentPassword({
    required String studentId,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      // Firebase Auth API를 통해 비밀번호 변경 (현재는 Cloud Function 사용)
      final result = await _cloudFunctions.changeStudentPassword(
        studentId: studentId,
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

      if (result.isLeft()) {
        return Left(result.fold(
          (failure) => failure,
          (_) => ServerFailure(message: '비밀번호 변경 중 오류가 발생했습니다.'),
        ));
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: '비밀번호 변경 중 오류가 발생했습니다: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateStudentGender({
    required String studentId,
    required String gender,
  }) async {
    try {
      // Cloud Function을 통해 학생 성별 업데이트
      final result = await _cloudFunctions.updateStudentGender(
        studentId: studentId,
        gender: gender,
      );

      if (result.isLeft()) {
        return Left(result.fold(
          (failure) => failure,
          (_) => ServerFailure(message: '성별 정보 업데이트 중 오류가 발생했습니다.'),
        ));
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: '성별 정보 업데이트 중 오류가 발생했습니다: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> resetStudentPassword(String studentId) async {
    try {
      // Cloud Function을 통해 학생 비밀번호 초기화
      final result = await _cloudFunctions.resetStudentPassword(
        studentId: studentId,
      );

      if (result.isLeft()) {
        return Left(result.fold(
          (failure) => failure,
          (_) => ServerFailure(message: '비밀번호 초기화 중 오류가 발생했습니다.'),
        ));
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: '비밀번호 초기화 중 오류가 발생했습니다: $e'));
    }
  }

  // Excel 파일 파싱 메서드 (필요한 경우)
  List<Map<String, dynamic>> parseExcelFile(List<int> bytes) {
    final excel = Excel.decodeBytes(bytes);
    final sheet = excel.tables[excel.tables.keys.first];

    if (sheet == null || sheet.rows.isEmpty) {
      throw Exception('엑셀 파일이 비어있거나 형식이 올바르지 않습니다.');
    }

    // 헤더 행
    final headers = sheet.rows.first.map((cell) => cell?.value.toString() ?? '').toList();
    
    List<Map<String, dynamic>> result = [];

    // 데이터 행
    for (var i = 1; i < sheet.rows.length; i++) {
      final row = sheet.rows[i];
      Map<String, dynamic> rowData = {};
      
      for (var j = 0; j < headers.length && j < row.length; j++) {
        rowData[headers[j]] = row[j]?.value?.toString() ?? '';
      }
      
      result.add(rowData);
    }

    return result;
  }
}
