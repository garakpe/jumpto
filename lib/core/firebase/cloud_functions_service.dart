import 'package:cloud_functions/cloud_functions.dart';
import '../../features/auth/domain/entities/student.dart';

/// Cloud Functions 서비스
///
/// Firebase Cloud Functions를 호출하기 위한 서비스 클래스
class CloudFunctionsService {
  final FirebaseFunctions _functions;
  
  CloudFunctionsService({FirebaseFunctions? functions}) 
    : _functions = functions ?? FirebaseFunctions.instance;
  
  /// 학생 비밀번호 초기화
  ///
  /// 교사가 학생 비밀번호를 초기화할 때 사용
  /// 교사 권한 검증이 Cloud Functions에서 수행됨
  Future<void> resetStudentPassword({
    required String studentId,
    required String newPassword,
  }) async {
    try {
      final result = await _functions.httpsCallable('resetStudentPassword').call({
        'studentId': studentId,
        'newPassword': newPassword,
      });
      
      if (result.data['success'] != true) {
        throw Exception(result.data['message'] ?? '비밀번호 초기화 실패');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// 학생 계정 일괄 생성
  ///
  /// 교사가 학생 명단을 업로드할 때 사용
  /// 여러 학생 계정을 한번에 생성함
  Future<Map<String, dynamic>> createBulkStudentAccounts({
    required List<Student> students,
    required String schoolCode,
    required String schoolName,
    String initialPassword = 'student123',
  }) async {
    try {
      // 학생 데이터를 Map으로 변환
      final studentsList = students.map((student) => {
        'grade': student.grade,
        'classNum': student.classNum,
        'studentNum': student.studentNum,
        'name': student.name,
        'gender': student.gender,
      }).toList();
      
      final result = await _functions.httpsCallable('createBulkStudentAccounts').call({
        'students': studentsList,
        'schoolCode': schoolCode,
        'schoolName': schoolName,
        'initialPassword': initialPassword,
      });
      
      if (result.data['success'] != true) {
        throw Exception(result.data['message'] ?? '학생 계정 일괄 생성 실패');
      }
      
      return result.data;
    } catch (e) {
      rethrow;
    }
  }

  /// 학생 로그인
  ///
  /// 학생이 학교명과 학번으로 로그인할 때 사용
  Future<Map<String, dynamic>> studentLogin({
    required String schoolName,
    required String studentId,
    required String password,
  }) async {
    try {
      final result = await _functions.httpsCallable('studentLogin').call({
        'schoolName': schoolName,
        'studentId': studentId,
        'password': password,
      });
      
      if (result.data['success'] != true) {
        throw Exception(result.data['message'] ?? '로그인 실패');
      }
      
      return result.data;
    } catch (e) {
      rethrow;
    }
  }
    
  /// 학생 성별 업데이트
  ///
  /// 학생이 마이페이지에서 성별을 선택할 때 사용
  /// 학생 권한 검증이 Cloud Functions에서 수행됨
  Future<void> updateStudentGender({
    required String gender,
  }) async {
    try {
      final result = await _functions.httpsCallable('updateStudentGender').call({
        'gender': gender,
      });
      
      if (result.data['success'] != true) {
        throw Exception(result.data['message'] ?? '성별 정보 업데이트 실패');
      }
    } catch (e) {
      rethrow;
    }
  }
}