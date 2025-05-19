import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/admin.dart';
import '../../domain/entities/base_user.dart';
import 'base_user_model.dart';

/// Admin 엔티티의 데이터 모델 구현
/// Firestore 문서와 도메인 엔티티 사이의 변환을 담당
class AdminModel extends Admin {
  const AdminModel({
    required super.baseUser,
    super.level,
  });

  /// Firestore 문서에서 AdminModel 객체 생성
  factory AdminModel.fromFirestore(DocumentSnapshot doc, BaseUserModel baseUser) {
    final data = doc.data() as Map<String, dynamic>;
    
    return AdminModel(
      baseUser: baseUser,
      level: data['level'] as int? ?? 1,
    );
  }

  /// Map에서 AdminModel 객체 생성 (두 컬렉션 데이터 결합 시 사용)
  factory AdminModel.fromJson(Map<String, dynamic> json, BaseUserModel baseUser) {
    return AdminModel(
      baseUser: baseUser,
      level: json['level'] as int? ?? 1,
    );
  }

  /// AdminModel 객체를 Firestore 문서로 변환
  Map<String, dynamic> toFirestore() {
    return {
      'level': level,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// 도메인 엔티티에서 AdminModel 생성
  factory AdminModel.fromEntity(Admin admin) {
    return AdminModel(
      baseUser: admin.baseUser is BaseUserModel 
        ? admin.baseUser as BaseUserModel
        : BaseUserModel.fromEntity(admin.baseUser),
      level: admin.level,
    );
  }
}
