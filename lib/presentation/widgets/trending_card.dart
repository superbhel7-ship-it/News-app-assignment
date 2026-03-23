import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../domain/entities/article.dart';
import 'network_image.dart';

/// Trending card — text overlaid on image (exact design match)
class TrendingCard extends StatelessWidget {
  final Article article;
  final int trendingIndex;
  final VoidCallback onTap;

  const TrendingCard({
    super.key,
    required this.article,
    required this.trendingIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 290,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              // Full image background
              Positioned.fill(
                child: AppNetworkImage(
                  imageUrl: article.urlToImage ?? '',
                  fit: BoxFit.cover,
                ),
              ),

              // Gradient overlay (dark at bottom for text readability)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.5),
                        Colors.black.withValues(alpha: 0.85),
                      ],
                      stops: const [0.0, 0.3, 0.6, 1.0],
                    ),
                  ),
                ),
              ),

              // Trending badge (top-left)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Trending ${trendingIndex + 1} \u{1F525}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              // Content at bottom (overlaid on image)
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Source + time
                    Row(
                      children: [
                        const Icon(Icons.circle,
                            size: 6, color: Colors.white70),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            article.sourceName ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormatter.timeAgo(article.publishedAt),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Title
                    Text(
                      article.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    // Stats (realistic based on article hash)
                    Builder(builder: (_) {
                      final seed = article.title.hashCode;
                      final rng = Random(seed);
                      final likes = rng.nextInt(800) + 50;
                      final comments = rng.nextInt(200) + 10;
                      final views = rng.nextInt(5000) + 500;
                      return Row(
                        children: [
                          _stat(Icons.thumb_up_outlined, _formatNum(likes)),
                          const SizedBox(width: 14),
                          _stat(Icons.chat_bubble_outline, _formatNum(comments)),
                          const SizedBox(width: 14),
                          _stat(Icons.visibility_outlined, _formatNum(views)),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(IconData icon, String count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.white60),
        const SizedBox(width: 3),
        Text(count,
            style: const TextStyle(color: Colors.white60, fontSize: 11)),
      ],
    );
  }

  String _formatNum(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return n.toString();
  }
}
