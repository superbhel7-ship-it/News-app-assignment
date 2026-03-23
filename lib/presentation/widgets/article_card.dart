import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../domain/entities/article.dart';

class ArticleCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;
  final int? trendingIndex;

  const ArticleCard({
    super.key,
    required this.article,
    required this.onTap,
    this.trendingIndex,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (article.urlToImage != null)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(10),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: article.urlToImage!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Shimmer.fromColors(
                        baseColor: c.surface,
                        highlightColor: c.card,
                        child: Container(
                          height: 200,
                          color: c.surface,
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        height: 200,
                        color: c.surface,
                        child: Icon(
                          Icons.image_not_supported,
                          color: c.textSecondary,
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                  if (trendingIndex != null)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Trending ${trendingIndex! + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text('\u{1F525}', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),

            // Content
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Source & time
                  Row(
                    children: [
                      if (article.sourceName != null) ...[
                        const Icon(Icons.circle, size: 6, color: AppTheme.primary),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            article.sourceName!,
                            style: TextStyle(
                              color: c.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      if (article.publishedAt != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          DateFormatter.timeAgo(article.publishedAt),
                          style: TextStyle(
                            color: c.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Title
                  Text(
                    article.title,
                    style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),

                  if (article.description != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      article.description!,
                      style: TextStyle(
                        color: c.textSecondary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: 12),
                  // Stats row
                  Row(
                    children: [
                      _buildStat(Icons.thumb_up_outlined, '10k', c),
                      const SizedBox(width: 16),
                      _buildStat(Icons.chat_bubble_outline, '1k', c),
                      const SizedBox(width: 16),
                      _buildStat(Icons.visibility_outlined, '100k', c),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String count, AppColors c) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: c.textSecondary),
        const SizedBox(width: 4),
        Text(
          count,
          style: TextStyle(
            color: c.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class ArticleCardCompact extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;

  const ArticleCardCompact({
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
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (article.sourceName != null)
                    Row(
                      children: [
                        const Icon(Icons.circle, size: 5, color: AppTheme.primary),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            article.sourceName!,
                            style: TextStyle(
                              color: c.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (article.publishedAt != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            DateFormatter.timeAgo(article.publishedAt),
                            style: TextStyle(
                              color: c.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                  const SizedBox(height: 6),
                  Text(
                    article.title,
                    style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (article.urlToImage != null) ...[
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: article.urlToImage!,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Shimmer.fromColors(
                    baseColor: c.surface,
                    highlightColor: c.card,
                    child: Container(
                      width: 80,
                      height: 80,
                      color: c.surface,
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    width: 80,
                    height: 80,
                    color: c.surface,
                    child: Icon(
                      Icons.image_not_supported,
                      color: c.textSecondary,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
