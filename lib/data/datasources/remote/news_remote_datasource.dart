import 'package:dio/dio.dart';
import 'package:xml/xml.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/article_model.dart';

/// Hybrid news source: NewsAPI (primary) + Google News RSS (fallback).
/// When NewsAPI rate-limits or fails, automatically falls back to Google RSS.
class NewsRemoteDataSource {
  final Dio _dio;

  NewsRemoteDataSource(this._dio);

  // ─── NewsAPI config ───
  static const String _newsApiBase = 'https://newsapi.org/v2';
  static const String _apiKey = 'f862b816d51445708056a40e37507da0';

  // ─── Google News RSS config (free, unlimited) ───
  static const String _rssBase = 'https://news.google.com/rss';

  static const Map<String, String> _categoryQueries = {
    'general': 'India news today',
    'business': 'India business stocks market',
    'technology': 'India technology startup',
    'science': 'India science ISRO',
    'health': 'India health medical',
    'sports': 'India cricket IPL sports',
    'entertainment': 'India Bollywood entertainment',
  };

  static const Map<String, String> _rssCategoryTopics = {
    'general': '',
    'business': 'BUSINESS',
    'technology': 'TECHNOLOGY',
    'science': 'SCIENCE',
    'health': 'HEALTH',
    'sports': 'SPORTS',
    'entertainment': 'ENTERTAINMENT',
  };

  // ────────────────────────────────────────────
  //  PUBLIC API
  // ────────────────────────────────────────────

  Future<List<ArticleModel>> getTopHeadlines({
    required String category,
    required int page,
    int hoursAgo = 12,
  }) async {
    try {
      // Try NewsAPI first
      return await _newsApiHeadlines(category, page, hoursAgo);
    } catch (_) {
      // Fallback to Google News RSS
      try {
        return await _rssHeadlines(category, page, hoursAgo);
      } on DioException catch (e) {
        if (e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.connectionTimeout) {
          throw const NetworkException();
        }
        throw ServerException(e.message ?? 'Failed to fetch headlines');
      } catch (e) {
        if (e is NetworkException || e is ServerException) rethrow;
        throw ServerException('Failed to fetch headlines');
      }
    }
  }

