import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _onlineController =
      StreamController<bool>.broadcast();

  ConnectivityService() {
    _init();
  }

  void _init() {
    _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      // Assuming online if any of the results is not 'none'
      final isOnline = results.any(
        (result) => result != ConnectivityResult.none,
      );
      _onlineController.add(isOnline);
    });
  }

  Future<bool> checkIsOnline() async {
    final results = await _connectivity.checkConnectivity();
    return results.any((result) => result != ConnectivityResult.none);
  }

  Stream<bool> get isOnlineStream => _onlineController.stream;

  void dispose() {
    _onlineController.close();
  }
}
