import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../domain/entities/article.dart';
import 'network_image.dart';

/// Compact world article card with source icon, title, and optional thumbnail.
/// Used in the "World" section of the home screen.
class WorldArticleCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;

  const WorldArticleCard({
    super.key,
    required this.article,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Source icon
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withValues(alpha: 0.15),
              ),
              child: Center(
                child: Text(
                  (article.sourceName ?? 'N')[0].toUpperCase(),
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Source name + time
                  Row(
                    children: [
                      Text(
                        article.sourceName ?? '',
                        style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormatter.timeAgo(article.publishedAt),
                        style: TextStyle(
                          color: c.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Article with image
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          article.title,
                          style: TextStyle(
                            color: c.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (article.urlToImage != null) ...[
                        const SizedBox(width: 12),
                        AppNetworkImage(
                          imageUrl: article.urlToImage!,
                          width: 90,
                          height: 90,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // 3 dot menu
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(Icons.more_horiz,
                  size: 18, color: c.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
