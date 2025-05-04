/// 서버 관련 예외
class ServerException implements Exception {}

/// 캐시 관련 예외
class CacheException implements Exception {}

/// 네트워크 관련 예외
class NetworkException implements Exception {}

/// 인증 관련 예외
class AuthException implements Exception {
  final String message;

  AuthException({required this.message});
}