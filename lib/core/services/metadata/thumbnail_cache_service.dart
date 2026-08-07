import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:path/path.dart' as p;

class ThumbnailCacheService {
  final Dio _dio;

  ThumbnailCacheService(this._dio);

  /// Downloads and caches a thumbnail from the given [url].
  /// Returns the absolute path to the local cached file, or null if it failed.
  Future<String?> cacheThumbnail(String url) async {
    try {
      final cacheDir = await getApplicationDocumentsDirectory();
      final thumbnailsDir = Directory(p.join(cacheDir.path, 'thumbnails'));
      
      if (!await thumbnailsDir.exists()) {
        await thumbnailsDir.create(recursive: true);
      }

      // Generate a safe, unique filename based on the URL
      final hash = md5.convert(utf8.encode(url)).toString();
      // Try to get extension from URL or default to jpg
      String ext = '.jpg';
      final uri = Uri.tryParse(url);
      if (uri != null && uri.pathSegments.isNotEmpty) {
        final lastSegment = uri.pathSegments.last;
        if (lastSegment.contains('.')) {
          final extractedExt = p.extension(lastSegment);
          if (['.jpg', '.jpeg', '.png', '.webp'].contains(extractedExt.toLowerCase())) {
            ext = extractedExt;
          }
        }
      }

      final fileName = '$hash$ext';
      final filePath = p.join(thumbnailsDir.path, fileName);
      final file = File(filePath);

      // If file already exists, return its path (cache hit)
      if (await file.exists()) {
        return filePath;
      }

      // Download the file
      debugPrint('Downloading thumbnail to $filePath');
      await _dio.download(
        url,
        filePath,
        options: Options(
          headers: {
            'User-Agent': 'VaultedApp/1.0',
          },
        ),
      );
      debugPrint('Thumbnail download complete.');

      return filePath;
    } catch (e) {
      // In a production app, we would log this to Crashlytics
      debugPrint('Thumbnail cache error: $e');
      return null;
    }
  }
}
