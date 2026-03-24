import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../domain/entities/article.dart';
import '../../providers/news_provider.dart';
import '../../widgets/market_ticker.dart';
import '../../widgets/network_image.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/trending_card.dart';
import '../../widgets/world_article_card.dart';
import '../../widgets/topic_chip.dart';
import '../article_detail/article_detail_screen.dart';
import '../search/search_screen.dart';
import 'notifications_screen.dart';
import 'see_all_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsState = ref.watch(newsProvider);
    final webStories = ref.watch(webStoriesProvider);
    final worldNews = ref.watch(worldNewsProvider);
    final hotNewsArticles = newsState.articles;
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // ─── PINNED HEADER (does NOT scroll away) ───
            SliverAppBar(
              pinned: true,
              floating: false,
              backgroundColor: c.background,
              surfaceTintColor: Colors.transparent,
              toolbarHeight: 56,
              title: Row(
                children: [
                  // Menu icon (hamburger)
                  GestureDetector(
                    onTap: () => _showMenuSheet(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: c.surface,
                        border: Border.all(color: c.divider, width: 0.5),
                      ),
                      child: Icon(Icons.menu, size: 18, color: c.textSecondary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Search bar
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SearchScreen()),
                        );
                      },
                      child: Container(
                        height: 38,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: c.surface,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search, size: 18, color: c.textSecondary),
                            const SizedBox(width: 8),
                            Text(
                              'Search',
                              style: TextStyle(
                                color: c.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Notification bell
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const NotificationsScreen()),
                      );
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: c.surface,
                        border: Border.all(color: c.divider, width: 0.5),
                      ),
                      child: Icon(Icons.notifications_outlined,
                          size: 18, color: c.textPrimary),
                    ),
                  ),
                ],
              ),
              // Category tabs
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(44),
                child: _CategoryTabs(
                  selected: newsState.selectedCategory,
                  onChanged: (cat) =>
                      ref.read(newsProvider.notifier).changeCategory(cat),
                ),
              ),
            ),
          ];
        },
        body: RefreshIndicator(
          onRefresh: () async {
            await ref.read(newsProvider.notifier).fetchNews(refresh: true);
            ref.read(webStoriesProvider.notifier).refresh();
            ref.read(worldNewsProvider.notifier).refresh();
          },
          color: c.primary,
          backgroundColor: c.surface,
          child: newsState.isLoading && newsState.articles.isEmpty
              ? const ShimmerLoading()
              : newsState.error != null && newsState.articles.isEmpty
                  ? ErrorView(
                      message: newsState.error!,
                      onRetry: () => ref
                          .read(newsProvider.notifier)
                          .fetchNews(refresh: true),
                    )
                  : ListView(
                      padding: EdgeInsets.zero,
                      children: [

                        // ─── Market Ticker ───
                        const Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: MarketTicker(),
                        ),

                        // ─── Hot News Header ───
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hot News',
                                    style: TextStyle(
                                      color: c.textPrimary,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    newsState.lastFetchedAt != null
                                        ? 'Updated, ${DateFormatter.timeAgo(newsState.lastFetchedAt!.toIso8601String())}'
                                        : 'Updating...',
                                    style: TextStyle(
                                      color: c.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                DateFormatter.todayFormatted(),
                                style: TextStyle(
                                  color: c.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ─── Trending Horizontal Cards ───
                        if (hotNewsArticles.isNotEmpty)
                          SizedBox(
                            height: 280,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              itemCount:
                                  hotNewsArticles.length > 5 ? 5 : hotNewsArticles.length,
                              itemBuilder: (context, index) {
                                final article = hotNewsArticles[index];
                                return TrendingCard(
                                  article: article,
                                  trendingIndex: index,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ArticleDetailScreen(
                                          article: article),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                        // ─── Topics Section (horizontal scroll carousel) ───
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
                          child: Text(
                            'Topics',
                            style: TextStyle(
                              color: c.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 38,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            children: const [
                              TopicChip('#Cricket'),
                              SizedBox(width: 8),
                              TopicChip('#Stocks'),
                              SizedBox(width: 8),
                              TopicChip('#Bollywood'),
                              SizedBox(width: 8),
                              TopicChip('#Technology'),
                              SizedBox(width: 8),
                              TopicChip('#IPL'),
                              SizedBox(width: 8),
                              TopicChip('#Politics'),
                              SizedBox(width: 8),
                              TopicChip('#Startup'),
                              SizedBox(width: 8),
                              TopicChip('#AI'),
                              SizedBox(width: 8),
                              TopicChip('#Crypto'),
                              SizedBox(width: 8),
                              TopicChip('#Election'),
                            ],
                          ),
                        ),

                        // ─── World Section Header ───
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'World',
                                style: TextStyle(
                                  color: c.textPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const SeeAllScreen(
                                          title: 'World News'),
                                    ),
                                  );
                                },
                                child: Text(
                                  'See all',
                                  style: TextStyle(
                                    color: c.primary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ─── World Articles (from worldNewsProvider — crypto, global) ───
                        if (worldNews.isEmpty)
                          const EmptySection(message: 'No world news available right now'),
                        if (worldNews.isNotEmpty)
                          ...worldNews
                              .take(6)
                              .map((article) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: WorldArticleCard(
                                      article: article,
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ArticleDetailScreen(
                                              article: article),
                                        ),
                                      ),
                                    ),
                                  )),

                        // See More button
                        if (worldNews.length > 5)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SeeAllScreen(
                                        title: 'Latest News'),
                                  ),
                                );
                              },
                              child: const Text('See More',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w600)),
                            ),
                          ),

                        const SizedBox(height: 90),
                      ],
                    ),
        ),
      ),
    );
  }

  void _showMenuSheet(BuildContext context) {
    final c = context.colors;
    showModalBottomSheet(
      context: context,
      backgroundColor: c.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: c.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            _menuItem(context, Icons.trending_up, 'Trending Now'),
            _menuItem(context, Icons.location_on_outlined, 'Local News'),
            _menuItem(context, Icons.video_library_outlined, 'Videos'),
            _menuItem(context, Icons.settings_outlined, 'Settings'),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(BuildContext context, IconData icon, String label) {
    final c = context.colors;
    return ListTile(
      leading: Icon(icon, color: c.textSecondary),
      title: Text(label,
          style: TextStyle(color: c.textPrimary, fontSize: 15)),
      onTap: () => Navigator.pop(context),
    );
  }
}

// ─── Time Range Filter ───
class _TimeRangeFilter extends StatelessWidget {
  final TimeRange selected;
  final ValueChanged<TimeRange> onChanged;

  const _TimeRangeFilter({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        children: TimeRange.values.map((range) {
          final isActive = range == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onChanged(range),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppTheme.primary
                      : c.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isActive
                        ? AppTheme.primary
                        : c.divider.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (range == TimeRange.latest)
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isActive ? Colors.white : Colors.green,
                          ),
                        ),
                      ),
                    Text(
                      range.label,
                      style: TextStyle(
                        color: isActive ? Colors.white : c.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Category Tabs ───
class _CategoryTabs extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _CategoryTabs({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      height: 44,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: c.divider, width: 0.3),
        ),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: ApiConstants.categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 4),
        itemBuilder: (context, index) {
          final cat = ApiConstants.categories[index];
          final isSelected = cat == selected;
          final label = ApiConstants.categoryLabels[cat] ?? cat;
          return GestureDetector(
            onTap: () => onChanged(cat),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected ? c.primary : Colors.transparent,
                    width: 2.5,
                  ),
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? c.textPrimary : c.textSecondary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Google Web Stories Header ───
class _WebStoriesHeader extends StatelessWidget {
  final AppColors c;
  const _WebStoriesHeader({required this.c});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF4285F4),
                  Color(0xFF34A853),
                  Color(0xFFFBBC05),
                  Color(0xFFEA4335)
                ],
              ),
            ),
            child: const Center(
              child: Text('G',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Web Stories',
            style: TextStyle(
              color: c.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Icon(Icons.chevron_right, size: 20, color: c.textSecondary),
        ],
      ),
    );
  }
}

// ─── Google Web Stories Bar ───
class _WebStoriesBar extends StatelessWidget {
  final List<Article> articles;
  final void Function(Article) onTap;

  const _WebStoriesBar({required this.articles, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // Skip first 5 articles (used by trending) so stories show DIFFERENT content
    final storyArticles = articles
        .where((a) => a.urlToImage != null)
        .skip(5)
        .take(8)
        .toList();
    if (storyArticles.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: storyArticles.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final article = storyArticles[i];
          return GestureDetector(
            onTap: () => onTap(article),
            child: Container(
              width: 110,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppNetworkImage(
                      imageUrl: article.urlToImage!,
                      fit: BoxFit.cover,
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                          stops: const [0.4, 1.0],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        width: 28,
                        height: 28,
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: AppTheme.primary, width: 2),
                        ),
                        child: CircleAvatar(
                          backgroundColor: c.surface,
                          child: Text(
                            (article.sourceName ?? 'N')[0].toUpperCase(),
                            style: const TextStyle(
                              color: AppTheme.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 8,
                      right: 8,
                      bottom: 10,
                      child: Text(
                        article.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
