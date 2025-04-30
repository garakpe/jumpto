import 'package:equatable/equatable.dart';

/// 앱에서 발생할 수 있는 실패 상황을 나타내는 기본 클래스
abstract class Failure extends Equatable {
  final String message;
  
  const Failure({required this.message});
  
  @override
  List<Object> get props => [message];
}

/// 서버 관련 실패 (Firebase 등)
class ServerFailure extends Failure {
  const ServerFailure({required String message}) : super(message: message);
}

/// 캐시 관련 실패 (로컬 데이터베이스 등)
class CacheFailure extends Failure {
  const CacheFailure({required String message}) : super(message: message);
}

/// 인증 관련 실패
class AuthFailure extends Failure {
  const AuthFailure({required String message}) : super(message: message);
}

/// 네트워크 관련 실패
class NetworkFailure extends Failure {
  const NetworkFailure({required String message}) : super(message: message);
}

/// 입력값 검증 실패
class ValidationFailure extends Failure {
  const ValidationFailure({required String message}) : super(message: message);
}

/// 권한 관련 실패
class PermissionFailure extends Failure {
  const PermissionFailure({required String message}) : super(message: message);
}
