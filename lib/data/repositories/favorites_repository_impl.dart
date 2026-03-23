import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/article.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/local/favorites_local_datasource.dart';
import '../models/article_model.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesLocalDataSource _localDataSource;

  FavoritesRepositoryImpl(this._localDataSource);

  @override
  Future<List<Article>> getFavorites() async {
    try {
      return await _localDataSource.getFavorites();
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    }
  }

  @override
  Future<void> addFavorite(Article article) async {
    try {
      final model = ArticleModel.fromEntity(article);
      await _localDataSource.addFavorite(article.uniqueKey, model);
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    }
  }

  @override
  Future<void> removeFavorite(String key) async {
    try {
      await _localDataSource.removeFavorite(key);
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    }
  }

  @override
  Future<bool> isFavorite(String key) async {
    return await _localDataSource.isFavorite(key);
  }
}
