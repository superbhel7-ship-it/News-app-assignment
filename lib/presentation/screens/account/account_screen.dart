import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import 'edit_profile_screen.dart';

// ---------------------------------------------------------------------------
// Providers for settings stored in Hive
// ---------------------------------------------------------------------------

class _NotificationsNotifier extends Notifier<bool> {
  @override
  bool build() {
    _load();
    return true;
  }

  Future<void> _load() async {
    final box = await Hive.openBox('settings');
    state = box.get('notifications_enabled', defaultValue: true) as bool;
  }

  Future<void> toggle() async {
    final box = await Hive.openBox('settings');
    state = !state;
    await box.put('notifications_enabled', state);
  }
}

final _notificationsProvider = NotifierProvider<_NotificationsNotifier, bool>(
  _NotificationsNotifier.new,
);

class _LanguageNotifier extends Notifier<String> {
  @override
  String build() {
    _load();
    return 'English';
  }

  Future<void> _load() async {
    final box = await Hive.openBox('settings');
    state = box.get('language', defaultValue: 'English') as String;
  }

  Future<void> setLanguage(String lang) async {
    final box = await Hive.openBox('settings');
    state = lang;
    await box.put('language', lang);
  }
}

final _languageProvider = NotifierProvider<_LanguageNotifier, String>(
  _LanguageNotifier.new,
);

