import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaulted/core/providers.dart';
import 'package:vaulted/application/providers/search_provider.dart';
import 'package:vaulted/data/repositories/metadata_repository_impl.dart';
import 'package:vaulted/domain/entities/enums.dart';
import 'package:vaulted/domain/repositories/metadata_repository.dart';
import 'package:vaulted/core/services/metadata/metadata_provider.dart';
import 'package:vaulted/core/services/metadata/metadata_service.dart';
import 'package:vaulted/core/services/metadata/thumbnail_cache_service.dart';
import 'package:vaulted/core/services/metadata/providers/youtube_provider.dart';
import 'package:vaulted/core/services/metadata/providers/tiktok_provider.dart';
import 'package:vaulted/core/services/metadata/providers/generic_url_provider.dart';
import 'package:vaulted/core/services/metadata/providers/microlink_provider.dart';

import 'package:vaulted/application/providers/sync_provider.dart';

final metadataRepositoryProvider = Provider<MetadataRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final syncRepo = ref.watch(syncRepositoryProvider);
  return MetadataRepositoryImpl(db.metadataDao, syncRepo);
});

final thumbnailCacheServiceProvider = Provider<ThumbnailCacheService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ThumbnailCacheService(dioClient.dio);
});

final metadataServiceProvider = Provider<MetadataService>((ref) {
  final metadataRepo = ref.watch(metadataRepositoryProvider);
  final searchRepo = ref.watch(searchRepositoryProvider);
  final cacheService = ref.watch(thumbnailCacheServiceProvider);
  final dio = ref.watch(dioClientProvider).dio;
  
  final genericProvider = GenericUrlProvider(dio);
  
  final providers = <Platform, MetadataProvider>{
    Platform.youtube: YouTubeProvider(dio),
    Platform.tiktok: TikTokProvider(dio),
    Platform.instagram: MicrolinkProvider(dio),
    Platform.facebook: MicrolinkProvider(dio),
  };

  return MetadataService(
    metadataRepository: metadataRepo,
    searchRepository: searchRepo,
    thumbnailCacheService: cacheService,
    providers: providers,
    genericProvider: genericProvider,
  );
});
