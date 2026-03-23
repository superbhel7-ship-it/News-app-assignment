import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/article.dart';

class StoriesBar extends StatelessWidget {
  final List<Article> articles;
  final void Function(Article) onTap;

  const StoriesBar({super.key, required this.articles, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (articles.isEmpty) return const SizedBox.shrink();

    // Group by source for stories
    final Map<String, List<Article>> grouped = {};
    for (final a in articles) {
      final src = a.sourceName ?? 'News';
      grouped.putIfAbsent(src, () => []);
      grouped[src]!.add(a);
    }
    final sources = grouped.keys.take(10).toList();

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: sources.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, i) {
          final name = sources[i];
          final storyArticles = grouped[name]!;
          final firstArticle = storyArticles.first;
          final hasImage = firstArticle.urlToImage != null;

          return GestureDetector(
            onTap: () => onTap(firstArticle),
            child: Column(
              children: [
                // Story ring
                Container(
                  width: 64,
                  height: 64,
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primary,
                        AppTheme.primary.withValues(alpha: 0.4),
                        const Color(0xFF00E676),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.background,
                      border: Border.all(color: AppTheme.background, width: 2),
                    ),
                    child: ClipOval(
                      child: hasImage
                          ? CachedNetworkImage(
                              imageUrl: firstArticle.urlToImage!,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => _buildFallback(name),
                            )
                          : _buildFallback(name),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                // Source name
                SizedBox(
                  width: 68,
                  child: Text(
                    name,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFallback(String name) {
    return Container(
      color: AppTheme.surface,
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'N',
          style: const TextStyle(
            color: AppTheme.primary,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
