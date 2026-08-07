import 'package:dio/dio.dart';
import '../metadata_models.dart';
import '../metadata_provider.dart';

class YouTubeProvider implements MetadataProvider {
  final Dio _dio;

  YouTubeProvider(this._dio);

  @override
  Future<ExtractedMetadata> getMetadata(String url) async {
    try {
      final response = await _dio.get(
        'https://www.youtube.com/oembed',
        queryParameters: {
          'url': url,
          'format': 'json',
        },
      );

      final data = response.data;
      return ExtractedMetadata(
        title: data['title'] as String? ?? 'YouTube Video',
        creator: data['author_name'] as String?,
        thumbnailUrl: data['thumbnail_url'] as String?,
      );
    } catch (e) {
      throw Exception('Failed to fetch YouTube metadata: $e');
    }
  }
}