  Future<List<ArticleModel>> getWorldNews({required int page}) async {
    // Try NewsAPI first
    try {
      final articles = await _newsApiWorldNews(page);
      if (articles.isNotEmpty) return articles;
    } catch (_) {
      // Fall through to RSS
    }

    // Fallback: Google News RSS (US feed for world news)
    try {
      return await _rssWorldNews(page);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        throw const NetworkException();
      }
      throw ServerException(e.message ?? 'Failed to fetch world news');
    } catch (e) {
      if (e is NetworkException || e is ServerException) rethrow;
      throw ServerException('Failed to fetch world news');
    }
  }

  Future<List<ArticleModel>> searchArticles({
    required String query,
    required int page,
  }) async {
    try {
      return await _newsApiSearch(query, page);
    } catch (_) {
      try {
        return await _rssSearch(query, page);
      } on DioException catch (e) {
        if (e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.connectionTimeout) {
          throw const NetworkException();
        }
        throw ServerException(e.message ?? 'Failed to search articles');
      } catch (e) {
        if (e is NetworkException || e is ServerException) rethrow;
        throw ServerException('Failed to search articles');
      }
    }
  }

  // ────────────────────────────────────────────
  //  NEWSAPI (PRIMARY)
  // ────────────────────────────────────────────

  String _fromDate(int hoursAgo) {
    final dt = DateTime.now().toUtc().subtract(Duration(hours: hoursAgo));
    return dt.toIso8601String();
  }

  Future<List<ArticleModel>> _newsApiHeadlines(
      String category, int page, int hoursAgo) async {
    final query = _categoryQueries[category] ?? _categoryQueries['general']!;
    final response = await _dio.get(
      '$_newsApiBase/everything',
      queryParameters: {
        'q': query,
        'from': _fromDate(hoursAgo),
        'sortBy': 'publishedAt',
        'language': 'en',
        'pageSize': 20,
        'page': page,
        'apiKey': _apiKey,
      },
    );
    final articles = _parseNewsApi(response);

    // If too few, widen the window
    if (articles.length < 5 && page == 1) {
      final wider = hoursAgo < 24 ? 48 : 72;
      final fallback = await _dio.get(
        '$_newsApiBase/everything',
        queryParameters: {
          'q': query,
          'from': _fromDate(wider),
          'sortBy': 'publishedAt',
          'language': 'en',
          'pageSize': 20,
          'page': page,
          'apiKey': _apiKey,
        },
      );
      return _parseNewsApi(fallback);
    }
    return articles;
  }

  Future<List<ArticleModel>> _newsApiWorldNews(int page) async {
    final response = await _dio.get(
      '$_newsApiBase/everything',
      queryParameters: {
        'q': 'world OR international OR global OR US OR Europe OR China',
        'from': _fromDate(24),
        'sortBy': 'publishedAt',
        'language': 'en',
        'pageSize': 20,
        'page': page,
        'apiKey': _apiKey,
      },
    );
    final articles = _parseNewsApi(response);
    // If NewsAPI returns empty, throw to trigger RSS fallback
    if (articles.isEmpty && page == 1) {
      throw ServerException('No world news from NewsAPI');
    }
    return articles;
  }

  Future<List<ArticleModel>> _newsApiSearch(String query, int page) async {
    final response = await _dio.get(
      '$_newsApiBase/everything',
      queryParameters: {
        'q': query,
        'from': _fromDate(6),
        'sortBy': 'publishedAt',
        'language': 'en',
        'pageSize': 20,
        'page': page,
        'apiKey': _apiKey,
      },
    );
    final articles = _parseNewsApi(response);
    if (articles.length < 5 && page == 1) {
      final fallback = await _dio.get(
        '$_newsApiBase/everything',
        queryParameters: {
          'q': query,
          'from': _fromDate(24),
          'sortBy': 'publishedAt',
          'language': 'en',
          'pageSize': 20,
          'page': page,
          'apiKey': _apiKey,
        },
      );
      return _parseNewsApi(fallback);
    }
    return articles;
  }

  /// Parse NewsAPI JSON response — keep ALL articles (with or without images).
  List<ArticleModel> _parseNewsApi(Response response) {
    if (response.statusCode != 200 || response.data == null) {
      throw ServerException('Invalid response from NewsAPI');
    }

    final data = response.data as Map<String, dynamic>;

    // Check for rate limit or error
    if (data['status'] == 'error') {
      throw ServerException(data['message'] ?? 'NewsAPI error');
    }

    final articles = data['articles'] as List<dynamic>? ?? [];

    return articles
        .where((item) {
          final title = item['title'] as String?;
          return title != null && title != '[Removed]';
        })
        .map((item) => ArticleModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // ────────────────────────────────────────────
  //  GOOGLE NEWS RSS (FALLBACK — free, unlimited)
  // ────────────────────────────────────────────

  Future<List<ArticleModel>> _rssHeadlines(
      String category, int page, int hoursAgo) async {
    List<ArticleModel> articles;

    if (category == 'general') {
      articles = await _fetchRss('$_rssBase?hl=en-IN&gl=IN&ceid=IN:en');
    } else {
      // Try search query first, fallback to main feed
      try {
        final query = Uri.encodeComponent(
            _categoryQueries[category] ?? 'India news');
        articles = await _fetchRss(
            '$_rssBase/search?q=$query&hl=en-IN&gl=IN&ceid=IN:en');
      } catch (_) {
        // If search also fails (403), use main feed
        articles = await _fetchRss('$_rssBase?hl=en-IN&gl=IN&ceid=IN:en');
      }
    }

    // Time filter
    final cutoff = DateTime.now().toUtc().subtract(Duration(hours: hoursAgo));
    final filtered = articles.where((a) {
      if (a.publishedAt == null) return true;
      final pubDate = _parseDate(a.publishedAt!);
      return pubDate == null || pubDate.isAfter(cutoff);
    }).toList();

    final source = filtered.length < 5 ? articles : filtered;
    final start = (page - 1) * 20;
    if (start >= source.length) return [];
    return source.skip(start).take(20).toList();
  }

  Future<List<ArticleModel>> _rssWorldNews(int page) async {
    List<ArticleModel> articles;
    try {
      // Try US feed for world news
      articles = await _fetchRss('$_rssBase?hl=en&gl=US&ceid=US:en');
    } catch (_) {
      // If US feed fails, use India feed (same articles better than nothing)
      articles = await _fetchRss('$_rssBase?hl=en-IN&gl=IN&ceid=IN:en');
    }
    final start = (page - 1) * 20;
    if (start >= articles.length) return [];
    return articles.skip(start).take(20).toList();
  }

  Future<List<ArticleModel>> _rssSearch(String query, int page) async {
    List<ArticleModel> articles;
    try {
      final encoded = Uri.encodeComponent(query);
      final url = '$_rssBase/search?q=$encoded&hl=en-IN&gl=IN&ceid=IN:en';
      articles = await _fetchRss(url);
    } catch (_) {
      // If search 403s, return main feed
      articles = await _fetchRss('$_rssBase?hl=en-IN&gl=IN&ceid=IN:en');
    }
    final start = (page - 1) * 20;
    if (start >= articles.length) return [];
    return articles.skip(start).take(20).toList();
  }

  /// Fetch and parse a Google News RSS feed.
  Future<List<ArticleModel>> _fetchRss(String url) async {
    final response = await _dio.get(
      url,
      options: Options(responseType: ResponseType.plain),
    );

    if (response.statusCode != 200 || response.data == null) {
      throw ServerException('Invalid RSS response');
    }

    final xml = XmlDocument.parse(response.data as String);
    final items = xml.findAllElements('item');
    final results = <ArticleModel>[];

    for (final item in items) {
      final rawTitle = item.getElement('title')?.innerText ?? 'No Title';
      final link = item.getElement('link')?.innerText;
      final pubDate = item.getElement('pubDate')?.innerText;
      final sourceElement = item.getElement('source');
      final sourceName = sourceElement?.innerText;
      final sourceUrl = sourceElement?.getAttribute('url');

      // Parse title: "Article Title - Source Name"
      String title = rawTitle;
      String? extractedSource = sourceName;
      final dashIndex = rawTitle.lastIndexOf(' - ');
      if (dashIndex > 0) {
        title = rawTitle.substring(0, dashIndex).trim();
        extractedSource ??= rawTitle.substring(dashIndex + 3).trim();
      }

      final descHtml = item.getElement('description')?.innerText ?? '';
      final imageUrl = _extractImageFromHtml(descHtml);
      final description = _stripHtml(descHtml);

      // Build favicon URL from source domain as image fallback
      String? thumbnail = imageUrl;
      if (thumbnail == null && sourceUrl != null) {
        final domain = Uri.tryParse(sourceUrl)?.host;
        if (domain != null) {
          thumbnail =
              'https://www.google.com/s2/favicons?domain=$domain&sz=128';
        }
      }

      results.add(ArticleModel(
        title: title,
        url: link,
        publishedAt: _formatPubDate(pubDate),
        sourceName: extractedSource,
        sourceId: sourceUrl,
        description: description.isNotEmpty ? description : null,
        urlToImage: thumbnail,
      ));
    }

    return results;
  }

  // ────────────────────────────────────────────
  //  HELPERS
  // ────────────────────────────────────────────

  String? _extractImageFromHtml(String html) {
    final imgMatch = RegExp(r'<img[^>]+src="([^"]+)"').firstMatch(html);
    if (imgMatch != null) return imgMatch.group(1);
    return null;
  }

  String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'&nbsp;'), ' ')
        .replaceAll(RegExp(r'&amp;'), '&')
        .replaceAll(RegExp(r'&lt;'), '<')
        .replaceAll(RegExp(r'&gt;'), '>')
        .replaceAll(RegExp(r'&quot;'), '"')
        .replaceAll(RegExp(r'&#39;'), "'")
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String? _formatPubDate(String? pubDate) {
    if (pubDate == null) return null;
    try {
      final parsed = _parseRfc2822(pubDate);
      return parsed?.toIso8601String();
    } catch (_) {
      return pubDate;
    }
  }

  DateTime? _parseRfc2822(String dateStr) {
    try {
      const months = {
        'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
        'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
      };
      final parts =
          dateStr.replaceFirst(RegExp(r'^\w+,\s*'), '').split(' ');
      if (parts.length < 4) return null;
      final day = int.parse(parts[0]);
      final month = months[parts[1]] ?? 1;
      final year = int.parse(parts[2]);
      final timeParts = parts[3].split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      final second = timeParts.length > 2 ? int.parse(timeParts[2]) : 0;
      return DateTime.utc(year, month, day, hour, minute, second);
    } catch (_) {
      return null;
    }
  }

  DateTime? _parseDate(String dateStr) {
    try {
      return DateTime.parse(dateStr);
    } catch (_) {
      return _parseRfc2822(dateStr);
    }
  }
}
