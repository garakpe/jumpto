import 'package:cloud_functions/cloud_functions.dart';

import '../../../core/error/exceptions.dart';

/// Cloud Functions 호출을 위한 서비스 클래스
class CloudFunctionsService {
  final FirebaseFunctions _functions;
  
  CloudFunctionsService({FirebaseFunctions? functions}) 
    : _functions = functions ?? FirebaseFunctions.instance;
  
  /// 학생 비밀번호 초기화
  /// 
  /// [studentId] 학생 ID(학번)
  /// [newPassword] 새 비밀번호
  /// 
  /// 교사 권한이 필요합니다.
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
        throw ServerException(message: result.data['message'] ?? '비밀번호 초기화 실패');
      }
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(message: '비밀번호 초기화 실패: $e');
    }
  }
  
  /// 학생 성별 업데이트
  /// 
  /// [gender] 성별 ('남' 또는 '여')
  /// 
  /// 학생 본인만 호출할 수 있습니다.
  Future<void> updateStudentGender({
    required String gender,
  }) async {
    try {
      final result = await _functions.httpsCallable('updateStudentGender').call({
        'gender': gender,
      });
      
      if (result.data['success'] != true) {
        throw ServerException(message: result.data['message'] ?? '성별 정보 업데이트 실패');
      }
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(message: '성별 정보 업데이트 실패: $e');
    }
  }
}
