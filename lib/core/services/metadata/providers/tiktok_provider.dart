import 'package:dio/dio.dart';
import '../metadata_models.dart';
import '../metadata_provider.dart';

class TikTokProvider implements MetadataProvider {
  final Dio _dio;

  TikTokProvider(this._dio);

  @override
  Future<ExtractedMetadata> getMetadata(String url) async {
    try {
      final response = await _dio.get(
        'https://www.tiktok.com/oembed',
        queryParameters: {
          'url': url,
        },
      );

      final data = response.data;
      return ExtractedMetadata(
        title: data['title'] as String? ?? 'TikTok Video',
        creator: data['author_name'] as String?,
        thumbnailUrl: data['thumbnail_url'] as String?,
      );
    } catch (e) {
      throw Exception('Failed to fetch TikTok metadata: $e');
    }
  }
}
