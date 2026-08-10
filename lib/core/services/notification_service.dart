import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/logger.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final SupabaseClient _supabaseClient;
  
  // Stream controller for deep linking payloads
  final _payloadStreamController = StreamController<String>.broadcast();
  Stream<String> get onNotificationPayload => _payloadStreamController.stream;

  NotificationService({required SupabaseClient supabaseClient}) 
    : _supabaseClient = supabaseClient;

  Future<void> init() async {
    // Request permission
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    AppLogger.i('Notification permissions: ${settings.authorizationStatus}');

    // Initialize local notifications
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
    
    await _localNotificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {
        if (response.payload != null) {
          _payloadStreamController.add(response.payload!);
        }
      },
    );

    // Ensure the channel exists for Android (Firebase might create it, but good to be explicit)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important notifications.', // description
      importance: Importance.max,
    );

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Sync FCM Token
    await _syncFcmToken();

    // Update token if it changes
    _firebaseMessaging.onTokenRefresh.listen((token) {
       _syncFcmTokenWith(token);
    });

    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      AppLogger.i('Received foreground message: ${message.messageId}');
      _showLocalNotification(message);
    });

    // Handle tapping on notification when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      AppLogger.i('Message opened app: ${message.messageId}');
      _handleDeepLink(message.data);
    });
    
    // Handle tapping on notification when app is terminated
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      // Need a slight delay to allow router to initialize in some cases, 
      // but usually the listener will catch it when set up early.
      Future.delayed(const Duration(milliseconds: 500), () {
        _handleDeepLink(initialMessage.data);
      });
    }
  }

  Future<void> _syncFcmToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        AppLogger.i('FCM Token: $token');
        await _syncFcmTokenWith(token);
      }
    } catch (e) {
      AppLogger.e('Failed to get FCM token: $e');
    }
  }

  Future<void> _syncFcmTokenWith(String token) async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) return;

      AppLogger.d('Syncing FCM Token: $token');

      // Sync to user_fcm_tokens table
      await _supabaseClient.from('user_fcm_tokens').upsert({
        'user_id': user.id,
        'token': token,
      }, onConflict: 'token');
      
    } catch (e) {
      AppLogger.e('Failed to sync FCM token: $e');
    }
  }

  void _handleDeepLink(Map<String, dynamic> data) {
    if (data.containsKey('route')) {
      _payloadStreamController.add(data['route'] as String);
    } else if (data.containsKey('folderId')) {
      _payloadStreamController.add('/folders/${data['folderId']}');
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null && android != null) {
      await _localNotificationsPlugin.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription: 'This channel is used for important notifications.',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        payload: message.data['route'] ?? message.data['folderId'],
      );
    }
  }

  // Method for Sync/Reminder notifications directly from the app
  Future<void> showLocalAlert({required int id, required String title, required String body, String? payload}) async {
    await _localNotificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'local_alerts_channel', 
          'Local Alerts', 
          channelDescription: 'Channel for local reminders and sync alerts.',
          importance: Importance.defaultImportance,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: payload,
    );
  }
}
