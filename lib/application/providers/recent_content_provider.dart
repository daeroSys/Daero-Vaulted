import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaulted/domain/entities/content.dart';
import 'package:vaulted/application/providers/content_provider.dart';

final recentContentProvider = StreamProvider.autoDispose<List<SavedItemView>>((
  ref,
) {
  final contentRepo = ref.watch(contentRepositoryProvider);
  return contentRepo.watchRecentItems(limit: 5);
});
