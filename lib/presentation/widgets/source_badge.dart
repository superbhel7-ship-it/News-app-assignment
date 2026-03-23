import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_styles.dart';
import '../../core/utils/date_formatter.dart';

/// Reusable source badge widget showing a circular icon with source initial,
/// source name, and time ago. Used in article detail, world article cards, etc.
class SourceBadge extends StatelessWidget {
  final String? sourceName;
  final DateTime? publishedAt;
  final double iconSize;
  final double fontSize;
  final bool showTimeAgo;

  const SourceBadge({
    super.key,
    required this.sourceName,
    this.publishedAt,
    this.iconSize = 28,
    this.fontSize = 13,
    this.showTimeAgo = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Source icon circle
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.primary.withValues(alpha: 0.15),
          ),
          child: Center(
            child: Text(
              (sourceName ?? 'N')[0].toUpperCase(),
              style: TextStyle(
                color: AppTheme.primary,
                fontSize: iconSize * 0.46,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Source name
        Flexible(
          child: Text(
            sourceName ?? '',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (showTimeAgo && publishedAt != null) ...[
          const SizedBox(width: 8),
          Text(
            DateFormatter.timeAgo(publishedAt?.toIso8601String()),
            style: AppStyles.timeAgo,
          ),
        ],
      ],
    );
  }
}
