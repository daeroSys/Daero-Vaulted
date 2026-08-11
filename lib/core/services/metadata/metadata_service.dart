// ignore_for_file: prefer_initializing_formals
import 'package:flutter/foundation.dart';
import 'package:vaulted/core/services/metadata/metadata_provider.dart';
import 'package:vaulted/core/services/metadata/thumbnail_cache_service.dart';
import 'package:vaulted/domain/entities/enums.dart';
import 'package:vaulted/domain/repositories/metadata_repository.dart';
import 'package:vaulted/domain/repositories/search_repository.dart';

class MetadataService {
  final MetadataRepository _metadataRepository;
  final SearchRepository _searchRepository;
  final ThumbnailCacheService _thumbnailCacheService;
  final Map<Platform, MetadataProvider> _providers;
  final MetadataProvider _genericProvider;

  MetadataService({
    required MetadataRepository metadataRepository,
    required SearchRepository searchRepository,
    required ThumbnailCacheService thumbnailCacheService,
    required Map<Platform, MetadataProvider> providers,
    required MetadataProvider genericProvider,
  }) : _metadataRepository = metadataRepository,
       _searchRepository = searchRepository,
       _thumbnailCacheService = thumbnailCacheService,
       _providers = providers,
       _genericProvider = genericProvider;

  /// Fetches metadata in the background and updates the repository.
  Future<void> fetchMetadata(
    String contentId,
    String url,
    Platform platform,
  ) async {
    // Initial status update
    await _metadataRepository.updateMetadata(
      contentId,
      status: MetadataStatus.fetching,
    );

    try {
      final provider = _providers[platform] ?? _genericProvider;
      final extracted = await provider.getMetadata(url);

      String? localThumbnailPath;
      if (extracted.thumbnailUrl != null &&
          extracted.thumbnailUrl!.isNotEmpty) {
        localThumbnailPath = await _thumbnailCacheService.cacheThumbnail(
          extracted.thumbnailUrl!,
        );
      }

      await _metadataRepository.updateMetadata(
        contentId,
        title: extracted.title,
        creator: extracted.creator,
        description: extracted.description,
        thumbnail: localThumbnailPath, // Store local path
        duration: extracted.duration,
        status: MetadataStatus.ready,
      );

      // Index for FTS5 Search
      await _searchRepository.indexContent(
        contentId,
        extracted.title,
        extracted.description ?? '',
        extracted.creator ?? '',
        '', // Notes are added by the user elsewhere, not from metadata
        [], // Tags are added elsewhere
      );

      debugPrint('✅ Metadata saved successfully for $contentId!');
      debugPrint('   Title: ${extracted.title}');
      debugPrint('   Creator: ${extracted.creator}');
      debugPrint('   Thumbnail: $localThumbnailPath');
    } catch (e) {
      debugPrint('Failed to fetch metadata for $contentId: $e');
      await _metadataRepository.updateMetadata(
        contentId,
        status: MetadataStatus.failed,
      );
    }
  }
}
