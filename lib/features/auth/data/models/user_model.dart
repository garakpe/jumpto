import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/user.dart';

part 'user_model.g.dart';

/// User 엔티티의 데이터 모델 구현
/// Firestore 문서와 도메인 엔티티 사이의 변환을 담당
@JsonSerializable()
class UserModel extends User {
  const UserModel({
    required String id,
    required String email,
    required String role,
    String? name,
    bool isApproved = false,
    int? maxStudents,
    String? schoolName,
    String? grade,
    String? classNumber,
    String? studentNumber,
    String? gender,
  }) : super(
          id: id,
          email: email,
          role: role,
          name: name,
          isApproved: isApproved,
          maxStudents: maxStudents,
          schoolName: schoolName,
          grade: grade,
          classNumber: classNumber,
          studentNumber: studentNumber,
          gender: gender,
        );

  /// Firestore 문서에서 UserModel 객체 생성
  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  /// UserModel 객체를 Firestore 문서로 변환
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  /// Firebase Auth User와 추가 정보로부터 UserModel 생성
  factory UserModel.fromFirebaseUser(
    String userId,
    String email, {
    required Map<String, dynamic> userData,
  }) {
    return UserModel(
      id: userId,
      email: email,
      role: userData['role'] as String? ?? 'student',
      name: userData['name'] as String?,
      isApproved: userData['isApproved'] as bool? ?? false,
      maxStudents: userData['maxStudents'] as int?,
      schoolName: userData['schoolName'] as String?,
      grade: userData['grade'] as String?,
      classNumber: userData['classNumber'] as String?,
      studentNumber: userData['studentNumber'] as String?,
      gender: userData['gender'] as String?,
    );
  }

  /// 도메인 엔티티에서 UserModel 생성
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      role: user.role,
      name: user.name,
      isApproved: user.isApproved,
      maxStudents: user.maxStudents,
      schoolName: user.schoolName,
      grade: user.grade,
      classNumber: user.classNumber,
      studentNumber: user.studentNumber,
      gender: user.gender,
    );
  }
}
