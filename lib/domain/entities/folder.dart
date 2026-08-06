import 'package:flutter/material.dart';

class Folder {
  final String id;
  final String userId;
  final String name;
  final String? icon;
  final String? color;
  final int position;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  Folder({
    required this.id,
    required this.userId,
    required this.name,
    this.icon,
    this.color,
    required this.position,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  /// Helper to get a Flutter Color from the stored hex string, defaulting to grey
  Color get displayColor {
    if (color == null || color!.isEmpty) return Colors.grey;
    try {
      String hex = color!.replaceAll('#', '');
      if (hex.length == 6) hex = 'FF$hex';
      return Color(int.parse(hex, radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }

  /// Helper to get a Flutter IconData from the stored string, defaulting to folder
  IconData get displayIcon {
    // We will use a predefined set of icons mapped by string names.
    // For now, default to folder if none provided.
    return _iconMap[icon] ?? Icons.folder_rounded;
  }

  static const Map<String, IconData> _iconMap = {
    'folder': Icons.folder_rounded,
    'work': Icons.work_rounded,
    'school': Icons.school_rounded,
    'star': Icons.star_rounded,
    'home': Icons.home_rounded,
    'book': Icons.book_rounded,
    'article': Icons.article_rounded,
    'code': Icons.code_rounded,
    'lightbulb': Icons.lightbulb_rounded,
    'explore': Icons.explore_rounded,
  };
}
