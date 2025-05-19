import 'package:equatable/equatable.dart';

import 'base_user.dart';

/// 관리자 엔티티
///
/// 관리자에 관한 세부 정보를 담고 있는 엔티티입니다.
class Admin extends Equatable {
  /// 기본 사용자 정보
  final BaseUser baseUser;

  /// 관리자 레벨 (높을 수록 권한이 큼)
  final int level;
  
  /// 생성자
  const Admin({
    required this.baseUser,
    this.level = 1,
  });

  /// 편의를 위한 getter들
  String get id => baseUser.id;
  String? get email => baseUser.email;
  String get displayName => baseUser.displayName;
  DateTime get createdAt => baseUser.createdAt;
  DateTime? get updatedAt => baseUser.updatedAt;

  /// 슈퍼 관리자 여부
  bool get isSuperAdmin => level >= 10;

  @override
  List<Object?> get props => [
    baseUser,
    level,
  ];

  @override
  String toString() {
    return 'Admin{id: ${baseUser.id}, email: ${baseUser.email}, displayName: ${baseUser.displayName}, level: $level}';
  }
}
