import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaulted/application/providers/auth_provider.dart';
import 'package:vaulted/application/providers/content_provider.dart';
import 'package:vaulted/application/providers/folder_provider.dart';
import 'package:vaulted/core/services/share_parser.dart';
import 'package:vaulted/application/providers/metadata_providers.dart';
import 'package:vaulted/domain/entities/content.dart';
import 'package:vaulted/core/utils/uuid_utils.dart';
import 'package:vaulted/presentation/widgets/glass_container.dart';

class SaveShareBottomSheet extends ConsumerStatefulWidget {
  final ParsedShare share;

  const SaveShareBottomSheet({super.key, required this.share});

  static Future<void> show(BuildContext context, ParsedShare share) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SaveShareBottomSheet(share: share),
      ),
    );
  }

  @override
  ConsumerState<SaveShareBottomSheet> createState() => _SaveShareBottomSheetState();
}

class _SaveShareBottomSheetState extends ConsumerState<SaveShareBottomSheet> {
  final _noteController = TextEditingController();
  String? _selectedFolderId;
  bool _isLoading = true;
  Content? _existingContent;

  @override
  void initState() {
    super.initState();
    _checkDuplicate();
  }
  
  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _checkDuplicate() async {
    final duplicateService = ref.read(duplicateDetectionServiceProvider);
    final existing = await duplicateService.findExistingContent(widget.share.canonicalUrl);
    
    if (mounted) {
      setState(() {
        _existingContent = existing;
        _isLoading = false;
      });
    }
  }

  Future<void> _save() async {
    final userId = await ref.read(authRepositoryProvider).getCurrentUserId();
    if (userId == null) return;
    
    final contentRepo = ref.read(contentRepositoryProvider);
    
    final contentToSave = _existingContent ?? Content(
      id: UuidUtils.generateV7(),
      platform: widget.share.platform,
      type: widget.share.type,
      url: widget.share.url,
      canonicalUrl: widget.share.canonicalUrl,
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );

    await contentRepo.saveItem(
      userId: userId,
      content: contentToSave,
      folderId: _selectedFolderId,
      notes: _noteController.text.trim(),
    );
    
    // Trigger background metadata fetch
    ref.read(metadataServiceProvider).fetchMetadata(
      contentToSave.id,
      contentToSave.url,
      contentToSave.platform,
    );
    
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved to Vaulted!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final foldersState = ref.watch(foldersProvider);
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: _isLoading 
        ? const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()))
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Save to Vaulted',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                widget.share.url,
                style: const TextStyle(color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              
              if (_existingContent != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange),
                      SizedBox(width: 12),
                      Expanded(child: Text('You have already saved this link before. Saving again will create a new reference.')),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              const Text('Add a Note', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              GlassContainer(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    hintText: 'Why are you saving this?',
                    border: InputBorder.none,
                  ),
                  maxLines: 3,
                  minLines: 1,
                ),
              ),
              
              const SizedBox(height: 24),
              const Text('Select Folder', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              
              SizedBox(
                height: 50,
                child: foldersState.when(
                  data: (folders) {
                    if (folders.isEmpty) return const Text('No folders available.');
                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: folders.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final folder = folders[index];
                        final isSelected = _selectedFolderId == folder.id;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedFolderId = folder.id),
                          child: GlassContainer(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            opacity: isSelected ? 0.3 : 0.05,
                            border: isSelected ? Border.all(color: folder.displayColor, width: 2) : null,
                            child: Row(
                              children: [
                                Icon(folder.displayIcon, color: folder.displayColor, size: 20),
                                const SizedBox(width: 8),
                                Text(folder.name, style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                )),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Error: $e'),
                ),
              ),
              
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Save to Vault', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
    );
  }
}
