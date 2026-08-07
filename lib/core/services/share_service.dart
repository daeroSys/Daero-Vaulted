import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:vaulted/core/services/share_parser.dart';

final shareServiceProvider = Provider<ShareService>((ref) {
  final service = ShareService();
  service.initialize();
  ref.onDispose(() => service.dispose());
  return service;
});

final shareIntentStreamProvider = StreamProvider<ParsedShare>((ref) {
  final service = ref.watch(shareServiceProvider);
  return service.intentStream;
});

class ShareService {
  final ShareParserOrchestrator _parser = ShareParserOrchestrator();
  final _intentController = StreamController<ParsedShare>.broadcast();
  
  StreamSubscription? _intentDataStreamSubscription;

  /// Stream of parsed share intents to be listened to by the UI
  Stream<ParsedShare> get intentStream => _intentController.stream;

  void initialize() {
    // For sharing images coming from outside the app while the app is in the memory
    _intentDataStreamSubscription = ReceiveSharingIntent.instance.getMediaStream().listen((List<SharedMediaFile> value) {
      _processMediaFiles(value);
    }, onError: (err) {
      debugPrint('getMediaStream error: $err');
    });

    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.instance.getInitialMedia().then((List<SharedMediaFile> value) {
      _processMediaFiles(value);
    }).catchError((err) {
      debugPrint('getInitialMedia error: $err');
    });
  }

  void _processMediaFiles(List<SharedMediaFile> files) {
    if (files.isEmpty) return;
    
    // We only process the first item for now, assuming text/URL
    final file = files.first;
    
    // If it's a path or text (URL usually comes as path or thumbnail)
    // The library usually maps text intents to the 'path' field for text/plain
    final text = file.path;
    if (text.isNotEmpty) {
      final parsed = _parser.processText(text);
      _intentController.add(parsed);
    }
    
    // Clear the intent so it doesn't fire again on cold starts
    ReceiveSharingIntent.instance.reset();
  }

  void dispose() {
    _intentDataStreamSubscription?.cancel();
    _intentController.close();
  }
}
