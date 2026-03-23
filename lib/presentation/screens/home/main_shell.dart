import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_colors.dart';
import '../account/account_screen.dart';
import '../favorites/favorites_screen.dart';
import '../live/live_tv_screen.dart';
import '../search/search_screen.dart';
import '../../providers/news_provider.dart';
import 'home_screen.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;

  final _screens = const [
    HomeScreen(),
    SearchScreen(),
    LiveTvScreen(),
    FavoritesScreen(),
    AccountScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Auto-refresh ALL sections when user logs in / app opens
    Future.microtask(() {
      ref.read(newsProvider.notifier).fetchNews(refresh: true);
      ref.read(webStoriesProvider.notifier).refresh();
      ref.read(worldNewsProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      extendBody: true,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: c.isDark
                ? const Color(0xFF1C2128)
                : Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: c.divider.withValues(alpha: 0.3),
              width: 0.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _TabItem(
                  icon: CupertinoIcons.house,
                  activeIcon: CupertinoIcons.house_fill,
                  label: 'Home',
                  isSelected: _currentIndex == 0,
                  c: c,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
                _TabItem(
                  icon: CupertinoIcons.search,
                  activeIcon: CupertinoIcons.search,
                  label: 'Search',
                  isSelected: _currentIndex == 1,
                  c: c,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
                _TabItem(
                  icon: CupertinoIcons.tv,
                  activeIcon: CupertinoIcons.tv_fill,
                  label: 'Live TV',
                  isSelected: _currentIndex == 2,
                  c: c,
                  onTap: () => setState(() => _currentIndex = 2),
                ),
                _TabItem(
                  icon: CupertinoIcons.bookmark,
                  activeIcon: CupertinoIcons.bookmark_fill,
                  label: 'Saved',
                  isSelected: _currentIndex == 3,
                  c: c,
                  onTap: () => setState(() => _currentIndex = 3),
                ),
                _TabItem(
                  icon: CupertinoIcons.person,
                  activeIcon: CupertinoIcons.person_fill,
                  label: 'Account',
                  isSelected: _currentIndex == 4,
                  c: c,
                  onTap: () => setState(() => _currentIndex = 4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final AppColors c;
  final VoidCallback onTap;

  const _TabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.c,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? activeIcon : icon,
                size: 24,
                color: isSelected ? AppTheme.primary : c.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.primary : c.textSecondary,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
