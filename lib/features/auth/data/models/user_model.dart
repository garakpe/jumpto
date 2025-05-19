import '../../domain/entities/user.dart';

/// User 엔티티의 데이터 모델 구현
/// Firestore 문서와 도메인 엔티티 사이의 변환을 담당
class UserModel extends User {
  UserModel({
    required super.id,
    super.authUid,
    super.email,
    required super.displayName,
    required super.role,
    super.schoolCode,
    super.schoolName,
    super.grade,
    super.classNum,
    super.studentNum,
    super.studentId,
    super.gender,
    super.phoneNumber,
    super.isApproved,
  });

  /// Firestore 문서에서 UserModel 객체 생성
  factory UserModel.fromJson(Map<String, dynamic> json) {
    final roleStr = json['role'] as String? ?? 'student';
    UserRole role;
    
    if (roleStr == 'admin') {
      role = UserRole.admin;
    } else if (roleStr == 'teacher') {
      role = UserRole.teacher;
    } else {
      role = UserRole.student;
    }

    return UserModel(
      id: json['id'] as String,
      authUid: json['authUid'] as String?,
      email: json['email'] as String?,
      displayName: json['displayName'] as String? ?? '',
      role: role,
      schoolCode: json['schoolCode'] as String?,
      schoolName: json['schoolName'] as String?,
      grade: json['grade'] as String?,
      classNum: json['classNum'] as String?,
      studentNum: json['studentNum'] as String?,
      studentId: json['studentId'] as String?,
      gender: json['gender'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      isApproved: json['isApproved'] as bool? ?? false,
    );
  }

  /// UserModel 객체를 Firestore 문서로 변환
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
      'authUid': authUid,
      'email': email,
      'displayName': displayName,
      'role': roleStr,
      'schoolCode': schoolCode,
      'schoolName': schoolName,
      'grade': grade,
      'classNum': classNum,
      'studentNum': studentNum,
      'studentId': studentId,
      'gender': gender,
      'phoneNumber': phoneNumber,
      'isApproved': isApproved,
    };
  }

  /// Firebase Auth User와 추가 정보로부터 UserModel 생성
  factory UserModel.fromFirebaseUser(
    String userId,
    String? email, {
    required Map<String, dynamic> userData,
  }) {
    final roleStr = userData['role'] as String? ?? 'student';
    UserRole role;
    
    if (roleStr == 'admin') {
      role = UserRole.admin;
    } else if (roleStr == 'teacher') {
      role = UserRole.teacher;
    } else {
      role = UserRole.student;
    }

    return UserModel(
      id: userId,
      authUid: userData['authUid'] as String?,
      email: email,
      displayName: userData['displayName'] as String? ?? '',
      role: role,
      schoolCode: userData['schoolCode'] as String?,
      schoolName: userData['schoolName'] as String?,
      grade: userData['grade'] as String?,
      classNum: userData['classNum'] as String?,
      studentNum: userData['studentNum'] as String?,
      studentId: userData['studentId'] as String?,
      gender: userData['gender'] as String?,
      phoneNumber: userData['phoneNumber'] as String?,
      isApproved: userData['isApproved'] as bool? ?? false,
    );
  }

  /// 도메인 엔티티에서 UserModel 생성
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      authUid: user.authUid,
      email: user.email,
      displayName: user.displayName,
      role: user.role,
      schoolCode: user.schoolCode,
      schoolName: user.schoolName,
      grade: user.grade,
      classNum: user.classNum,
      studentNum: user.studentNum,
      studentId: user.studentId,
      gender: user.gender,
      phoneNumber: user.phoneNumber,
      isApproved: user.isApproved,
    );
  }
}
