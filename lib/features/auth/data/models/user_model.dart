import '../../domain/entities/user.dart';

/// User 엔티티의 데이터 모델 구현
/// Firestore 문서와 도메인 엔티티 사이의 변환을 담당
class UserModel extends User {
  UserModel({
    required super.id,
    super.email,
    required super.displayName,
    required super.role,
    super.schoolId,
    super.classNum,
    super.studentNum,
    super.gender,
  });

  /// Firestore 문서에서 UserModel 객체 생성
  factory UserModel.fromJson(Map<String, dynamic> json) {
    final roleStr = json['role'] as String? ?? 'student';
    final role = roleStr == 'teacher' ? UserRole.teacher : UserRole.student;

    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String?,
      displayName: json['displayName'] as String? ?? '',
      role: role,
      schoolId: json['schoolId'] as String?,
      classNum: json['classId'] as String?,
      studentNum: json['studentNumber'] as String?,
      gender: json['gender'] as String?,
    );
  }

  /// UserModel 객체를 Firestore 문서로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'role': role == UserRole.teacher ? 'teacher' : 'student',
      'schoolId': schoolId,
      'classId': classNum,
      'studentNumber': studentNum,
      'gender': gender,
    };
  }

  /// Firebase Auth User와 추가 정보로부터 UserModel 생성
  factory UserModel.fromFirebaseUser(
    String userId,
    String email, {
    required Map<String, dynamic> userData,
  }) {
    final roleStr = userData['role'] as String? ?? 'student';
    final role = roleStr == 'teacher' ? UserRole.teacher : UserRole.student;

    return UserModel(
      id: userId,
      email: email,
      role: role,
      displayName: userData['displayName'] as String? ?? '',
      schoolId: userData['schoolId'] as String?,
      classNum: userData['classId'] as String?,
      studentNum: userData['studentNumber'] as String?,
      gender: userData['gender'] as String?,
    );
  }

  /// 도메인 엔티티에서 UserModel 생성
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      displayName: user.displayName,
      role: user.role,
      schoolId: user.schoolId,
      classNum: user.classNum,
      studentNum: user.studentNum,
      gender: user.gender,
    );
  }
}
