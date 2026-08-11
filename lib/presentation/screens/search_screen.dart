import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaulted/application/providers/search_provider.dart';
import 'package:vaulted/domain/entities/content.dart';
import 'package:vaulted/domain/entities/enums.dart';
import 'package:vaulted/presentation/widgets/glass_container.dart';
import 'package:url_launcher/url_launcher.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSearchSubmitted(String query) {
    if (query.trim().isEmpty) return;
    ref.read(searchNotifierProvider).executeSearch(query);
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final isSearching = query.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search titles, notes, tags...',
            border: InputBorder.none,
            suffixIcon: isSearching
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      ref.read(searchNotifierProvider).setQuery('');
                    },
                  )
                : null,
          ),
          onChanged: (val) {
            ref.read(searchNotifierProvider).setQuery(val);
          },
          onSubmitted: _onSearchSubmitted,
          textInputAction: TextInputAction.search,
        ),
      ),
      body: isSearching ? const _SearchResults() : const _RecentSearches(),
    );
  }
}

class _RecentSearches extends ConsumerWidget {
  const _RecentSearches();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentAsync = ref.watch(recentSearchesProvider);

    return recentAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (searches) {
        if (searches.isEmpty) {
          return const Center(
            child: Text(
              'No recent searches',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          itemCount: searches.length,
          itemBuilder: (context, index) {
            final search = searches[index];
            return ListTile(
              leading: const Icon(Icons.history),
              title: Text(search),
              onTap: () {
                ref.read(searchNotifierProvider).setQuery(search);
              },
            );
          },
        );
      },
    );
  }
}

class _SearchResults extends ConsumerWidget {
  const _SearchResults();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(searchResultsProvider);

    return resultsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (items) {
        if (items.isEmpty) {
          return const Center(
            child: Text(
              'No results found',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: GridView.builder(
            padding: const EdgeInsets.only(top: 16, bottom: 32),
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
    final query = ref.watch(searchQueryProvider);

    return GestureDetector(
      onTap: _launchUrl,
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
                      child: HighlightedText(
                        text: item.title ?? item.content.url,
                        query: query,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                        highlightStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                          color: Theme.of(context).colorScheme.primary,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primaryContainer,
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

class HighlightedText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle? style;
  final TextStyle? highlightStyle;
  final int? maxLines;
  final TextOverflow? overflow;

  const HighlightedText({
    super.key,
    required this.text,
    required this.query,
    this.style,
    this.highlightStyle,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final cleanQuery = query.replaceAll(RegExp(r'[^\w\s]'), '');
    final words = cleanQuery
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();

    if (words.isEmpty || text.trim().isEmpty) {
      return Text(text, style: style, maxLines: maxLines, overflow: overflow);
    }

    final pattern = words.map(RegExp.escape).join('|');
    final regex = RegExp(pattern, caseSensitive: false);

    final List<TextSpan> spans = [];
    int start = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > start) {
        spans.add(
          TextSpan(text: text.substring(start, match.start), style: style),
        );
      }
      spans.add(
        TextSpan(
          text: match.group(0),
          style:
              highlightStyle ??
              style?.copyWith(fontWeight: FontWeight.w900, color: Colors.blue),
        ),
      );
      start = match.end;
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start), style: style));
    }

    return RichText(
      text: TextSpan(children: spans, style: style),
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
    );
  }
}
