import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_functions/cloud_functions.dart';
import '../../features/auth/domain/entities/student.dart';

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
      final result = await _functions
          .httpsCallable('resetStudentPassword')
          .call({'studentId': studentId, 'newPassword': newPassword});

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
    String initialPassword = '123456',
  }) async {
    try {
      // 학생 데이터를 Map으로 변환
      final studentsList =
          students
              .map(
                (student) => {
                  'grade': student.grade,
                  'classNum': student.classNum,
                  'studentNum': student.studentNum,
                  'name': student.name,
                  'gender': student.gender,
                },
              )
              .toList();

      final result = await _functions
          .httpsCallable('createBulkStudentAccounts')
          .call({
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
      // Firebase SDK의 httpsCallable을 사용하여 함수 호출
      final result = await _functions.httpsCallable('studentLogin').call({
        'schoolName': schoolName,
        'studentId': studentId,
        'password': password,
      });

      // 결과 데이터 반환
      // Cloud Function의 응답 형식에 따라 'success' 키와 'message' 키를 확인합니다.
      // 실제 Cloud Function의 응답 구조에 맞게 이 부분을 조정해야 할 수 있습니다.
      if (result.data is Map && result.data['success'] != true) {
        throw Exception(result.data['message'] ?? '로그인에 실패했습니다.');
      }

      // HttpsCallableResult의 data는 dynamic이므로, Map으로 형변환하여 반환합니다.
      // Cloud Function이 Map<String, dynamic> 형태의 데이터를 반환한다고 가정합니다.
      return Map<String, dynamic>.from(result.data);
    } on FirebaseFunctionsException catch (e) {
      // Firebase Functions 호출과 관련된 구체적인 오류 처리
      print(
        'Firebase Functions Exception (studentLogin): ${e.code} - ${e.message}',
      );
      // 사용자에게 보여줄 메시지를 여기서 결정할 수 있습니다.
      // 예를 들어 e.code에 따라 다른 메시지를 표시할 수 있습니다.
      String userMessage = '로그인 중 오류가 발생했습니다. (코드: ${e.code})';
      if (e.code == 'unavailable') {
        userMessage = '서버에 연결할 수 없습니다. 잠시 후 다시 시도해주세요.';
      } else if (e.code == 'not-found') {
        userMessage = '로그인 기능을 찾을 수 없습니다.';
      }
      // 필요하다면 e.details를 통해 추가 정보를 확인할 수도 있습니다.
      throw Exception(userMessage);
    } catch (e) {
      // 그 외 일반적인 오류 처리
      print('Unknown error during student login: $e');
      throw Exception('알 수 없는 오류로 로그인에 실패했습니다.');
    }
  }

  /// 학생 성별 업데이트
  ///
  /// 학생이 마이페이지에서 성별을 선택할 때 사용
  /// 학생 권한 검증이 Cloud Functions에서 수행됨
  Future<void> updateStudentGender({required String gender}) async {
    try {
      final result = await _functions.httpsCallable('updateStudentGender').call(
        {'gender': gender},
      );

      if (result.data['success'] != true) {
        throw Exception(result.data['message'] ?? '성별 정보 업데이트 실패');
      }
    } catch (e) {
      rethrow;
    }
  }
}
