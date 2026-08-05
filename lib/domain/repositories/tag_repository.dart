abstract class TagRepository {
  Future<void> createTag(String name);
  Future<List<dynamic>> getAllTags();
  Future<void> assignTagToContent(String contentId, String tagId);
  Future<void> removeTagFromContent(String contentId, String tagId);
}
