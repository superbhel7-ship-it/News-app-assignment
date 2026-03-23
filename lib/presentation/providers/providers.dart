import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/dio_client.dart';
import '../../data/datasources/local/auth_local_datasource.dart';
import '../../data/datasources/local/favorites_local_datasource.dart';
import '../../data/datasources/remote/news_remote_datasource.dart';
import '../../data/repositories/favorites_repository_impl.dart';
import '../../data/repositories/news_repository_impl.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../../domain/repositories/news_repository.dart';

// Core
final dioClientProvider = Provider((ref) => DioClient());

// Data Sources
final newsRemoteDataSourceProvider = Provider(
  (ref) => NewsRemoteDataSource(ref.read(dioClientProvider).dio),
);

final favoritesLocalDataSourceProvider = Provider(
  (ref) => FavoritesLocalDataSource(),
);

final authLocalDataSourceProvider = Provider(
  (ref) => AuthLocalDataSource(),
);

// Repositories
final newsRepositoryProvider = Provider<NewsRepository>(
  (ref) => NewsRepositoryImpl(ref.read(newsRemoteDataSourceProvider)),
);

final favoritesRepositoryProvider = Provider<FavoritesRepository>(
  (ref) => FavoritesRepositoryImpl(ref.read(favoritesLocalDataSourceProvider)),
);
