import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class INetworkInfo {
  Future<bool> get isConnected;
}

// Provider
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfo(connectivity: Connectivity());
});

class NetworkInfo implements INetworkInfo {
  final Connectivity _connectivity;

  NetworkInfo({required Connectivity connectivity})
      : _connectivity = connectivity;

  @override
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity(); // wifi / mobiledata

    // ✅ Check if there is NO connection
    if (result == ConnectivityResult.none) {
      return false;
    }

    // Check actual internet access
    return await isInternetAvailable();
  }

  Future<bool> isInternetAvailable() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    }
  }
}
