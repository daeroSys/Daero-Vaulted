import 'package:flutter/material.dart';
import 'logger.dart';

class AppLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        AppLogger.i('App resumed');
        break;
      case AppLifecycleState.inactive:
        AppLogger.i('App inactive');
        break;
      case AppLifecycleState.paused:
        AppLogger.i('App paused');
        break;
      case AppLifecycleState.detached:
        AppLogger.i('App detached');
        break;
      case AppLifecycleState.hidden:
        AppLogger.i('App hidden');
        break;
    }
  }
}
