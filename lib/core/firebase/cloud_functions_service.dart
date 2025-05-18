import 'package:cloud_functions/cloud_functions.dart';
import '../../features/auth/domain/entities/student.dart';
import '../error/exceptions.dart';
import 'package:flutter/foundation.dart';

/// Cloud Functions 서비스
///
/// Firebase Cloud Functions를 호출하기 위한 서비스 클래스
class CloudFunctionsService {
  final FirebaseFunctions _functions;

  CloudFunctionsService({FirebaseFunctions? functions})
    : _functions = functions ?? FirebaseFunctions.instanceFor(region: 'asia-northeast3') {
    debugPrint('Cloud Functions 서비스 초기화 - 리전: asia-northeast3');
  }

  /// 학생 비밀번호 초기화
  ///
  /// 교사가 학생 비밀번호를 초기화할 때 사용
  /// 교사 권한 검증이 Cloud Functions에서 수행됨
  Future<void> resetStudentPassword({
    required String studentId,
    required String newPassword,
  }) async {
    try {
      final callable = _functions.httpsCallable('resetStudentPassword');
      final result = await callable.call({
        'studentId': studentId, 
        'newPassword': newPassword, // 실제 호출에는 원래 비밀번호 사용
      });

      if (result.data['success'] != true) {
        throw ServerException(
          message: result.data['message'] ?? '비밀번호 초기화 실패'
        );
      }
    } on FirebaseFunctionsException catch (e) {
      debugPrint('Firebase Functions Exception (resetStudentPassword): ${e.code} - ${e.message}');
      throw ServerException(
        message: '비밀번호 초기화 실패: ${e.message ?? e.code}'
      );
    } catch (e) {
      debugPrint('학생 비밀번호 초기화 중 오류: $e');
      throw ServerException(message: '비밀번호 초기화 중 오류가 발생했습니다');
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
    String initialPassword = '123456',
  }) async {
    try {
      // 학생 데이터를 Map으로 변환
      final studentsList = students
          .map((student) => {
                'grade': student.grade,
                'classNum': student.classNum,
                'studentNum': student.studentNum,
                'name': student.name,
                'gender': student.gender,
              })
          .toList();

      debugPrint('학생 계정 일괄 생성 - ${students.length}개 계정, 학교: $schoolName');
      // 민감한 초기 비밀번호는 로깅하지 않음

      final callable = _functions.httpsCallable('createBulkStudentAccounts');
      final result = await callable.call({
        'students': studentsList,
        'schoolCode': schoolCode,
        'schoolName': schoolName,
        'initialPassword': initialPassword, // 실제 호출에서는 원래 비밀번호 사용
      });

      if (result.data['success'] != true) {
        throw ServerException(
          message: result.data['message'] ?? '학생 계정 일괄 생성 실패'
        );
      }

      return Map<String, dynamic>.from(result.data);
    } on FirebaseFunctionsException catch (e) {
      debugPrint('Firebase Functions Exception (createBulkStudentAccounts): ${e.code} - ${e.message}');
      throw ServerException(
        message: '학생 계정 생성 실패: ${e.message ?? e.code}'
      );
    } catch (e) {
      debugPrint('학생 계정 일괄 생성 중 오류: $e');
      throw ServerException(message: '학생 계정 생성 중 오류가 발생했습니다');
    }
  }

  /// 학생 로그인 이메일 가져오기
  ///
  /// 학생이 학교명과 학번으로 로그인 이메일을 가져올 때 사용
  /// 리팩토링: 에러 처리 강화 및 성능 최적화
  Future<String> getStudentLoginEmail({
    required String schoolName,
    required String studentId,
  }) async {
    try {
      // 학교명, 학번 트림처리 - 잘못된 공백 방지
      final trimmedSchoolName = schoolName.trim();
      final trimmedStudentId = studentId.trim();
      
      // 디버그 로그
      debugPrint('학생 로그인 이메일 요청 - 학교: $trimmedSchoolName, 학번: $trimmedStudentId');
      
      // 구조화된 데이터로 함수 호출 파라미터 구성
      final params = {
        'schoolName': trimmedSchoolName,
        'studentId': trimmedStudentId,
      };
      
      // 함수 호출 시도
      final callable = _functions.httpsCallable('getStudentLoginEmail');
      final result = await callable.call(params);
      
      // 결과 검증
      if (result.data is! Map || result.data['success'] != true) {
        final errorMsg = (result.data is Map) ? result.data['message'] : '알 수 없는 오류';
        debugPrint('함수 호출 실패: $errorMsg');
        throw ServerException(
          message: errorMsg ?? '로그인 이메일 조회에 실패했습니다'
        );
      }

      final email = result.data['email'] as String;
      debugPrint('학생 로그인 이메일 조회 성공: $email');
      
      return email;
    } on FirebaseFunctionsException catch (e) {
      // Firebase Functions 호출과 관련된 구체적인 오류 처리
      debugPrint(
        'Firebase Functions Exception (getStudentLoginEmail): ${e.code} - ${e.message}',
      );
      
      // 전용 오류 처리 함수로 메시지 변환
      final errorMessage = _getFirebaseFunctionErrorMessage(
        code: e.code,
        defaultMessage: '로그인 이메일 조회 중 오류가 발생했습니다',
        context: '학생 로그인',
      );
      
      throw ServerException(message: errorMessage);
    } catch (e) {
      debugPrint('학생 로그인 이메일 조회 중 예외 발생: $e');
      throw ServerException(message: '알 수 없는 오류로 로그인 이메일 조회에 실패했습니다');
    }
  }

