import 'enums.dart';

class Content {
  final String id;
  final Platform platform;
  final ContentType type;
  final String url;
  final String canonicalUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  Content({
    required this.id,
    required this.platform,
    required this.type,
    required this.url,
    required this.canonicalUrl,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;
}

class SavedItem {
  final String id;
  final String userId;
  final String? folderId;
  final String contentId;
  final String notes;
  final bool isFavorite;
  final bool isArchived;
  final DateTime savedAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  SavedItem({
    required this.id,
    required this.userId,
    this.folderId,
    required this.contentId,
    this.notes = '',
    this.isFavorite = false,
    this.isArchived = false,
    required this.savedAt,
    required this.updatedAt,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;
}

class SavedItemView {
  final SavedItem savedItem;
  final Content content;
  final String? title;
  final String? description;
  final String? thumbnail;
  final int? duration;

  SavedItemView({
    required this.savedItem,
    required this.content,
    this.title,
    this.description,
    this.thumbnail,
    this.duration,
  });
}
