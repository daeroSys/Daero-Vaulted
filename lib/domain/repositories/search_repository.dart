import '../entities/content.dart';

abstract class SearchRepository {
  Future<List<SavedItemView>> search(String userId, String query);
  Future<void> indexContent(
    String contentId,
    String title,
    String description,
    String creator,
    String notes,
    List<String> tags,
  );
  Future<List<String>> getRecentSearches(String userId);
  Future<void> addRecentSearch(String userId, String query);
}
