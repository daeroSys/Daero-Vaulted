import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vaulted/application/providers/folder_provider.dart';
import 'package:vaulted/application/providers/content_provider.dart';
import 'package:vaulted/domain/entities/content.dart';
import 'package:vaulted/domain/entities/enums.dart';
import 'package:vaulted/presentation/widgets/folder_form_bottom_sheet.dart';
import 'package:vaulted/presentation/widgets/glass_container.dart';
import 'package:url_launcher/url_launcher.dart';

class FolderDetailsScreen extends ConsumerWidget {
  final String folderId;

  const FolderDetailsScreen({super.key, required this.folderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foldersAsync = ref.watch(foldersProvider);
    final folder = foldersAsync.value
        ?.where((f) => f.id == folderId)
        .firstOrNull;

    final itemsAsync = ref.watch(folderItemsProvider(folderId));

    if (folder == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Folder not found')),
        body: const Center(child: Text('This folder does not exist.')),
      );
    }

    final color = folder.displayColor;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: color.withValues(alpha: 0.2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            Icon(folder.displayIcon),
            const SizedBox(width: 8),
            Text(
              folder.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              FolderFormBottomSheet.show(context, folder: folder);
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.1),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: itemsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data: (items) {
            if (items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.folder_open,
                      size: 64,
                      color: color.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'This folder is empty',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Share links from other apps to save them here.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.only(
                top: 100.0,
                left: 16,
                right: 16,
              ), // Account for AppBar
              child: GridView.builder(
                padding: const EdgeInsets.only(bottom: 32),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return _SavedItemCard(item: items[index]);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SavedItemCard extends ConsumerWidget {
  final SavedItemView item;

  const _SavedItemCard({required this.item});

  Future<void> _launchUrl() async {
    final uri = Uri.parse(item.content.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: _launchUrl,
      onLongPress: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Remove Video'),
            content: const Text(
              'Are you sure you want to remove this video from your folder?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  ref
                      .read(contentRepositoryProvider)
                      .softDeleteSavedItem(item.savedItem.id);
                  Navigator.pop(context);
                },
                child: const Text(
                  'Remove',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
      child: GlassContainer(
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: item.thumbnail != null
                    ? Image.file(
                        File(item.thumbnail!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildFallbackImage(context),
                      )
                    : _buildFallbackImage(context),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildPlatformIcon(),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.content.platform.name.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Expanded(
                      child: Text(
                        item.title ?? item.content.url,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackImage(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Center(
        child: Icon(Icons.link, size: 48, color: Colors.grey),
      ),
    );
  }

  Widget _buildPlatformIcon() {
    IconData iconData;
    switch (item.content.platform) {
      case Platform.youtube:
        iconData = Icons.play_circle_filled;
        break;
      case Platform.instagram:
        iconData = Icons.camera_alt;
        break;
      case Platform.tiktok:
        iconData = Icons.music_note;
        break;
      case Platform.facebook:
        iconData = Icons.facebook;
        break;
      default:
        iconData = Icons.language;
    }
    return Icon(iconData, size: 14, color: Colors.grey);
  }
}
