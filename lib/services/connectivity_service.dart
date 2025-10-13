import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectivityController =
      StreamController<bool>.broadcast();

  ConnectivityService() {
    _initConnectivity();
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      _connectivityController.add(result != ConnectivityResult.none);
    });
  }

  Stream<bool> get connectivityStream => _connectivityController.stream;

  Future<bool> isConnected() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<void> _initConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _connectivityController.add(result != ConnectivityResult.none);
  }

  void dispose() {
    _connectivityController.close();
  }
}
