import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/base_user.dart';
import '../../domain/entities/teacher.dart';
import 'base_user_model.dart';

/// Teacher 엔티티의 데이터 모델 구현
/// Firestore 문서와 도메인 엔티티 사이의 변환을 담당
class TeacherModel extends Teacher {
  const TeacherModel({
    required super.baseUser,
    super.phoneNumber,
    super.isApproved,
    required super.schoolCode,
    required super.schoolName,
  });

  /// Firestore 문서에서 TeacherModel 객체 생성
  factory TeacherModel.fromFirestore(DocumentSnapshot doc, BaseUserModel baseUser) {
    final data = doc.data() as Map<String, dynamic>;
    
    return TeacherModel(
      baseUser: baseUser,
      phoneNumber: data['phoneNumber'] as String?,
      isApproved: data['isApproved'] as bool? ?? false,
      schoolCode: data['schoolCode'] as String? ?? '',
      schoolName: data['schoolName'] as String? ?? '',
    );
  }

  /// Map에서 TeacherModel 객체 생성 (두 컬렉션 데이터 결합 시 사용)
  factory TeacherModel.fromJson(Map<String, dynamic> json, BaseUserModel baseUser) {
    return TeacherModel(
      baseUser: baseUser,
      phoneNumber: json['phoneNumber'] as String?,
      isApproved: json['isApproved'] as bool? ?? false,
      schoolCode: json['schoolCode'] as String? ?? '',
      schoolName: json['schoolName'] as String? ?? '',
    );
  }

  /// TeacherModel 객체를 Firestore 문서로 변환
  Map<String, dynamic> toFirestore() {
    return {
      'phoneNumber': phoneNumber,
      'isApproved': isApproved,
      'schoolCode': schoolCode,
      'schoolName': schoolName,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// 도메인 엔티티에서 TeacherModel 생성
  factory TeacherModel.fromEntity(Teacher teacher) {
    return TeacherModel(
      baseUser: teacher.baseUser is BaseUserModel 
        ? teacher.baseUser as BaseUserModel
        : BaseUserModel.fromEntity(teacher.baseUser),
      phoneNumber: teacher.phoneNumber,
      isApproved: teacher.isApproved,
      schoolCode: teacher.schoolCode,
      schoolName: teacher.schoolName,
    );
  }
}
