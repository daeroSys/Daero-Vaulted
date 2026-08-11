import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaulted/application/providers/folder_provider.dart';
import 'package:vaulted/domain/entities/folder.dart';
import 'package:vaulted/presentation/widgets/glass_container.dart';
import 'package:vaulted/core/exceptions/quota_exception.dart';
import 'package:vaulted/presentation/premium/premium_paywall_screen.dart';

class FolderFormBottomSheet extends ConsumerStatefulWidget {
  final Folder? folder;

  const FolderFormBottomSheet({super.key, this.folder});

  static Future<void> show(BuildContext context, {Folder? folder}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: FolderFormBottomSheet(folder: folder),
      ),
    );
  }

  @override
  ConsumerState<FolderFormBottomSheet> createState() =>
      _FolderFormBottomSheetState();
}

class _FolderFormBottomSheetState extends ConsumerState<FolderFormBottomSheet> {
  final _nameController = TextEditingController();
  String _selectedIcon = 'folder';
  String _selectedColor = '#3B82F6'; // Default Blue

  // Preset Colors
  final List<String> _colors = [
    '#EF4444', // Red
    '#F97316', // Orange
    '#F59E0B', // Amber
    '#10B981', // Emerald
    '#3B82F6', // Blue
    '#6366F1', // Indigo
    '#8B5CF6', // Violet
    '#EC4899', // Pink
  ];

  // Preset Icons
  final List<String> _icons = [
    'folder',
    'work',
    'school',
    'star',
    'home',
    'book',
    'article',
    'code',
    'lightbulb',
    'explore',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.folder != null) {
      _nameController.text = widget.folder!.name;
      _selectedIcon = widget.folder!.icon ?? 'folder';
      _selectedColor = widget.folder!.color ?? '#3B82F6';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final notifier = ref.read(foldersProvider.notifier);
    try {
      if (widget.folder == null) {
        await notifier.createFolder(name, _selectedIcon, _selectedColor);
      } else {
        await notifier.updateFolder(
          widget.folder!.id,
          name: name,
          icon: _selectedIcon,
          color: _selectedColor,
        );
      }
      if (mounted) {
        Navigator.of(context).pop();
      }
    } on QuotaExceededException catch (_) {
      if (mounted) {
        Navigator.of(context).pop();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                const PremiumPaywallScreen(featureName: 'unlimited folders'),
            fullscreenDialog: true,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.folder == null ? 'New Folder' : 'Edit Folder',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // Name Input
          GlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Folder Name',
                border: InputBorder.none,
                fillColor: Colors.transparent,
              ),
              autofocus: true,
              onSubmitted: (_) => _save(),
            ),
          ),

          const SizedBox(height: 24),
          const Text('Color', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),

          // Color Picker
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _colors.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final hex = _colors[index];
                final color = Color(
                  int.parse(hex.replaceAll('#', 'FF'), radix: 16),
                );
                final isSelected = _selectedColor == hex;

                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = hex),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(
                              color: isDarkMode ? Colors.white : Colors.black,
                              width: 3,
                            )
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),
          const Text('Icon', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),

          // Icon Picker
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _icons.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final iconName = _icons[index];
                final isSelected = _selectedIcon == iconName;
                final dummyFolder = Folder(
                  id: '',
                  userId: '',
                  name: '',
                  position: 0,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                  icon: iconName,
                );
                final iconData = dummyFolder.displayIcon;

                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = iconName),
                  child: GlassContainer(
                    width: 48,
                    height: 48,
                    opacity: isSelected ? 0.3 : 0.05,
                    borderRadius: BorderRadius.circular(12),
                    child: Center(
                      child: Icon(
                        iconData,
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : null,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 32),

          // Save Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Save',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
