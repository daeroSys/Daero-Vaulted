import 'package:dio/dio.dart';
import '../metadata_models.dart';
import '../metadata_provider.dart';

class MicrolinkProvider implements MetadataProvider {
  final Dio _dio;

  MicrolinkProvider(this._dio);

  @override
  Future<ExtractedMetadata> getMetadata(String url) async {
    try {
      final response = await _dio.get(
        'https://api.microlink.io/',
        queryParameters: {'url': url},
      );

      final data = response.data['data'] as Map<String, dynamic>?;

      if (data == null) {
        throw Exception('Microlink returned empty data');
      }

      final title = data['title'] as String?;
      final description = data['description'] as String?;
      final creator = data['publisher'] as String?;

      String? thumbnailUrl;
      if (data['image'] != null) {
        thumbnailUrl = data['image']['url'] as String?;
      } else if (data['logo'] != null) {
        thumbnailUrl = data['logo']['url'] as String?;
      }

      return ExtractedMetadata(
        title: title ?? 'Shared Link',
        description: description,
        thumbnailUrl: thumbnailUrl,
        creator: creator,
      );
    } catch (e) {
      throw Exception('Failed to fetch Microlink metadata: $e');
    }
  }
}
