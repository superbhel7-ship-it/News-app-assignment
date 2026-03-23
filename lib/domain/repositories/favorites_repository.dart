import '../entities/article.dart';

abstract class FavoritesRepository {
  Future<List<Article>> getFavorites();
  Future<void> addFavorite(Article article);
  Future<void> removeFavorite(String key);
  Future<bool> isFavorite(String key);
}
