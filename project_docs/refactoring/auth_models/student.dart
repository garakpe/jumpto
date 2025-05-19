import 'package:equatable/equatable.dart';

import 'base_user.dart';

/// 학생 엔티티
///
/// 학생에 관한 세부 정보를 담고 있는 엔티티입니다.
class Student extends Equatable {
  /// 기본 사용자 정보
  final BaseUser baseUser;
  
  /// 학년 (문자열, 예: "1", "2", "3")
  final String grade;
  
  /// 반 번호 (두자리 문자열, 예: "01", "02")
  final String classNum;
  
  /// 학생 번호 (두자리 문자열, 예: "01", "02")
  final String studentNum;
  
  /// 학번 (grade + classNum + studentNum, 예: "10101")
  final String studentId;
  
  /// 관리 교사 ID
  final String teacherId;
  
  /// 학교 코드
  final String schoolCode;
  
  /// 학교 이름
  final String schoolName;
  
  /// 출석 여부
  final bool attendance;
  
  /// 성별 ("남"/"여")
  final String? gender;

  /// 비밀번호 (초기 비밀번호 설정 용도, 실제 저장되진 않음)
  final String? password;

  const Student({
    required this.baseUser,
    required this.grade,
    required this.classNum,
    required this.studentNum,
    required this.studentId,
    required this.teacherId,
    required this.schoolCode,
    required this.schoolName,
    this.attendance = true,
    this.gender,
    this.password,
  });

  /// 편의를 위한 getter들
  String get id => baseUser.id;
  String? get email => baseUser.email;
  String get displayName => baseUser.displayName;
  DateTime get createdAt => baseUser.createdAt;
  DateTime? get updatedAt => baseUser.updatedAt;

  @override
  List<Object?> get props => [
    baseUser,
    grade, 
    classNum, 
    studentNum, 
    studentId, 
    teacherId, 
    schoolCode, 
    schoolName,
    attendance, 
    gender
  ];

  @override
  String toString() {
    return 'Student{id: ${baseUser.id}, name: ${baseUser.displayName}, grade: $grade, class: $classNum, number: $studentNum, studentId: $studentId}';
  }
}