  /// 학생 성별 업데이트
  ///
  /// 학생이 마이페이지에서 성별을 선택할 때 사용
  /// 학생 권한 검증이 Cloud Functions에서 수행됨
  Future<void> updateStudentGender({required String gender}) async {
    try {
      final callable = _functions.httpsCallable('updateStudentGender');
      final result = await callable.call({'gender': gender});

      if (result.data['success'] != true) {
        throw ServerException(
          message: result.data['message'] ?? '성별 정보 업데이트 실패'
        );
      }
    } on FirebaseFunctionsException catch (e) {
      debugPrint('Firebase Functions Exception (updateStudentGender): ${e.code} - ${e.message}');
      throw ServerException(
        message: '성별 정보 업데이트 실패: ${e.message ?? e.code}'
      );
    } catch (e) {
      debugPrint('학생 성별 업데이트 중 오류: $e');
      throw ServerException(message: '성별 정보 업데이트 중 오류가 발생했습니다');
    }
  }
  
  /// 학교 정보 조회 또는 생성
  ///
  /// 학교명으로 학교 정보를 조회하거나, 없으면 새로 생성
  Future<Map<String, dynamic>> getOrCreateSchool({
    required String schoolName,
    required String schoolCode,
  }) async {
    try {
      final callable = _functions.httpsCallable('getOrCreateSchool');
      final result = await callable.call({
        'schoolName': schoolName,
        'schoolCode': schoolCode,
      });

      if (result.data['success'] != true) {
        throw ServerException(
          message: result.data['message'] ?? '학교 정보 조회/생성 실패'
        );
      }

      return Map<String, dynamic>.from(result.data['school']);
    } on FirebaseFunctionsException catch (e) {
      debugPrint('Firebase Functions Exception (getOrCreateSchool): ${e.code} - ${e.message}');
      throw ServerException(
        message: '학교 정보 처리 실패: ${e.message ?? e.code}'
      );
    } catch (e) {
      debugPrint('학교 정보 처리 중 오류: $e');
      throw ServerException(message: '학교 정보 처리 중 오류가 발생했습니다');
    }
  }
  
  /// Firebase Functions 예외 코드에 따른 사용자 친화적 오류 메시지 생성
  /// 
  /// 중복되는 오류 처리 로직을 통합하여 리펙토링
  String _getFirebaseFunctionErrorMessage({
    required String code,
    required String defaultMessage,
    String context = '',
  }) {
    final contextPrefix = context.isNotEmpty ? '$context: ' : '';
    
    switch (code) {
      case 'unavailable':
        return '$contextPrefix서버에 연결할 수 없습니다. 잠시 후 다시 시도해주세요.';
      case 'not-found':
        return '$contextPrefix학교 정보를 찾을 수 없습니다. 학교명을 확인해주세요.';
      case 'permission-denied':
        return '$contextPrefix권한이 부족합니다. 계정 정보를 확인해주세요.';
      case 'invalid-argument':
        return '$contextPrefix입력한 정보가 올바르지 않습니다. 다시 확인해주세요.';
      case 'unauthenticated':
        return '$contextPrefix인증이 필요합니다. 로그인 후 다시 시도해주세요.';
      case 'user-not-found':
        return '$contextPrefix해당 학번으로 등록된 계정을 찾을 수 없습니다.';
      case 'wrong-password':
        return '$contextPrefix비밀번호가 일치하지 않습니다.';
      case 'deadline-exceeded':
        return '$contextPrefix요청 시간이 초과되었습니다. 잠시 후 다시 시도해주세요.';
      case 'cancelled':
        return '$contextPrefix요청이 취소되었습니다.';
      case 'internal':
        return '$contextPrefix서버 내부 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
      default:
        return defaultMessage;
    }
  }
}