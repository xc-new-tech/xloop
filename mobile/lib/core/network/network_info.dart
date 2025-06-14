import 'package:connectivity_plus/connectivity_plus.dart';

/// 网络信息抽象类
abstract class NetworkInfo {
  /// 检查是否有网络连接
  Future<bool> get isConnected;
  
  /// 获取当前连接类型
  Future<List<ConnectivityResult>> get connectionType;
  
  /// 监听网络连接状态变化
  Stream<List<ConnectivityResult>> get onConnectivityChanged;
}

/// 网络信息实现类
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity;

  NetworkInfoImpl({
    required Connectivity connectivity,
  }) : _connectivity = connectivity;

  @override
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return _isConnectedResults(results);
  }

  @override
  Future<List<ConnectivityResult>> get connectionType async {
    return await _connectivity.checkConnectivity();
  }

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged;
  }

  /// 判断连接结果是否为已连接状态
  bool _isConnectedResults(List<ConnectivityResult> results) {
    return results.any((result) => _isConnectedResult(result));
  }

  /// 判断单个连接结果是否为已连接状态
  bool _isConnectedResult(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
      case ConnectivityResult.ethernet:
        return true;
      case ConnectivityResult.none:
      case ConnectivityResult.bluetooth:
      case ConnectivityResult.vpn:
      case ConnectivityResult.other:
        return false;
    }
  }

  /// 获取连接类型的友好显示名称
  String getConnectionTypeName(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return '移动网络';
      case ConnectivityResult.ethernet:
        return '以太网';
      case ConnectivityResult.bluetooth:
        return '蓝牙';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.none:
        return '无网络';
      case ConnectivityResult.other:
        return '其他';
    }
  }

  /// 检查是否为WiFi连接
  Future<bool> get isWifiConnected async {
    final results = await _connectivity.checkConnectivity();
    return results.contains(ConnectivityResult.wifi);
  }

  /// 检查是否为移动网络连接
  Future<bool> get isMobileConnected async {
    final results = await _connectivity.checkConnectivity();
    return results.contains(ConnectivityResult.mobile);
  }

  /// 检查是否为以太网连接
  Future<bool> get isEthernetConnected async {
    final results = await _connectivity.checkConnectivity();
    return results.contains(ConnectivityResult.ethernet);
  }
} 