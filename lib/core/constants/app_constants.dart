/// 앱 전체에서 사용되는 상수들을 정의합니다.
class AppConstants {
  // 앱 기본 정보
  static const String appName = '온라인 PAPS';
  static const String appVersion = '1.0.0';
  
  // Firebase 컬렉션 이름
  static const String usersCollection = 'users';
  static const String studentsCollection = 'students';
  static const String papsStandardsCollection = 'paps_standards';
  static const String teacherSettingsCollection = 'teacher_settings';
  static const String studentPapsRecordsCollection = 'student_paps_records';
  static const String studentReflectionsCollection = 'student_reflections';
  
  // 사용자 역할
  static const String roleStudent = 'student';
  static const String roleTeacher = 'teacher';
  static const String roleAdmin = 'admin';
  
  // 라우트 이름
  static const String routeLogin = '/login';
  static const String routeHome = '/home';
  static const String routePapsStandards = '/paps/standards';
  static const String routePapsRecord = '/paps/record';
  
  // 기타 상수
  static const int maxStudentsPerTeacher = 200; // 교사당 최대 학생 수 (기본값)
}
