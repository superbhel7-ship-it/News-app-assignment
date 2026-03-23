import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_colors.dart';
import '../../providers/search_provider.dart';
import '../../widgets/article_card.dart';
import '../../widgets/shimmer_loading.dart';
import '../article_detail/article_detail_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final searchState = ref.watch(searchProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        backgroundColor: c.background,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              style: TextStyle(color: c.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search articles...',
                prefixIcon: Icon(Icons.search, color: c.textSecondary),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear,
                            color: c.textSecondary),
                        onPressed: () {
                          _controller.clear();
                          ref.read(searchProvider.notifier).clear();
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: c.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (query) {
                setState(() {});
                ref.read(searchProvider.notifier).onQueryChanged(query);
              },
              onSubmitted: (query) {
                ref.read(searchProvider.notifier).search(query);
              },
            ),
          ),

          // Topic chips
          if (!searchState.hasSearched)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Topics',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      '#iPhone',
                      '#Stocks',
                      '#Farel',
                      '#Macbook',
                      '#Bullying',
                      '#Technology',
                      '#Science',
                      '#Bitcoin',
                    ]
                        .map((tag) => GestureDetector(
                              onTap: () {
                                final query = tag.replaceAll('#', '');
                                _controller.text = query;
                                ref
                                    .read(searchProvider.notifier)
                                    .search(query);
                                setState(() {});
                              },
                              child: Chip(
                                label: Text(tag),
                                backgroundColor: c.surface,
                                side: BorderSide(
                                    color: c.divider),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),

          // Results
          Expanded(
            child: searchState.isLoading
                ? const ShimmerCompactLoading()
                : searchState.error != null
                    ? ErrorView(
                        message: searchState.error!,
                        onRetry: () => ref
                            .read(searchProvider.notifier)
                            .search(searchState.query),
                      )
                    : searchState.hasSearched && searchState.results.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off,
                                    size: 64, color: c.textSecondary),
                                const SizedBox(height: 16),
                                Text(
                                  'No articles found',
                                  style: TextStyle(
                                    color: c.textSecondary,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : NotificationListener<ScrollNotification>(
                            onNotification: (notification) {
                              if (notification is ScrollEndNotification &&
                                  notification.metrics.extentAfter < 300) {
                                ref.read(searchProvider.notifier).loadMore();
                              }
                              return false;
                            },
                            child: ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: searchState.results.length +
                                  (searchState.isLoadingMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == searchState.results.length) {
                                  return const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: AppTheme.primary,
                                      ),
                                    ),
                                  );
                                }
                                final article = searchState.results[index];
                                return ArticleCardCompact(
                                  article: article,
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
          ),
        ],
      ),
    );
  }
}
