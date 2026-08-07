import 'package:vaulted/domain/repositories/content_repository.dart';
import 'package:vaulted/domain/entities/content.dart';

class DuplicateDetectionService {
  final ContentRepository _contentRepository;

  DuplicateDetectionService(this._contentRepository);

  /// Checks if the content is already saved locally based on its canonical URL.
  /// Returns the Content entity if found, otherwise null.
  Future<Content?> findExistingContent(String canonicalUrl) async {
    return await _contentRepository.findContentByCanonicalUrl(canonicalUrl);
  }
}
