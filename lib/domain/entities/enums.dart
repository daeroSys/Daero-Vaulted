enum Platform {
  youtube,
  instagram,
  facebook,
  tiktok,
  unknown;

  /// Parses a string to a [Platform] enum.
  static Platform fromString(String value) {
    return Platform.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => Platform.unknown,
    );
  }
}

enum ContentType {
  shortVideo,
  video,
  article,
  post,
  pdf,
  podcast,
  repository,
  link,
  unknown;

  static ContentType fromString(String value) {
    // Handling snake_case from DB
    final normalized = value.replaceAll('_', '').toLowerCase();
    return ContentType.values.firstWhere(
      (e) => e.name.toLowerCase() == normalized,
      orElse: () => ContentType.unknown,
    );
  }
}

enum MetadataStatus {
  pending,
  fetching,
  ready,
  failed,
  stale;

  static MetadataStatus fromString(String value) {
    return MetadataStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => MetadataStatus.pending,
    );
  }
}

enum SyncOperation {
  create,
  update,
  delete,
  restore,
  metadataRefresh;

  static SyncOperation fromString(String value) {
    final normalized = value.replaceAll('_', '').toLowerCase();
    return SyncOperation.values.firstWhere(
      (e) => e.name.toLowerCase() == normalized,
      orElse: () => SyncOperation.create,
    );
  }
}

enum SyncPriority {
  high,
  normal,
  low;

  static SyncPriority fromString(String value) {
    return SyncPriority.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => SyncPriority.normal,
    );
  }
}

enum SyncStatus {
  pending,
  running,
  synced,
  failed,
  retrying;

  static SyncStatus fromString(String value) {
    return SyncStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => SyncStatus.pending,
    );
  }
}
