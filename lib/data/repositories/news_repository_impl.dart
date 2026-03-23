import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/article.dart';
import '../../domain/repositories/news_repository.dart';
import '../datasources/remote/news_remote_datasource.dart';

class NewsRepositoryImpl implements NewsRepository {
  final NewsRemoteDataSource _remoteDataSource;

  NewsRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Article>> getTopHeadlines({
    required String category,
    required int page,
    int hoursAgo = 12,
  }) async {
    try {
      return await _remoteDataSource.getTopHeadlines(
        category: category,
        page: page,
        hoursAgo: hoursAgo,
      );
    } on NetworkException {
      throw const NetworkFailure();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<List<Article>> getWorldNews({required int page}) async {
    try {
      return await _remoteDataSource.getWorldNews(page: page);
    } on NetworkException {
      throw const NetworkFailure();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<List<Article>> searchArticles({
    required String query,
    required int page,
  }) async {
    try {
      return await _remoteDataSource.searchArticles(
        query: query,
        page: page,
      );
    } on NetworkException {
      throw const NetworkFailure();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }
}
