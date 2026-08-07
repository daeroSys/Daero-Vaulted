import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaulted/core/providers.dart';
import 'package:vaulted/data/repositories/metadata_repository_impl.dart';
import 'package:vaulted/domain/entities/enums.dart';
import 'package:vaulted/domain/repositories/metadata_repository.dart';
import 'package:vaulted/core/services/metadata/metadata_provider.dart';
import 'package:vaulted/core/services/metadata/metadata_service.dart';
import 'package:vaulted/core/services/metadata/thumbnail_cache_service.dart';
import 'package:vaulted/core/services/metadata/providers/youtube_provider.dart';
import 'package:vaulted/core/services/metadata/providers/tiktok_provider.dart';
import 'package:vaulted/core/services/metadata/providers/instagram_provider.dart';
import 'package:vaulted/core/services/metadata/providers/generic_url_provider.dart';

final metadataRepositoryProvider = Provider<MetadataRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return MetadataRepositoryImpl(db.metadataDao);
});

final thumbnailCacheServiceProvider = Provider<ThumbnailCacheService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ThumbnailCacheService(dioClient.dio);
});

final metadataServiceProvider = Provider<MetadataService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  final dio = dioClient.dio;
  
  final genericProvider = GenericUrlProvider(dio);
  
  final providers = <Platform, MetadataProvider>{
    Platform.youtube: YouTubeProvider(dio),
    Platform.tiktok: TikTokProvider(dio),
    Platform.instagram: InstagramProvider(dio),
    Platform.facebook: genericProvider,
  };

  return MetadataService(
    metadataRepository: ref.watch(metadataRepositoryProvider),
    thumbnailCacheService: ref.watch(thumbnailCacheServiceProvider),
    providers: providers,
    genericProvider: genericProvider,
  );
});
