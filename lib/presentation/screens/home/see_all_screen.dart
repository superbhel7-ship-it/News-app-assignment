import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_colors.dart';
import '../../providers/news_provider.dart';
import '../../widgets/world_article_card.dart';
import '../../widgets/shimmer_loading.dart';
import '../article_detail/article_detail_screen.dart';

class SeeAllScreen extends ConsumerStatefulWidget {
  final String title;
  const SeeAllScreen({super.key, this.title = 'Latest News'});

  @override
  ConsumerState<SeeAllScreen> createState() => _SeeAllScreenState();
}

class _SeeAllScreenState extends ConsumerState<SeeAllScreen> {
  String _selectedFilter = 'Latest';
  final _filters = ['Latest', 'Trending', 'Today', 'This Week'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(newsProvider.notifier);
      final state = ref.read(newsProvider);
      if (state.articles.isEmpty && !state.isLoading) {
        notifier.fetchNews(refresh: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final newsState = ref.watch(newsProvider);
    final currentCategory = newsState.selectedCategory;

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: c.textPrimary,
        title: Text(
          widget.title,
          style: TextStyle(
            color: c.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _CategoryDropdown(
              currentCategory: currentCategory,
              onChanged: (cat) {
                if (cat != null) {
                  ref.read(newsProvider.notifier).changeCategory(cat);
                }
              },
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              itemCount: ApiConstants.categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = ApiConstants.categories[index];
                final label =
                    ApiConstants.categoryLabels[category] ?? category;
                final isSelected = category == currentCategory;
                return GestureDetector(
                  onTap: () =>
                      ref.read(newsProvider.notifier).changeCategory(category),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primary : c.surface,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: isSelected ? AppTheme.primary : c.divider,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        label,
                        style: TextStyle(
                          color: isSelected ? Colors.white : c.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // --- Filters ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final f = _filters[i];
                  final isSelected = f == _selectedFilter;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = f),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? AppTheme.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppTheme.primary : c.divider,
                          width: 0.8,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          f,
                          style: TextStyle(
                            color: isSelected ? Colors.white : c.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 4),

          // --- Articles list ---
          Expanded(
            child: newsState.isLoading
                ? const ShimmerCompactLoading()
                : newsState.error != null
                    ? ErrorView(
                        message: newsState.error!,
                        onRetry: () => ref
                            .read(newsProvider.notifier)
                            .fetchNews(refresh: true),
                      )
                    : RefreshIndicator(
                        onRefresh: () => ref
                            .read(newsProvider.notifier)
                            .fetchNews(refresh: true),
                        color: AppTheme.primary,
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (n) {
                            if (n is ScrollEndNotification &&
                                n.metrics.extentAfter < 300) {
                              ref.read(newsProvider.notifier).loadMore();
                            }
                            return false;
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: newsState.articles.length +
                                (newsState.isLoadingMore ? 1 : 0),
                            itemBuilder: (_, i) {
                              if (i == newsState.articles.length) {
                                return const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                        color: AppTheme.primary,
                                        strokeWidth: 2),
                                  ),
                                );
                              }
                              final article = newsState.articles[i];
                              return WorldArticleCard(
                                article: article,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ArticleDetailScreen(article: article),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _CategoryDropdown extends StatelessWidget {
  final String currentCategory;
  final ValueChanged<String?> onChanged;

  const _CategoryDropdown({
    required this.currentCategory,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.divider, width: 0.8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentCategory,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: c.textSecondary,
            size: 18,
          ),
          dropdownColor: c.surface,
          borderRadius: BorderRadius.circular(12),
          style: TextStyle(
            color: c.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          selectedItemBuilder: (_) {
            return ApiConstants.categories.map((cat) {
              return Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  ApiConstants.categoryLabels[cat] ?? cat,
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList();
          },
          items: ApiConstants.categories.map((cat) {
            final label = ApiConstants.categoryLabels[cat] ?? cat;
            final isSelected = cat == currentCategory;
            return DropdownMenuItem(
              value: cat,
              child: Row(
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? AppTheme.primary : c.textPrimary,
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.check,
                      color: AppTheme.primary,
                      size: 16,
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
