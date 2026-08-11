import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Implements Supabase's [LocalStorage] to securely persist the session token.
class SecureLocalStorage extends LocalStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // The key used by default in supabase_flutter
  final String _storageKey = 'supabase.auth.token';

  @override
  Future<void> initialize() async {
    // Initialization is optional for flutter_secure_storage
  }

  @override
  Future<bool> hasAccessToken() async {
    final session = await _storage.read(key: _storageKey);
    return session != null;
  }

  @override
  Future<String?> accessToken() async {
    return await _storage.read(key: _storageKey);
  }

  @override
  Future<void> persistSession(String persistSessionString) async {
    await _storage.write(key: _storageKey, value: persistSessionString);
  }

  @override
  Future<void> removePersistedSession() async {
    await _storage.delete(key: _storageKey);
  }
}
