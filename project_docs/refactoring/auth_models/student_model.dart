import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/base_user.dart';
import '../../domain/entities/student.dart';
import 'base_user_model.dart';

/// Student 엔티티의 데이터 모델 구현
/// Firestore 문서와 도메인 엔티티 사이의 변환을 담당
class StudentModel extends Student {
  const StudentModel({
    required super.baseUser,
    required super.grade,
    required super.classNum,
    required super.studentNum,
    required super.studentId,
    required super.teacherId,
    required super.schoolCode,
    required super.schoolName,
    super.attendance,
    super.gender,
    super.password,
  });

  /// Firestore 문서에서 StudentModel 객체 생성
  factory StudentModel.fromFirestore(DocumentSnapshot doc, BaseUserModel baseUser) {
    final data = doc.data() as Map<String, dynamic>;
    
    return StudentModel(
      baseUser: baseUser,
      grade: data['grade'] ?? '',
      classNum: data['classNum'] ?? '',
      studentNum: data['studentNum'] ?? '',
      studentId: data['studentId'] ?? '',
      teacherId: data['teacherId'] ?? '',
      schoolCode: data['schoolCode'] ?? '',
      schoolName: data['schoolName'] ?? '',
      attendance: data['attendance'] ?? true,
      gender: data['gender'],
    );
  }

  /// Map 객체에서 StudentModel 생성 (CSV/Excel 업로드 용)
  factory StudentModel.fromMap(
    Map<String, dynamic> map, {
    required String teacherId,
    required String schoolCode,
    required String schoolName,
    String? email,
    required BaseUserModel baseUser,
  }) {
    // 학년, 반, 번호를 이용해 학번 생성
    final grade = map['grade']?.toString() ?? '';
    final classNum = map['classNum']?.toString().padLeft(2, '0') ?? '';
    final studentNum = map['studentNum']?.toString().padLeft(2, '0') ?? '';
    final studentId = '$grade$classNum$studentNum';

    return StudentModel(
      baseUser: baseUser,
      grade: grade,
      classNum: classNum,
      studentNum: studentNum,
      studentId: studentId,
      teacherId: teacherId,
      schoolCode: schoolCode,
      schoolName: schoolName,
      attendance: map['attendance'] ?? true,
      gender: map['gender'],
      password: map['password'] ?? '123456', // 초기 비밀번호 (업로드 시에만 사용)
    );
  }

  /// Firestore에 저장할 Map 객체로 변환
  Map<String, dynamic> toFirestore() {
    final map = {
      'grade': grade,
      'classNum': classNum,
      'studentNum': studentNum,
      'studentId': studentId,
      'teacherId': teacherId,
      'schoolCode': schoolCode,
      'schoolName': schoolName,
      'attendance': attendance,
      'gender': gender,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    
    // password가 있는 경우에만 추가 (Cloud Function 트리거를 위해 필요)
    // 새 구조에서는 Cloud Functions에서 처리 후 자동으로 삭제
    if (password != null && password!.isNotEmpty) {
      map['password'] = password;
    }

    return map;
  }

  /// 이메일 생성 로직 (새로운 학생 계정 생성 시 필요)
  static String generateStudentEmail(String studentId, String schoolCode) {
    // 현재 연도에서 뒤 두자리 가져오기 (2025 → 25)
    final DateTime now = DateTime.now();
    final String currentYearSuffix = now.year.toString().substring(2);
    
    // 학교 코드의 마지막 4자리만 추출
    String codeStr = schoolCode;
    String emailSchoolCode = 'default';
    
    if (codeStr.isNotEmpty) {
      if (codeStr.length >= 4) {
        emailSchoolCode = codeStr.substring(codeStr.length - 4);
      } else {
        emailSchoolCode = codeStr.padLeft(4, '0');
      }
    }
    
    // 이메일 형식: "(연도 두자리)(학번)@school(학교코드 뒤 4자리).com"
    return '$currentYearSuffix$studentId@school$emailSchoolCode.com';
  }

  /// 도메인 엔티티에서 StudentModel 생성
  factory StudentModel.fromEntity(Student student) {
    return StudentModel(
      baseUser: student.baseUser is BaseUserModel 
        ? student.baseUser as BaseUserModel
        : BaseUserModel.fromEntity(student.baseUser),
      grade: student.grade,
      classNum: student.classNum,
      studentNum: student.studentNum,
      studentId: student.studentId,
      teacherId: student.teacherId,
      schoolCode: student.schoolCode,
      schoolName: student.schoolName,
      attendance: student.attendance,
      gender: student.gender,
      password: student.password,
    );
  }
}
