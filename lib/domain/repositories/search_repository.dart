abstract class SearchRepository {
  Future<List<dynamic>> search(String query);
  Future<void> indexContent(String contentId, String title, String description, String creator, String notes, List<String> tags);
}
