import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vaulted/core/providers.dart';
import 'package:vaulted/database/app_database.dart';
import 'package:vaulted/application/providers/auth_provider.dart';
import 'package:vaulted/core/utils/logger.dart';

final dataManagementServiceProvider = Provider<DataManagementService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final authRepo = ref.watch(authRepositoryProvider);
  return DataManagementService(db, authRepo);
});

class DataManagementService {
  final AppDatabase _db;
  final dynamic _authRepository; // Will cast or use interface

  DataManagementService(this._db, this._authRepository);

  Future<void> exportDatabase() async {
    try {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'db.sqlite'));
      if (await file.exists()) {
        final xFile = XFile(file.path, mimeType: 'application/x-sqlite3');
        // ignore: deprecated_member_use
        await Share.shareXFiles([xFile], subject: 'Vaulted Database Backup');
      } else {
        throw Exception('Database file not found');
      }
    } catch (e) {
      AppLogger.e('Failed to export database: $e');
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    try {
      final userId = await _authRepository.getCurrentUserId();
      if (userId != null) {
        // Soft delete user in public.users on Supabase directly
        try {
          await Supabase.instance.client
              .from('users')
              .update({'deleted_at': DateTime.now().toUtc().toIso8601String()})
              .eq('id', userId);
        } catch (e) {
          AppLogger.e('Failed to soft-delete user on Supabase: $e');
          // Proceed with local deletion anyway
        }
      }
      
      // Wipe all local tables using drift's delete API
      await _db.customStatement('PRAGMA foreign_keys = OFF');
      
      await _db.delete(_db.savedItems).go();
      await _db.delete(_db.contentTags).go();
      await _db.delete(_db.tags).go();
      await _db.delete(_db.contentMetadata).go();
      await _db.delete(_db.content).go();
      await _db.delete(_db.folders).go();
      await _db.delete(_db.syncQueue).go();
      await _db.delete(_db.users).go();
      
      await _db.customStatement('PRAGMA foreign_keys = ON');
      
      // Log out
      await _authRepository.signOut();
    } catch (e) {
      AppLogger.e('Failed to delete account: $e');
      rethrow;
    }
  }
}
