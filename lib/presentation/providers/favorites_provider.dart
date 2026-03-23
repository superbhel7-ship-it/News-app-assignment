import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/article.dart';
import 'providers.dart';

class FavoritesState {
  final List<Article> favorites;
  final bool isLoading;
  final String? error;
  final Set<String> favoriteKeys;

  const FavoritesState({
    this.favorites = const [],
    this.isLoading = false,
    this.error,
    this.favoriteKeys = const {},
  });

  FavoritesState copyWith({
    List<Article>? favorites,
    bool? isLoading,
    String? error,
    Set<String>? favoriteKeys,
  }) {
    return FavoritesState(
      favorites: favorites ?? this.favorites,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      favoriteKeys: favoriteKeys ?? this.favoriteKeys,
    );
  }
}

class FavoritesNotifier extends Notifier<FavoritesState> {
  @override
  FavoritesState build() {
    loadFavorites();
    return const FavoritesState();
  }

  Future<void> loadFavorites() async {
    state = state.copyWith(isLoading: true);
    try {
      final favorites = await ref.read(favoritesRepositoryProvider).getFavorites();
      final keys = favorites.map((a) => a.uniqueKey).toSet();
      state = state.copyWith(
        favorites: favorites,
        isLoading: false,
        favoriteKeys: keys,
      );
    } on Failure catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> toggleFavorite(Article article) async {
    final key = article.uniqueKey;
    final repo = ref.read(favoritesRepositoryProvider);

    if (state.favoriteKeys.contains(key)) {
      await repo.removeFavorite(key);
      state = state.copyWith(
        favorites: state.favorites.where((a) => a.uniqueKey != key).toList(),
        favoriteKeys: {...state.favoriteKeys}..remove(key),
      );
    } else {
      await repo.addFavorite(article);
      state = state.copyWith(
        favorites: [article, ...state.favorites],
        favoriteKeys: {...state.favoriteKeys, key},
      );
    }
  }

  bool isFavorite(Article article) {
    return state.favoriteKeys.contains(article.uniqueKey);
  }
}

final favoritesProvider = NotifierProvider<FavoritesNotifier, FavoritesState>(
  FavoritesNotifier.new,
);
