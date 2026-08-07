import 'package:dio/dio.dart';
import '../metadata_models.dart';
import '../metadata_provider.dart';
import 'generic_url_provider.dart';

class InstagramProvider implements MetadataProvider {
  final GenericUrlProvider _genericUrlProvider;

  InstagramProvider(Dio dio) : _genericUrlProvider = GenericUrlProvider(dio);

  @override
  Future<ExtractedMetadata> getMetadata(String url) async {
    try {
      final metadata = await _genericUrlProvider.getMetadata(url);
      return ExtractedMetadata(
        title: metadata.title.isNotEmpty ? metadata.title : 'Instagram Post',
        description: metadata.description,
        thumbnailUrl: metadata.thumbnailUrl,
        creator: metadata.creator,
      );
    } catch (e) {
      throw Exception('Failed to fetch Instagram metadata: $e');
    }
  }
}
