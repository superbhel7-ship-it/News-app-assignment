import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Centralized styles, paddings, border radii, and box decorations
/// used across the app for consistency.
class AppStyles {
  AppStyles._();

  // ─── Border Radii ───
  static const double cardRadius = 10.0;
  static const double buttonPillRadius = 28.0;
  static const double chipRadius = 20.0;
  static const double imageThumbRadius = 8.0;
  static const double badgeRadius = 16.0;
  static const double inputRadius = 10.0;

  static BorderRadius cardBorderRadius = BorderRadius.circular(cardRadius);
  static BorderRadius buttonPillBorderRadius =
      BorderRadius.circular(buttonPillRadius);
  static BorderRadius chipBorderRadius = BorderRadius.circular(chipRadius);
  static BorderRadius imageBorderRadius =
      BorderRadius.circular(imageThumbRadius);
  static BorderRadius badgeBorderRadius = BorderRadius.circular(badgeRadius);
  static BorderRadius inputBorderRadius = BorderRadius.circular(inputRadius);

  // ─── Common Paddings ───
  static const EdgeInsets screenPadding =
      EdgeInsets.symmetric(horizontal: 16, vertical: 10);
  static const EdgeInsets sectionPadding = EdgeInsets.fromLTRB(16, 20, 16, 12);
  static const EdgeInsets cardContentPadding =
      EdgeInsets.fromLTRB(12, 10, 12, 10);
  static const EdgeInsets dialogPadding = EdgeInsets.all(20);

  // ─── Card Decorations ───
  static BoxDecoration cardDecoration = BoxDecoration(
    color: AppTheme.cardColor,
    borderRadius: cardBorderRadius,
  );

  static BoxDecoration surfaceDecoration = BoxDecoration(
    color: AppTheme.surface,
    borderRadius: cardBorderRadius,
  );

  static BoxDecoration chipDecoration = BoxDecoration(
    color: AppTheme.surface,
    borderRadius: chipBorderRadius,
    border: Border.all(color: AppTheme.dividerColor, width: 0.5),
  );

  static BoxDecoration actionChipDecoration = BoxDecoration(
    color: AppTheme.surface,
    borderRadius: BorderRadius.circular(cardRadius),
    border: Border.all(color: AppTheme.dividerColor, width: 0.5),
  );

  // ─── Common Text Styles ───
  static const TextStyle sectionTitle = TextStyle(
    color: AppTheme.textPrimary,
    fontSize: 20,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle cardTitle = TextStyle(
    color: AppTheme.textPrimary,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  static const TextStyle sourceName = TextStyle(
    color: AppTheme.textPrimary,
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle timeAgo = TextStyle(
    color: AppTheme.textSecondary,
    fontSize: 11,
  );

  static const TextStyle statText = TextStyle(
    color: AppTheme.textSecondary,
    fontSize: 11,
  );

  static const TextStyle chipLabel = TextStyle(
    color: AppTheme.textPrimary,
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle actionChipLabel = TextStyle(
    color: AppTheme.textSecondary,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle bodyText = TextStyle(
    color: AppTheme.textPrimary,
    fontSize: 16,
    height: 1.75,
    letterSpacing: 0.1,
  );

  static const TextStyle articleTitle = TextStyle(
    color: AppTheme.textPrimary,
    fontSize: 24,
    fontWeight: FontWeight.w800,
    height: 1.3,
    letterSpacing: -0.3,
  );
}
