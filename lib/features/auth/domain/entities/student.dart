import 'package:equatable/equatable.dart';

/// 학생 엔티티
///
/// 학생 정보를 표현하는 클래스입니다.
class Student extends Equatable {
  /// 학생 고유 ID (Firebase 자동 생성)
  final String id;
  
  /// 학생 이름
  final String name;
  
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
  
  /// 학교 ID
  final String schoolId;
  
  /// 학교 이름
  final String schoolName;
  
  /// 출석 여부
  final bool attendance;
  
  /// 생성 일시
  final DateTime createdAt;
  
  /// 비밀번호 (초기 비밀번호 설정 용도)
  final String? password;

  const Student({
    required this.id,
    required this.name,
    required this.grade,
    required this.classNum,
    required this.studentNum,
    required this.studentId,
    required this.teacherId,
    required this.schoolId,
    required this.schoolName,
    this.attendance = true,
    required this.createdAt,
    this.password,
  });

  @override
  List<Object?> get props => [
    id, name, grade, classNum, studentNum, 
    studentId, teacherId, schoolId, schoolName,
    attendance, createdAt
  ];
}
