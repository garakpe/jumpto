import 'package:equatable/equatable.dart';

/// 기본 실패 클래스
abstract class Failure extends Equatable {
  final String message;
  final int? code;
  
  const Failure({required this.message, this.code});
  
  @override
  List<Object?> get props => [message, code];
  
  @override
  String toString() => '${runtimeType}: $message (코드: $code)';
}

/// 서버 관련 실패
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.code});
}

/// 캐시 관련 실패
class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.code});
}

/// 네트워크 관련 실패
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.code});
}

/// 인증 관련 실패
class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.code});
}

/// 권한 관련 실패
class PermissionFailure extends Failure {
  const PermissionFailure({required super.message, super.code});
}

/// 입력값 검증 실패
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.code});
}

/// 데이터 형식 관련 실패
class FormatFailure extends Failure {
  const FormatFailure({required super.message, super.code});
}

/// 알 수 없는 실패
class UnknownFailure extends Failure {
  const UnknownFailure({required super.message, super.code});
}
