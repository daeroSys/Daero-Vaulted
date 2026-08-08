import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vaulted/core/providers.dart';
import '../../core/services/sync_service.dart';
import '../../core/services/connectivity_service.dart';
import '../../database/daos/sync_dao.dart';
import '../../data/repositories/sync_repository_impl.dart';

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  ref.onDispose(() => service.dispose());
  return service;
});

final syncDaoProvider = Provider<SyncDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.syncDao;
});

final syncRepositoryProvider = Provider<SyncRepositoryImpl>((ref) {
  return SyncRepositoryImpl(ref.watch(syncDaoProvider));
});

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    syncRepository: ref.watch(syncRepositoryProvider),
    connectivityService: ref.watch(connectivityServiceProvider),
    supabaseClient: Supabase.instance.client,
    db: ref.watch(appDatabaseProvider),
  );
});

final syncNotifierProvider = AsyncNotifierProvider<SyncNotifier, void>(() {
  return SyncNotifier();
});

class SyncNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // We don't necessarily need to return anything, just initializing state
    return;
  }

  Future<void> forceSync() async {
    state = const AsyncValue.loading();
    try {
      final syncService = ref.read(syncServiceProvider);
      await syncService.processQueue();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
