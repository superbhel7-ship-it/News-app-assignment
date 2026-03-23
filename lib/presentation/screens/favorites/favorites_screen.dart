import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/favorites_provider.dart';
import '../../widgets/article_card.dart';
import '../article_detail/article_detail_screen.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final favState = ref.watch(favoritesProvider);

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'Bookmarks',
          style: TextStyle(
            color: c.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_horiz, color: c.textSecondary),
            color: c.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              if (value == 'clear_all' && favState.favorites.isNotEmpty) {
                _showClearAllDialog(context, ref, c);
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep_outlined,
                        color: AppTheme.errorColor, size: 20),
                    const SizedBox(width: 10),
                    Text('Clear All',
                        style: TextStyle(
                            color: AppTheme.errorColor, fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: favState.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            )
          : favState.favorites.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.bookmark,
                        size: 64,
                        color: c.textSecondary.withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No saved articles yet',
                        style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Bookmark articles to read them later',
                        style: TextStyle(
                          color: c.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () =>
                      ref.read(favoritesProvider.notifier).loadFavorites(),
                  color: AppTheme.primary,
                  backgroundColor: c.surface,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: favState.favorites.length,
                    itemBuilder: (context, index) {
                      final article = favState.favorites[index];
                      return Stack(
                        children: [
                          Dismissible(
                            key: Key(article.uniqueKey),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color:
                                    AppTheme.errorColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                CupertinoIcons.delete,
                                color: AppTheme.errorColor,
                                size: 24,
                              ),
                            ),
                            onDismissed: (_) {
                              ref
                                  .read(favoritesProvider.notifier)
                                  .toggleFavorite(article);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      const Text('Removed from bookmarks'),
                                  duration: const Duration(seconds: 2),
                                  backgroundColor: c.surface,
                                  behavior: SnackBarBehavior.floating,
                                  action: SnackBarAction(
                                    label: 'Undo',
                                    textColor: AppTheme.primary,
                                    onPressed: () {
                                      ref
                                          .read(favoritesProvider.notifier)
                                          .toggleFavorite(article);
                                    },
                                  ),
                                ),
                              );
                            },
                            child: ArticleCardCompact(
                              article: article,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ArticleDetailScreen(article: article),
                                ),
                              ),
                            ),
                          ),
                          // Remove bookmark icon (top-right of card)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () {
                                ref
                                    .read(favoritesProvider.notifier)
                                    .toggleFavorite(article);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        const Text('Removed from bookmarks'),
                                    duration: const Duration(seconds: 2),
                                    backgroundColor: c.surface,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color:
                                      Colors.black.withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  CupertinoIcons.bookmark_fill,
                                  color: AppTheme.primary,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
    );
  }

  void _showClearAllDialog(BuildContext context, WidgetRef ref, AppColors c) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text('Clear All Bookmarks',
            style: TextStyle(color: c.textPrimary)),
        content: Text('Are you sure you want to remove all saved articles?',
            style: TextStyle(color: c.textSecondary)),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Clear All'),
            onPressed: () {
              final favs =
                  ref.read(favoritesProvider).favorites.toList();
              for (final a in favs) {
                ref.read(favoritesProvider.notifier).toggleFavorite(a);
              }
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }
}
