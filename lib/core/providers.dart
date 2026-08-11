import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';
import '../network/dio_client.dart';
import '../services/secure_storage_service.dart';
import '../services/connectivity_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/notification_service.dart';

final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient();
});

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(ref.read(supabaseProvider));
});
