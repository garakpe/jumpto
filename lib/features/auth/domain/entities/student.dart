import 'package:equatable/equatable.dart';

/// 학생 엔티티
///
/// 학생 정보를 표현하는 클래스입니다.
class Student extends Equatable {
  /// 학생 고유 ID (Firebase Firestore 문서 ID)
  final String id;
  
  /// Firebase Authentication UID
  final String? authUid;
  
  /// 시스템 생성 이메일 (학생 인증용, 예: '학번@학교코드.school')
  final String? email;
  
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
  
  /// 학교 코드
  final String schoolCode;
  
  /// 학교 이름
  final String schoolName;
  
  /// 출석 여부
  final bool attendance;
  
  /// 생성 일시
  final DateTime createdAt;
  
  /// 마지막 수정 일시
  final DateTime? updatedAt;
  
  /// 비밀번호 (초기 비밀번호 설정 용도, 실제 저장되진 않음)
  final String? password;

  /// 성별 ("남"/"여")
  final String? gender;

  const Student({
    required this.id,
    this.authUid,
    this.email,
    required this.name,
    required this.grade,
    required this.classNum,
    required this.studentNum,
    required this.studentId,
    required this.teacherId,
    required this.schoolCode,
    required this.schoolName,
    this.attendance = true,
    required this.createdAt,
    this.updatedAt,
    this.password,
    this.gender,
  });

  @override
  List<Object?> get props => [
    id, authUid, email, name, grade, classNum, studentNum, 
    studentId, teacherId, schoolCode, schoolName,
    attendance, createdAt, updatedAt, gender
  ];
}
