import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaulted/application/providers/folder_provider.dart';
import 'package:vaulted/presentation/widgets/glass_container.dart';
import 'package:vaulted/presentation/widgets/folder_form_bottom_sheet.dart';
import 'package:vaulted/core/services/share_service.dart';
import 'package:vaulted/presentation/widgets/save_share_bottom_sheet.dart';

class FoldersScreen extends ConsumerWidget {
  const FoldersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Keep ShareService alive to capture intents
    ref.watch(shareServiceProvider);
    
    ref.listen(shareIntentStreamProvider, (previous, next) {
      next.whenData((share) {
        SaveShareBottomSheet.show(context, share);
      });
    });

    final foldersState = ref.watch(foldersProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Folders', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.5)),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Dynamic background (Glassmorphism aesthetics)
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: Container(color: Colors.transparent),
            ),
          ),

          // Content
          foldersState.when(
            data: (folders) {
              if (folders.isEmpty) {
                return const Center(
                  child: Text('No folders yet. Create one!'),
                );
              }
              
              return ReorderableListView.builder(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 60,
                  bottom: 100,
                  left: 16,
                  right: 16,
                ),
                itemCount: folders.length,
                onReorderItem: (oldIndex, newIndex) {
                  ref.read(foldersProvider.notifier).reorderFolders(oldIndex, newIndex);
                },
                itemBuilder: (context, index) {
                  final folder = folders[index];
                  return Dismissible(
                    key: ValueKey(folder.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.delete_rounded, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      ref.read(foldersProvider.notifier).deleteFolder(folder.id);
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${folder.name} deleted'),
                          behavior: SnackBarBehavior.floating,
                          action: SnackBarAction(
                            label: 'UNDO',
                            onPressed: () {
                              ref.read(foldersProvider.notifier).restoreFolder(folder.id);
                            },
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: GestureDetector(
                        onTap: () {
                          FolderFormBottomSheet.show(context, folder: folder);
                        },
                        child: GlassContainer(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: folder.displayColor.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(folder.displayIcon, color: folder.displayColor),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  folder.name,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                ),
                              ),
                              const Icon(Icons.drag_indicator_rounded, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => FolderFormBottomSheet.show(context),
        child: const Icon(Icons.create_new_folder_rounded),
      ),
    );
  }
}
