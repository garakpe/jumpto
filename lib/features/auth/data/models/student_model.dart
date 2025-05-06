import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/student.dart';

/// 학생 모델
///
/// Student 엔티티의 데이터 계층 구현체
class StudentModel extends Student {
  const StudentModel({
    required super.id,
    super.authUid,
    super.email,
    required super.name,
    required super.grade,
    required super.classNum,
    required super.studentNum,
    required super.studentId,
    required super.teacherId,
    required super.schoolId,
    required super.schoolName,
    super.attendance = true,
    required super.createdAt,
    super.updatedAt,
    super.password,
    super.gender,
  });

  /// Firestore 문서에서 StudentModel 생성
  factory StudentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StudentModel(
      id: doc.id,
      authUid: data['authUid'],
      email: data['email'],
      name: data['name'] ?? '',
      grade: data['grade'] ?? '',
      classNum: data['classNum'] ?? '',
      studentNum: data['studentNum'] ?? '',
      studentId: data['studentId'] ?? '',
      teacherId: data['teacherId'] ?? '',
      schoolId: data['schoolId'] ?? '',
      schoolName: data['schoolName'] ?? '',
      attendance: data['attendance'] ?? true,
      createdAt: data['createdAt'] != null 
        ? (data['createdAt'] as Timestamp).toDate() 
        : DateTime.now(),
      updatedAt: data['updatedAt'] != null
        ? (data['updatedAt'] as Timestamp).toDate()
        : null,
      // 비밀번호는 보안상 제외 (Firebase Auth에서 관리)
      gender: data['gender'],
    );
  }

  /// Map 객체에서 StudentModel 생성 (CSV/Excel 업로드 용)
  factory StudentModel.fromMap(Map<String, dynamic> map, {required String teacherId, required String schoolId, required String schoolName}) {
    // 학년, 반, 번호를 이용해 학번 생성
    final grade = map['grade']?.toString() ?? '';
    final classNum = map['classNum']?.toString().padLeft(2, '0') ?? '';
    final studentNum = map['studentNum']?.toString().padLeft(2, '0') ?? '';
    final studentId = '$grade$classNum$studentNum';
    
    // 시스템 생성 이메일 형식: 학번@학교코드.school
    final email = '$studentId@$schoolId.school';
    
    return StudentModel(
      id: map['id'] ?? '', // Firestore에서 자동 생성될 ID
      authUid: map['authUid'], // 나중에 생성될 Firebase Auth UID
      email: email, // 시스템 생성 이메일
      name: map['name'] ?? '',
      grade: grade,
      classNum: classNum,
      studentNum: studentNum,
      studentId: studentId,
      teacherId: teacherId,
      schoolId: schoolId,
      schoolName: schoolName,
      attendance: map['attendance'] ?? true,
      createdAt: map['createdAt'] != null 
        ? (map['createdAt'] as Timestamp).toDate() 
        : DateTime.now(),
      password: map['password'] ?? '1234', // 초기 비밀번호 (업로드 시에만 사용)
      gender: map['gender'],
    );
  }

  /// Firestore에 저장할 Map 객체로 변환
  Map<String, dynamic> toFirestore() {
    final map = {
      'name': name,
      'grade': grade,
      'classNum': classNum,
      'studentNum': studentNum,
      'studentId': studentId,
      'teacherId': teacherId,
      'schoolId': schoolId,
      'schoolName': schoolName,
      'attendance': attendance,
      'gender': gender,
      'email': email,
      // 업데이트 시에는 updatedAt 사용, 생성 시에는 createdAt 사용
      'updatedAt': FieldValue.serverTimestamp(),
    };
    
    // id가 없는 경우 (새로 생성) createdAt 추가
    if (id.isEmpty) {
      map['createdAt'] = FieldValue.serverTimestamp();
    }
    
    // authUid가 있는 경우에만 추가 (null이 아닐 때)
    if (authUid != null) {
      map['authUid'] = authUid;
    }
    
    return map;
  }

  /// Entity를 Model로 변환
  factory StudentModel.fromEntity(Student entity) {
    return StudentModel(
      id: entity.id,
      authUid: entity.authUid,
      email: entity.email,
      name: entity.name,
      grade: entity.grade,
      classNum: entity.classNum,
      studentNum: entity.studentNum,
      studentId: entity.studentId,
      teacherId: entity.teacherId,
      schoolId: entity.schoolId,
      schoolName: entity.schoolName,
      attendance: entity.attendance,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      password: entity.password,
      gender: entity.gender,
    );
  }
}
