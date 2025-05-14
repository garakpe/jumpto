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
    : _functions =
          functions ?? FirebaseFunctions.instanceFor(region: 'asia-northeast3');

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
        'newPassword': newPassword
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

      final callable = _functions.httpsCallable('createBulkStudentAccounts');
      final result = await callable.call({
        'students': studentsList,
        'schoolCode': schoolCode,
        'schoolName': schoolName,
        'initialPassword': initialPassword,
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

  /// 학생 로그인
  ///
  /// 학생이 학교명과 학번으로 로그인할 때 사용
  Future<Map<String, dynamic>> studentLogin({
    required String schoolName,
    required String studentId,
    required String password,
  }) async {
    try {
      // Firebase SDK의 httpsCallable을 사용하여 함수 호출
      final callable = _functions.httpsCallable('studentLogin');
      final result = await callable.call({
        'schoolName': schoolName,
        'studentId': studentId,
        'password': password,
      });

      debugPrint('학생 로그인 결과: ${result.data}');

      // 결과 데이터 반환
      if (result.data is Map && result.data['success'] != true) {
        throw ServerException(
          message: result.data['message'] ?? '로그인에 실패했습니다'
        );
      }

      return Map<String, dynamic>.from(result.data);
    } on FirebaseFunctionsException catch (e) {
      // Firebase Functions 호출과 관련된 구체적인 오류 처리
      debugPrint(
        'Firebase Functions Exception (studentLogin): ${e.code} - ${e.message}',
      );
      
      String errorMessage = '로그인 중 오류가 발생했습니다';
      if (e.code == 'unavailable') {
        errorMessage = '서버에 연결할 수 없습니다. 잠시 후 다시 시도해주세요.';
      } else if (e.code == 'not-found') {
        errorMessage = '학교 정보를 찾을 수 없습니다. 학교명을 확인해주세요.';
      } else if (e.code == 'permission-denied') {
        errorMessage = '로그인 권한이 없습니다. 계정 정보를 확인해주세요.';
      }
      
      throw ServerException(message: errorMessage);
    } catch (e) {
      debugPrint('학생 로그인 중 오류: $e');
      throw ServerException(message: '알 수 없는 오류로 로그인에 실패했습니다');
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
}
