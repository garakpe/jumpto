/// 사용자 역할 (관리자/교사/학생)
enum UserRole {
  admin('관리자'),
  teacher('교사'),
  student('학생');

  final String koreanName;

  const UserRole(this.koreanName);

  @override
  String toString() => koreanName;
}

/// 사용자 엔티티
///
/// 인증된 사용자 정보를 표현하는 클래스
class User {
  /// 사용자 ID
  final String id;

  /// 이메일
  final String? email;

  /// 이름
  final String displayName;

  /// 사용자 역할
  final UserRole role;

  /// 학교 ID (선택)
  final String? schoolId;

  /// 학교명 (선택)
  final String? schoolName;

  /// 학년 (선택)
  final String? grade;

  /// 학반 (선택)
  final String? classNum;

  /// 학생 번호 (학생인 경우)
  final String? studentNum;

  /// 학번 (학생인 경우, classNum + studentNum)
  final String? studentId;

  /// 성별 (학생인 경우)
  final String? gender;

  /// 핸드폰 번호 (교사인 경우)
  final String? phoneNumber;

  /// 계정 승인 상태 (교사인 경우)
  final bool isApproved;

  /// 생성자
  User({
    required this.id,
    this.email,
    required this.displayName,
    required this.role,
    this.schoolId,
    this.schoolName,
    this.grade,
    this.classNum,
    this.studentNum,
    this.studentId,
    this.gender,
    this.phoneNumber,
    this.isApproved = false,
  });

  /// 익명 사용자 여부
  bool get isAnonymous => id.isEmpty;

  /// 교사 여부
  bool get isTeacher => role == UserRole.teacher;

  /// 학생 여부
  bool get isStudent => role == UserRole.student;

  /// 관리자 여부
  bool get isAdmin => role == UserRole.admin;

  @override
  String toString() {
    return 'User{id: $id, email: $email, displayName: $displayName, role: $role}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          id == other.id &&
          email == other.email &&
          displayName == other.displayName &&
          role == other.role);

  @override
  int get hashCode =>
      id.hashCode ^ email.hashCode ^ displayName.hashCode ^ role.hashCode;
}
