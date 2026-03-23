import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/article.dart';
import 'providers.dart';

/// Time range options for filtering news freshness.
enum TimeRange {
  latest(1, 'Latest'),
  oneHour(1, '1h'),
  fourHours(4, '4h'),
  eightHours(8, '8h'),
  twentyFourHours(24, '24h');

  final int hours;
  final String label;
  const TimeRange(this.hours, this.label);
}

class NewsState {
  final List<Article> articles;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final bool hasMore;
  final String selectedCategory;
  final TimeRange timeRange;
  final DateTime? lastFetchedAt;

  const NewsState({
    this.articles = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 1,
    this.hasMore = true,
    this.selectedCategory = 'general',
    this.timeRange = TimeRange.twentyFourHours,
    this.lastFetchedAt,
  });

  NewsState copyWith({
    List<Article>? articles,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    bool? hasMore,
    String? selectedCategory,
    TimeRange? timeRange,
    DateTime? lastFetchedAt,
  }) {
    return NewsState(
      articles: articles ?? this.articles,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      timeRange: timeRange ?? this.timeRange,
      lastFetchedAt: lastFetchedAt ?? this.lastFetchedAt,
    );
  }
}

class NewsNotifier extends Notifier<NewsState> {
  @override
  NewsState build() {
    Future.microtask(() => fetchNews());
    return const NewsState();
  }

  Future<void> fetchNews({bool refresh = false}) async {
    if (state.isLoading) return;

    state = state.copyWith(
      isLoading: true,
      error: null,
      currentPage: refresh ? 1 : state.currentPage,
      articles: refresh ? [] : state.articles,
    );

    try {
      final articles = await ref.read(newsRepositoryProvider).getTopHeadlines(
            category: state.selectedCategory,
            page: 1,
            hoursAgo: state.timeRange.hours,
          );
      state = state.copyWith(
        articles: articles,
        isLoading: false,
        currentPage: 1,
        hasMore: articles.length >= 20,
        lastFetchedAt: DateTime.now(),
      );
    } on Failure catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Something went wrong');
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) return;

    state = state.copyWith(isLoadingMore: true);
    final nextPage = state.currentPage + 1;

    try {
      final articles = await ref.read(newsRepositoryProvider).getTopHeadlines(
            category: state.selectedCategory,
            page: nextPage,
            hoursAgo: state.timeRange.hours,
          );
      state = state.copyWith(
        articles: [...state.articles, ...articles],
        isLoadingMore: false,
        currentPage: nextPage,
        hasMore: articles.length >= 20,
      );
    } on Failure catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.message);
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  void changeCategory(String category) {
    if (category == state.selectedCategory) return;
    state = state.copyWith(selectedCategory: category);
    fetchNews(refresh: true);
  }

  void changeTimeRange(TimeRange range) {
    if (range == state.timeRange) return;
    state = state.copyWith(timeRange: range);
    fetchNews(refresh: true);
  }
}

final newsProvider = NotifierProvider<NewsNotifier, NewsState>(
  NewsNotifier.new,
);

// ─── Separate provider for Web Stories (fetches from entertainment category) ───
class WebStoriesNotifier extends Notifier<List<Article>> {
  @override
  List<Article> build() {
    _fetch();
    return [];
  }

  Future<void> _fetch() async {
    try {
      final articles = await ref.read(newsRepositoryProvider).getTopHeadlines(
            category: 'entertainment',
            page: 1,
          );
      state = articles.take(10).toList();
    } catch (_) {
      // Silently fail — stories are optional
    }
  }

  Future<void> refresh() async => _fetch();
}

final webStoriesProvider = NotifierProvider<WebStoriesNotifier, List<Article>>(
  WebStoriesNotifier.new,
);

// ─── Separate provider for WORLD news (crypto, global, international) ───
class WorldNewsNotifier extends Notifier<List<Article>> {
  @override
  List<Article> build() {
    _fetch();
    return [];
  }

  Future<void> _fetch() async {
    try {
      final articles =
          await ref.read(newsRepositoryProvider).getWorldNews(page: 1);
      state = articles;
    } catch (_) {
      // Silent fail — world section is supplementary
    }
  }

  Future<void> refresh() async => _fetch();
}

final worldNewsProvider = NotifierProvider<WorldNewsNotifier, List<Article>>(
  WorldNewsNotifier.new,
);
