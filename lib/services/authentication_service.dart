import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vaulted/domain/repositories/authentication_repository.dart';
import 'package:vaulted/domain/repositories/user_repository.dart';
import 'package:vaulted/core/utils/logger.dart';

import 'package:vaulted/database/app_database.dart';
import 'package:vaulted/core/services/sync_service.dart';

class AuthenticationService {
  final AuthenticationRepository _authRepository;
  final UserRepository _userRepository;
  final AppDatabase _db;
  final SyncService _syncService;

  AuthenticationService(
    this._authRepository,
    this._userRepository,
    this._db,
    this._syncService,
  );

  /// Synchronizes the currently logged-in Supabase user with the local SQLite Users table.
  Future<void> _syncProfileToLocalDb() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        final email = user.email ?? '';
        final displayName = user.userMetadata?['full_name'] as String?;
        final photoUrl = user.userMetadata?['avatar_url'] as String?;

        await _userRepository.createUser(user.id, email, displayName, photoUrl);
        AppLogger.i('Profile synced successfully for user: ${user.id}');

        // Sync down all folders and content for this user
        await _syncService.syncDown(user.id);
      } catch (e) {
        AppLogger.e('Failed to sync profile to local DB: $e');
        // Do not throw, as auth succeeded but local sync failed
      }
    }
  }

  Future<void> signInWithGoogle() async {
    await _authRepository.signInWithGoogle();
    await _syncProfileToLocalDb();
  }

  Future<void> signInWithEmail(String email, String password) async {
    await _authRepository.signInWithEmail(email, password);
    await _syncProfileToLocalDb();
  }

  Future<void> signUpWithEmail(String email, String password) async {
    await _authRepository.signUpWithEmail(email, password);
    // Supabase sign-up might automatically sign them in, so we sync just in case
    await _syncProfileToLocalDb();
  }

  Future<void> signInWithApple() async {
    await _authRepository.signInWithApple();
    await _syncProfileToLocalDb();
  }

  Future<void> signOut() async {
    await _db.clearAllData();
    await _authRepository.signOut();
  }
}
