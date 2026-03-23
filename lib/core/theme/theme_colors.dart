import 'package:flutter/material.dart';

/// Helper extension to get theme-aware colors from any BuildContext.
/// Use `context.colors` instead of hardcoded AppTheme constants.
extension ThemeColors on BuildContext {
  AppColors get colors => AppColors(this);
}

class AppColors {
  final BuildContext _context;
  AppColors(this._context);

  bool get isDark => Theme.of(_context).brightness == Brightness.dark;

  Color get background => Theme.of(_context).scaffoldBackgroundColor;
  Color get surface => isDark ? const Color(0xFF161B22) : Colors.white;
  Color get card => isDark ? const Color(0xFF1C2128) : Colors.white;
  Color get textPrimary => isDark ? Colors.white : const Color(0xFF1C1C1E);
  Color get textSecondary =>
      isDark ? const Color(0xFF8B949E) : const Color(0xFF8E8E93);
  Color get divider =>
      isDark ? const Color(0xFF30363D) : const Color(0xFFD1D1D6);
  Color get primary => const Color(0xFF1E88E5);
  Color get shimmerBase =>
      isDark ? const Color(0xFF1E2A3A) : const Color(0xFFE0E0E0);
  Color get shimmerHighlight =>
      isDark ? const Color(0xFF2A3A4A) : const Color(0xFFF5F5F5);
}
