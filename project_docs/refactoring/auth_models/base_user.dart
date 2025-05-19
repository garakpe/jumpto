import 'package:equatable/equatable.dart';

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

/// 기본 사용자 엔티티 (BaseUser)
///
/// 모든 사용자 유형이 공유하는 기본 정보를 담습니다.
class BaseUser extends Equatable {
  /// 사용자 ID (Firebase Auth UID)
  final String id;

  /// 이메일
  final String? email;

  /// 이름
  final String displayName;

  /// 사용자 역할
  final UserRole role;

  /// 생성일시
  final DateTime createdAt;

  /// 마지막 수정일시
  final DateTime? updatedAt;

  /// 생성자
  const BaseUser({
    required this.id,
    this.email,
    required this.displayName,
    required this.role,
    required this.createdAt,
    this.updatedAt,
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
  List<Object?> get props => [
    id, 
    email, 
    displayName, 
    role, 
    createdAt, 
    updatedAt
  ];

  @override
  String toString() {
    return 'BaseUser{id: $id, email: $email, displayName: $displayName, role: $role}';
  }
}