// ---------------------------------------------------------------------------
// Account Screen
// ---------------------------------------------------------------------------

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final notificationsOn = ref.watch(_notificationsProvider);
    final language = ref.watch(_languageProvider);

    // Adaptive colors
    final bgColor = isDark ? AppTheme.background : const Color(0xFFF2F2F7);
    final surfaceColor = isDark ? AppTheme.surface : Colors.white;
    final textColor = isDark ? AppTheme.textPrimary : const Color(0xFF1C1C1E);
    final secondaryText = isDark ? AppTheme.textSecondary : const Color(0xFF8E8E93);
    final divider = isDark ? AppTheme.dividerColor : const Color(0xFFD1D1D6);

    final email = authState.email ?? 'user@example.com';
    final initial = email.isNotEmpty ? email[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ---------- App Bar ----------
          SliverAppBar(
            expandedHeight: 0,
            pinned: true,
            backgroundColor: bgColor,
            title: Text(
              'Settings',
              style: TextStyle(
                color: textColor,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            centerTitle: true,
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 8),

                  // ========== PROFILE CARD ==========
                  _GlassContainer(
                    isDark: isDark,
                    surfaceColor: surfaceColor,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      child: Row(
                        children: [
                          // Avatar
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppTheme.primary,
                                  AppTheme.primary.withValues(alpha: 0.55),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary.withValues(alpha: 0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                initial,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FutureBuilder(
                                  future: Hive.openBox('profile'),
                                  builder: (ctx, snap) {
                                    final name = snap.hasData
                                        ? (snap.data as Box).get('name', defaultValue: '') as String
                                        : '';
                                    return Text(
                                      name.isNotEmpty ? name : 'News Enthusiast',
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  email,
                                  style: TextStyle(
                                    color: secondaryText,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          // Edit button
                          _buildIconButton(
                            icon: Icons.edit_outlined,
                            color: AppTheme.primary,
                            onTap: () => Navigator.push(
                              context,
                              CupertinoPageRoute(builder: (_) => const EditProfileScreen()),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ========== APPEARANCE ==========
                  _SectionHeader(title: 'APPEARANCE', color: secondaryText),
                  const SizedBox(height: 8),
                  _GlassContainer(
                    isDark: isDark,
                    surfaceColor: surfaceColor,
                    child: _SettingsTile(
                      icon: Icons.dark_mode_outlined,
                      iconBgColor: const Color(0xFF5E5CE6),
                      title: 'Dark Mode',
                      textColor: textColor,
                      trailing: CupertinoSwitch(
                        value: isDark,
                        activeTrackColor: AppTheme.primary,
                        onChanged: (_) => ref.read(themeProvider.notifier).toggleTheme(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ========== PREFERENCES ==========
                  _SectionHeader(title: 'PREFERENCES', color: secondaryText),
                  const SizedBox(height: 8),
                  _GlassContainer(
                    isDark: isDark,
                    surfaceColor: surfaceColor,
                    child: Column(
                      children: [
                        _SettingsTile(
                          icon: Icons.language,
                          iconBgColor: const Color(0xFFFF9F0A),
                          title: 'Language',
                          textColor: textColor,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                language,
                                style: TextStyle(color: secondaryText, fontSize: 15),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.chevron_right, color: secondaryText, size: 20),
                            ],
                          ),
                          onTap: () => _showLanguageSheet(context, ref, isDark, surfaceColor, textColor, secondaryText),
                        ),
                        Divider(height: 0.5, indent: 56, color: divider.withValues(alpha: 0.5)),
                        _SettingsTile(
                          icon: Icons.notifications_outlined,
                          iconBgColor: const Color(0xFFFF3B30),
                          title: 'Push Notifications',
                          textColor: textColor,
                          trailing: CupertinoSwitch(
                            value: notificationsOn,
                            activeTrackColor: AppTheme.primary,
                            onChanged: (_) => ref.read(_notificationsProvider.notifier).toggle(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ========== ABOUT ==========
                  _SectionHeader(title: 'ABOUT', color: secondaryText),
                  const SizedBox(height: 8),
                  _GlassContainer(
                    isDark: isDark,
                    surfaceColor: surfaceColor,
                    child: Column(
                      children: [
                        _SettingsTile(
                          icon: Icons.info_outline,
                          iconBgColor: AppTheme.primary,
                          title: 'App Version',
                          textColor: textColor,
                          trailing: Text(
                            '1.0.0',
                            style: TextStyle(color: secondaryText, fontSize: 15),
                          ),
                        ),
                        Divider(height: 0.5, indent: 56, color: divider.withValues(alpha: 0.5)),
                        _SettingsTile(
                          icon: Icons.description_outlined,
                          iconBgColor: const Color(0xFF30D158),
                          title: 'Terms of Service',
                          textColor: textColor,
                          trailing: Icon(Icons.chevron_right, color: secondaryText, size: 20),
                          onTap: () {},
                        ),
                        Divider(height: 0.5, indent: 56, color: divider.withValues(alpha: 0.5)),
                        _SettingsTile(
                          icon: Icons.shield_outlined,
                          iconBgColor: const Color(0xFF64D2FF),
                          title: 'Privacy Policy',
                          textColor: textColor,
                          trailing: Icon(Icons.chevron_right, color: secondaryText, size: 20),
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ========== LOGOUT ==========
                  _GlassContainer(
                    isDark: isDark,
                    surfaceColor: surfaceColor,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => _showLogoutDialog(context, ref, isDark, surfaceColor, textColor, secondaryText),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Text(
                              'Log Out',
                              style: TextStyle(
                                color: AppTheme.errorColor,
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  void _showLanguageSheet(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    Color surfaceColor,
    Color textColor,
    Color secondaryText,
  ) {
    final languages = [
      'English',
      'Hindi',
      'Tamil',
      'Telugu',
      'Kannada',
      'Malayalam',
      'Bengali',
      'Marathi',
      'Gujarati',
      'Punjabi',
    ];
    final current = ref.read(_languageProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? surfaceColor.withValues(alpha: 0.85)
                    : surfaceColor.withValues(alpha: 0.95),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: secondaryText.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Text(
                            'Select Language',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => Navigator.pop(ctx),
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: secondaryText.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.close, size: 18, color: secondaryText),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...languages.map((lang) {
                      final isSelected = lang == current;
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            ref.read(_languageProvider.notifier).setLanguage(lang);
                            Navigator.pop(ctx);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            child: Row(
                              children: [
                                Text(
                                  lang,
                                  style: TextStyle(
                                    color: isSelected ? AppTheme.primary : textColor,
                                    fontSize: 17,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  ),
                                ),
                                const Spacer(),
                                if (isSelected)
                                  const Icon(Icons.check_circle, color: AppTheme.primary, size: 22),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showLogoutDialog(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    Color surfaceColor,
    Color textColor,
    Color secondaryText,
  ) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text('Log Out', style: TextStyle(color: textColor)),
        content: Text(
          'Are you sure you want to log out of your account?',
          style: TextStyle(color: secondaryText),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Log Out'),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authProvider.notifier).logout();
            },
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Glass Container Widget
// ---------------------------------------------------------------------------

class _GlassContainer extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final Color surfaceColor;

  const _GlassContainer({
    required this.child,
    required this.isDark,
    required this.surfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? surfaceColor.withValues(alpha: 0.55)
                : surfaceColor.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.04),
              width: 0.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section Header
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;

  const _SectionHeader({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Settings Tile
// ---------------------------------------------------------------------------

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final String title;
  final Color textColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconBgColor,
    required this.title,
    required this.textColor,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Icon with colored background
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}
