import 'package:dio/dio.dart';
import 'package:html/parser.dart' show parse;
import '../metadata_models.dart';
import '../metadata_provider.dart';

class GenericUrlProvider implements MetadataProvider {
  final Dio _dio;

  GenericUrlProvider(this._dio);

  @override
  Future<ExtractedMetadata> getMetadata(String url) async {
    try {
      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            // Emulate a standard browser to avoid basic blocks
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          },
        ),
      );

      final document = parse(response.data);

      String? title;
      String? description;
      String? thumbnailUrl;

      // Check OpenGraph tags
      final ogTitle = document
          .querySelector('meta[property="og:title"]')
          ?.attributes['content'];
      final ogDesc = document
          .querySelector('meta[property="og:description"]')
          ?.attributes['content'];
      final ogImage = document
          .querySelector('meta[property="og:image"]')
          ?.attributes['content'];

      // Check Twitter tags
      final twTitle = document
          .querySelector('meta[name="twitter:title"]')
          ?.attributes['content'];
      final twDesc = document
          .querySelector('meta[name="twitter:description"]')
          ?.attributes['content'];
      final twImage = document
          .querySelector('meta[name="twitter:image"]')
          ?.attributes['content'];

      // Check standard tags
      final stdTitle = document.querySelector('title')?.text;
      final stdDesc = document
          .querySelector('meta[name="description"]')
          ?.attributes['content'];

      title = ogTitle ?? twTitle ?? stdTitle ?? 'Saved Link';
      description = ogDesc ?? twDesc ?? stdDesc;
      thumbnailUrl = ogImage ?? twImage;

      // Normalize thumbnail URL if it's relative
      if (thumbnailUrl != null && thumbnailUrl.startsWith('/')) {
        final uri = Uri.parse(url);
        thumbnailUrl = '${uri.scheme}://${uri.host}$thumbnailUrl';
      }

      return ExtractedMetadata(
        title: title,
        description: description,
        thumbnailUrl: thumbnailUrl,
      );
    } catch (e) {
      // Graceful fallback if scraping fails entirely (e.g. 403 Forbidden)
      final uri = Uri.tryParse(url);
      return ExtractedMetadata(
        title: uri?.host ?? 'Saved Link',
        description: null,
        thumbnailUrl: null,
      );
    }
  }
}
