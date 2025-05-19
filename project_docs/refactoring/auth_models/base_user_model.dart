import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/base_user.dart';

/// BaseUser 엔티티의 데이터 모델 구현
/// Firestore 문서와 도메인 엔티티 사이의 변환을 담당
class BaseUserModel extends BaseUser {
  const BaseUserModel({
    required super.id,
    super.email,
    required super.displayName,
    required super.role,
    required super.createdAt,
    super.updatedAt,
  });

  /// Firestore 문서에서 BaseUserModel 객체 생성
  factory BaseUserModel.fromJson(Map<String, dynamic> json) {
    // 'role' 문자열로부터 UserRole enum 값 추출
    final roleStr = json['role'] as String? ?? 'student';
    UserRole role;
    
    if (roleStr == 'admin') {
      role = UserRole.admin;
    } else if (roleStr == 'teacher') {
      role = UserRole.teacher;
    } else {
      role = UserRole.student;
    }

    return BaseUserModel(
      id: json['id'] as String,
      email: json['email'] as String?,
      displayName: json['displayName'] as String? ?? '',
      role: role,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// BaseUserModel 객체를 Firestore 문서로 변환
  Map<String, dynamic> toJson() {
    String roleStr;
    switch (role) {
      case UserRole.admin:
        roleStr = 'admin';
        break;
      case UserRole.teacher:
        roleStr = 'teacher';
        break;
      case UserRole.student:
        roleStr = 'student';
        break;
    }

    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'role': roleStr,
      'createdAt': createdAt,
      'updatedAt': updatedAt ?? FieldValue.serverTimestamp(),
    };
  }

  /// Firebase Auth User와 추가 정보로부터 BaseUserModel 생성
  factory BaseUserModel.fromFirebaseUser(
    String userId,
    String? email, {
    required String displayName,
    required UserRole role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BaseUserModel(
      id: userId,
      email: email,
      displayName: displayName,
      role: role,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt,
    );
  }

  /// 도메인 엔티티에서 BaseUserModel 생성
  factory BaseUserModel.fromEntity(BaseUser user) {
    return BaseUserModel(
      id: user.id,
      email: user.email,
      displayName: user.displayName,
      role: user.role,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }
}
