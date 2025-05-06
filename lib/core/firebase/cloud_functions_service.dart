import 'package:cloud_functions/cloud_functions.dart';

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
