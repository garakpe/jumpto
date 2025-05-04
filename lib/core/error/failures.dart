import 'package:equatable/equatable.dart';

/// 실패 추상 클래스
abstract class Failure extends Equatable {
  @override
  List<Object?> get props => [];
}

/// 서버 관련 실패
class ServerFailure extends Failure {
  final String message;

  ServerFailure({this.message = '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.'});

  @override
  List<Object?> get props => [message];
}

/// 캐시 관련 실패
class CacheFailure extends Failure {
  final String message;

  CacheFailure({this.message = '캐시 오류가 발생했습니다. 잠시 후 다시 시도해주세요.'});

  @override
  List<Object?> get props => [message];
}

/// 네트워크 관련 실패
class NetworkFailure extends Failure {
  final String message;

  NetworkFailure({this.message = '네트워크 연결을 확인해주세요.'});

  @override
  List<Object?> get props => [message];
}

/// 인증 관련 실패
class AuthFailure extends Failure {
  final String message;
  final int? code;

  AuthFailure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

/// 알 수 없는 실패
class UnknownFailure extends Failure {
  final String message;

  UnknownFailure({this.message = '오류가 발생했습니다. 잠시 후 다시 시도해주세요.'});

  @override
  List<Object?> get props => [message];
}