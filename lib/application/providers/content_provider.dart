import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaulted/core/providers.dart';
import 'package:vaulted/data/repositories/content_repository_impl.dart';
import 'package:vaulted/domain/entities/content.dart';
import 'package:vaulted/domain/repositories/content_repository.dart';
import 'package:vaulted/core/services/duplicate_detection_service.dart';

import 'sync_provider.dart';

final contentRepositoryProvider = Provider<ContentRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final syncRepo = ref.watch(syncRepositoryProvider);
  return ContentRepositoryImpl(db.contentDao, syncRepo);
});

final duplicateDetectionServiceProvider = Provider<DuplicateDetectionService>((ref) {
  final repo = ref.watch(contentRepositoryProvider);
  return DuplicateDetectionService(repo);
});

final folderItemsProvider = StreamProvider.family<List<SavedItemView>, String>((ref, folderId) {
  final repo = ref.watch(contentRepositoryProvider);
  return repo.watchItemsInFolder(folderId);
});
