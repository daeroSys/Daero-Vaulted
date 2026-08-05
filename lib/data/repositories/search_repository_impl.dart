import '../../domain/repositories/search_repository.dart';
import '../../database/daos/search_dao.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchDao _searchDao;

  SearchRepositoryImpl(this._searchDao);

  @override
  Future<List<dynamic>> search(String query) async {
    return await _searchDao.search(query);
  }

  @override
  Future<void> indexContent(String contentId, String title, String description, String creator, String notes, List<String> tags) async {
    await _searchDao.updateSearchIndex(
      contentId: contentId,
      title: title,
      description: description,
      creator: creator,
      notes: notes,
      tags: tags.join(' '),
    );
  }
}
