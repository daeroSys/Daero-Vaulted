import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../domain/entities/content.dart';
import 'auth_provider.dart';

import '../../domain/repositories/search_repository.dart';
import '../../data/repositories/search_repository_impl.dart';

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return SearchRepositoryImpl(db.searchDao);
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final debouncedSearchQueryProvider = FutureProvider<String>((ref) async {
  final query = ref.watch(searchQueryProvider);
  
  var didDispose = false;
  ref.onDispose(() => didDispose = true);
  
  await Future.delayed(const Duration(milliseconds: 300));
  
  if (didDispose) {
    // If the provider is disposed (i.e., the query changed again within 300ms), 
    // we throw an exception to prevent the old query from being processed.
    throw Exception('Cancelled');
  }
  
  return query;
});

final searchResultsProvider = FutureProvider<List<SavedItemView>>((ref) async {
  final debouncedQuery = await ref.watch(debouncedSearchQueryProvider.future);
  if (debouncedQuery.trim().isEmpty) return [];
  
  final userId = await ref.read(authRepositoryProvider).getCurrentUserId();
  if (userId == null) return [];
  
  final repo = ref.read(searchRepositoryProvider);
  // Add an asterisk for prefix matching in FTS5
  final ftsQuery = '${debouncedQuery.trim()}*';
  return repo.search(userId, ftsQuery);
});

final recentSearchesProvider = FutureProvider.autoDispose<List<String>>((ref) async {
  final userId = await ref.read(authRepositoryProvider).getCurrentUserId();
  if (userId == null) return [];
  
  final repo = ref.read(searchRepositoryProvider);
  return repo.getRecentSearches(userId);
});

class SearchNotifier {
  final Ref ref;
  SearchNotifier(this.ref);

  Future<void> executeSearch(String query) async {
    final userId = await ref.read(authRepositoryProvider).getCurrentUserId();
    if (userId == null || query.trim().isEmpty) return;
    
    final repo = ref.read(searchRepositoryProvider);
    await repo.addRecentSearch(userId, query);
    
    ref.invalidate(recentSearchesProvider);
  }
  
  void setQuery(String query) {
    ref.read(searchQueryProvider.notifier).state = query;
  }
}

final searchNotifierProvider = Provider((ref) => SearchNotifier(ref));
