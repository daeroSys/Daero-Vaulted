import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vaulted/application/providers/folder_provider.dart';
import 'package:vaulted/application/providers/recent_content_provider.dart';
import 'package:vaulted/presentation/widgets/glass_container.dart';
import 'package:vaulted/presentation/widgets/shimmer_loading.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentContentState = ref.watch(recentContentProvider);
    final foldersState = ref.watch(foldersProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Vaulted',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              color: Theme.of(
                context,
              ).scaffoldBackgroundColor.withValues(alpha: 0.5),
            ),
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
          CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 60,
                  bottom: 100,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Welcome Back',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ).animate().fade().slideY(begin: 0.2, duration: 400.ms),
                    ),
                    const SizedBox(height: 32),

                    // Recently Saved Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child:
                          Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Recently Saved',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              )
                              .animate()
                              .fade(delay: 100.ms)
                              .slideY(begin: 0.2, duration: 400.ms),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 140,
                      child: recentContentState.when(
                        data: (items) {
                          if (items.isEmpty) {
                            return const Center(
                              child: Text('No saved items yet.'),
                            );
                          }
                          return ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            scrollDirection: Axis.horizontal,
                            itemCount: items.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 16),
                            itemBuilder: (context, index) {
                              final item = items[index];
                              return GlassContainer(
                                    width: 240,
                                    padding: const EdgeInsets.all(12),
                                    onTap: () {
                                      // Navigating to detail would go here.
                                      // For now just show a simple snackbar or push somewhere
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Item detail coming soon!',
                                          ),
                                        ),
                                      );
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (item.thumbnail != null)
                                          Expanded(
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child:
                                                  item.thumbnail!.startsWith(
                                                    'http',
                                                  )
                                                  ? Image.network(
                                                      item.thumbnail!,
                                                      width: double.infinity,
                                                      fit: BoxFit.cover,
                                                      errorBuilder:
                                                          (
                                                            _,
                                                            __,
                                                            ___,
                                                          ) => Container(
                                                            color: Colors.grey
                                                                .withValues(
                                                                  alpha: 0.2,
                                                                ),
                                                            child: const Center(
                                                              child: Icon(
                                                                Icons.link,
                                                              ),
                                                            ),
                                                          ),
                                                    )
                                                  : Image.file(
                                                      File(item.thumbnail!),
                                                      width: double.infinity,
                                                      fit: BoxFit.cover,
                                                      errorBuilder:
                                                          (
                                                            _,
                                                            __,
                                                            ___,
                                                          ) => Container(
                                                            color: Colors.grey
                                                                .withValues(
                                                                  alpha: 0.2,
                                                                ),
                                                            child: const Center(
                                                              child: Icon(
                                                                Icons.link,
                                                              ),
                                                            ),
                                                          ),
                                                    ),
                                            ),
                                          )
                                        else
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.grey.withValues(
                                                  alpha: 0.2,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Center(
                                                child: Icon(Icons.link),
                                              ),
                                            ),
                                          ),
                                        const SizedBox(height: 8),
                                        Text(
                                          item.title ?? item.content.url,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  )
                                  .animate(delay: (200 + index * 100).ms)
                                  .fade()
                                  .scale(begin: const Offset(0.9, 0.9));
                            },
                          );
                        },
                        loading: () => ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          itemCount: 3,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 16),
                          itemBuilder: (context, index) =>
                              const ShimmerContainer(width: 240, height: 140),
                        ),
                        error: (err, stack) =>
                            Center(child: Text('Error: $err')),
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Quick Folders Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child:
                          Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Your Folders',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      context.go('/folders');
                                    },
                                    child: const Text('View All'),
                                  ),
                                ],
                              )
                              .animate()
                              .fade(delay: 300.ms)
                              .slideY(begin: 0.2, duration: 400.ms),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: foldersState.when(
                        data: (folders) {
                          if (folders.isEmpty) {
                            return const Center(
                              child: Text('No folders created yet.'),
                            );
                          }
                          // Only show up to 4 folders on the home screen grid
                          final displayFolders = folders.take(4).toList();
                          return GridView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 1.2,
                                ),
                            itemCount: displayFolders.length,
                            itemBuilder: (context, index) {
                              final folder = displayFolders[index];
                              return GlassContainer(
                                    onTap: () {
                                      context.push('/folders/${folder.id}');
                                    },
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: folder.displayColor
                                                .withValues(alpha: 0.2),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            folder.displayIcon,
                                            color: folder.displayColor,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          folder.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  )
                                  .animate(delay: (400 + index * 100).ms)
                                  .fade()
                                  .scale(begin: const Offset(0.9, 0.9));
                            },
                          );
                        },
                        loading: () => GridView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 1.2,
                              ),
                          itemCount: 4,
                          itemBuilder: (context, index) =>
                              const ShimmerContainer(
                                width: double.infinity,
                                height: double.infinity,
                              ),
                        ),
                        error: (err, stack) =>
                            Center(child: Text('Error: $err')),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
