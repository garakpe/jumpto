import 'package:equatable/equatable.dart';

import 'base_user.dart';

/// 교사 엔티티
///
/// 교사에 관한 세부 정보를 담고 있는 엔티티입니다.
class Teacher extends Equatable {
  /// 기본 사용자 정보
  final BaseUser baseUser;

  /// 교사 전화번호
  final String? phoneNumber;

  /// 계정 승인 상태
  final bool isApproved;

  /// 학교 코드
  final String schoolCode;

  /// 학교 이름
  final String schoolName;

  /// 생성자
  const Teacher({
    required this.baseUser,
    this.phoneNumber,
    this.isApproved = false,
    required this.schoolCode,
    required this.schoolName,
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
    phoneNumber,
    isApproved,
    schoolCode,
    schoolName,
  ];

  @override
  String toString() {
    return 'Teacher{id: ${baseUser.id}, email: ${baseUser.email}, displayName: ${baseUser.displayName}, schoolName: $schoolName, isApproved: $isApproved}';
  }
}
