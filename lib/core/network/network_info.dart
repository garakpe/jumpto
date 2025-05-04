import 'package:connectivity_plus/connectivity_plus.dart';

/// 네트워크 연결 상태 정보 추상화 인터페이스
abstract class NetworkInfo {
  /// 네트워크 연결 여부 확인
  Future<bool> get isConnected;
}

/// 네트워크 연결 상태 정보 구현체
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  NetworkInfoImpl(this.connectivity);

  @override
  Future<bool> get isConnected async {
    // 현재 연결 상태 확인
    final connectivityResult = await connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }
}