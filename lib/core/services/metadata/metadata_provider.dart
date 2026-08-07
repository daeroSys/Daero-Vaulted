import 'metadata_models.dart';

abstract class MetadataProvider {
  /// Fetches metadata for the given [url].
  /// Throws an exception if the metadata cannot be fetched or parsing fails.
  Future<ExtractedMetadata> getMetadata(String url);
}
