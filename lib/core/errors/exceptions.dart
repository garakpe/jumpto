/// 서버 관련 예외 (Firebase 등)
class ServerException implements Exception {
  final String message;
  
  ServerException({required this.message});
}

/// 캐시 관련 예외 (로컬 데이터베이스 등)
class CacheException implements Exception {
  final String message;
  
  CacheException({required this.message});
}

/// 인증 관련 예외
class AuthException implements Exception {
  final String message;
  
  AuthException({required this.message});
}

/// 네트워크 관련 예외
class NetworkException implements Exception {
  final String message;
  
  NetworkException({required this.message});
}

/// 입력값 검증 예외
class ValidationException implements Exception {
  final String message;
  
  ValidationException({required this.message});
}

/// 권한 관련 예외
class PermissionException implements Exception {
  final String message;
  
  PermissionException({required this.message});
}
