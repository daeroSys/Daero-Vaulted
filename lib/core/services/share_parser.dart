import 'package:vaulted/domain/entities/enums.dart';

class ParsedShare {
  final String url;
  final String canonicalUrl;
  final Platform platform;
  final ContentType type;

  ParsedShare({
    required this.url,
    required this.canonicalUrl,
    required this.platform,
    required this.type,
  });
}

abstract class ShareParserInterface {
  /// Returns true if this parser can handle the given URL.
  bool canParse(String url);

  /// Parses the URL and normalizes it to a canonical representation.
  ParsedShare parse(String url);
}

class YouTubeParser implements ShareParserInterface {
  @override
  bool canParse(String url) {
    return url.contains('youtube.com') || url.contains('youtu.be');
  }

  @override
  ParsedShare parse(String url) {
    // Strip query parameters for canonical url, except 'v' for youtube.com
    final uri = Uri.parse(url);
    String canonicalUrl = url;

    if (uri.host.contains('youtu.be')) {
      final videoId = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
      canonicalUrl = 'https://www.youtube.com/watch?v=$videoId';
    } else if (uri.host.contains('youtube.com')) {
      final videoId = uri.queryParameters['v'] ?? '';
      canonicalUrl = 'https://www.youtube.com/watch?v=$videoId';
    }

    return ParsedShare(
      url: url,
      canonicalUrl: canonicalUrl,
      platform: Platform.youtube,
      type: ContentType.video, // Can be refined later (e.g. SHORT_VIDEO)
    );
  }
}

class GenericUrlParser implements ShareParserInterface {
  @override
  bool canParse(String url) {
    return true; // Fallback parser
  }

  @override
  ParsedShare parse(String url) {
    // Strip all query parameters for the canonical URL
    final uri = Uri.parse(url);
    final canonicalUrl = uri.replace(query: '').toString();

    // Naive platform detection
    Platform platform = Platform.unknown;
    if (uri.host.contains('instagram.com')) platform = Platform.instagram;
    if (uri.host.contains('tiktok.com')) platform = Platform.tiktok;
    if (uri.host.contains('facebook.com')) platform = Platform.facebook;

    return ParsedShare(
      url: url,
      canonicalUrl: canonicalUrl,
      platform: platform,
      type: ContentType.link,
    );
  }
}

/// Orchestrates parsing by finding the first matching parser.
class ShareParserOrchestrator {
  final List<ShareParserInterface> _parsers = [
    YouTubeParser(),
    GenericUrlParser(), // Must be last as a fallback
  ];

  ParsedShare processText(String text) {
    // Extract first URL from text
    final urlRegex = RegExp(r'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)');
    final match = urlRegex.firstMatch(text);
    
    final url = match != null ? match.group(0)! : text;

    for (final parser in _parsers) {
      if (parser.canParse(url)) {
        return parser.parse(url);
      }
    }
    
    // Fallback
    return _parsers.last.parse(url);
  }
}
