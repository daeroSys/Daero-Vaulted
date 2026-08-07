class ExtractedMetadata {
  final String title;
  final String? creator;
  final String? description;
  final String? thumbnailUrl;
  final int? duration;

  const ExtractedMetadata({
    required this.title,
    this.creator,
    this.description,
    this.thumbnailUrl,
    this.duration,
  });

  @override
  String toString() {
    return 'ExtractedMetadata(title: $title, creator: $creator, description: $description, thumbnailUrl: $thumbnailUrl, duration: $duration)';
  }
}
