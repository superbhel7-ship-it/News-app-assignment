import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/article.dart';
import 'providers.dart';

class SearchState {
  final List<Article> results;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final String query;
  final int currentPage;
  final bool hasMore;
  final bool hasSearched;

  const SearchState({
    this.results = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.query = '',
    this.currentPage = 1,
    this.hasMore = true,
    this.hasSearched = false,
  });

  SearchState copyWith({
    List<Article>? results,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    String? query,
    int? currentPage,
    bool? hasMore,
    bool? hasSearched,
  }) {
    return SearchState(
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      query: query ?? this.query,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      hasSearched: hasSearched ?? this.hasSearched,
    );
  }
}

class SearchNotifier extends Notifier<SearchState> {
  Timer? _debounce;

  @override
  SearchState build() {
    ref.onDispose(() => _debounce?.cancel());
    return const SearchState();
  }

  void onQueryChanged(String query) {
    _debounce?.cancel();
    state = state.copyWith(query: query);

    if (query.trim().isEmpty) {
      state = const SearchState();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () {
      search(query);
    });
  }

  Future<void> search(String query) async {
    if (query.trim().isEmpty) return;

    state = state.copyWith(
      isLoading: true,
      error: null,
      query: query,
      hasSearched: true,
    );

    try {
      final results = await ref.read(newsRepositoryProvider).searchArticles(
            query: query,
            page: 1,
          );
      state = state.copyWith(
        results: results,
        isLoading: false,
        currentPage: 1,
        hasMore: results.length >= 20,
      );
    } on Failure catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Search failed');
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.query.isEmpty) return;

    state = state.copyWith(isLoadingMore: true);
    final nextPage = state.currentPage + 1;

    try {
      final results = await ref.read(newsRepositoryProvider).searchArticles(
            query: state.query,
            page: nextPage,
          );
      state = state.copyWith(
        results: [...state.results, ...results],
        isLoadingMore: false,
        currentPage: nextPage,
        hasMore: results.length >= 20,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  void clear() {
    _debounce?.cancel();
    state = const SearchState();
  }
}

final searchProvider = NotifierProvider<SearchNotifier, SearchState>(
  SearchNotifier.new,
);
