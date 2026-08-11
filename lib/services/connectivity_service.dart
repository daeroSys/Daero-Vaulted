import 'dart:async';

class ConnectivityService {
  final StreamController<bool> _connectivityController =
      StreamController<bool>.broadcast();

  Stream<bool> get connectivityStream => _connectivityController.stream;

  void dispose() {
    _connectivityController.close();
  }
}
