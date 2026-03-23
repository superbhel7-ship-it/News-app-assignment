import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/article_model.dart';

class FavoritesLocalDataSource {
  Box? _box;

  Future<Box> get box async {
    _box ??= await Hive.openBox(AppConstants.hiveBoxName);
    return _box!;
  }

  Future<List<ArticleModel>> getFavorites() async {
    try {
      final b = await box;
      final favorites = <ArticleModel>[];
      for (var key in b.keys) {
        final data = b.get(key);
        if (data != null) {
          favorites.add(ArticleModel.fromHive(Map<dynamic, dynamic>.from(data)));
        }
      }
      return favorites.reversed.toList();
    } catch (e) {
      throw CacheException('Failed to get favorites: $e');
    }
  }

  Future<void> addFavorite(String key, ArticleModel article) async {
    try {
      final b = await box;
      await b.put(key, article.toHiveMap());
    } catch (e) {
      throw CacheException('Failed to save favorite: $e');
    }
  }

  Future<void> removeFavorite(String key) async {
    try {
      final b = await box;
      await b.delete(key);
    } catch (e) {
      throw CacheException('Failed to remove favorite: $e');
    }
  }

  Future<bool> isFavorite(String key) async {
    try {
      final b = await box;
      return b.containsKey(key);
    } catch (e) {
      return false;
    }
  }
}
