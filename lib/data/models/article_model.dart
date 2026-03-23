import '../../domain/entities/article.dart';

class ArticleModel extends Article {
  const ArticleModel({
    super.sourceId,
    super.sourceName,
    super.author,
    required super.title,
    super.description,
    super.url,
    super.urlToImage,
    super.publishedAt,
    super.content,
    super.category,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    final url = json['url'] as String?;
    return ArticleModel(
      sourceId: json['source']?['id'],
      sourceName: _resolveSourceName(
        json['source']?['name'] as String?,
        url,
      ),
      author: json['author'],
      title: json['title'] ?? 'No Title',
      description: json['description'],
      url: url,
      urlToImage: json['urlToImage'],
      publishedAt: json['publishedAt'],
      content: json['content'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'source': {'id': sourceId, 'name': sourceName},
      'author': author,
      'title': title,
      'description': description,
      'url': url,
      'urlToImage': urlToImage,
      'publishedAt': publishedAt,
      'content': content,
      'category': category,
    };
  }

  /// GNews API has a different response format
  factory ArticleModel.fromGNews(Map<String, dynamic> json) {
    final url = json['url'] as String?;
    return ArticleModel(
      sourceName: _resolveSourceName(
        json['source']?['name'] as String?,
        url,
      ),
      sourceId: json['source']?['url'],
      title: json['title'] ?? 'No Title',
      description: json['description'],
      url: url,
      urlToImage: json['image'],
      publishedAt: json['publishedAt'],
      content: json['content'],
    );
  }

  factory ArticleModel.fromEntity(Article article) {
    return ArticleModel(
      sourceId: article.sourceId,
      sourceName: article.sourceName,
      author: article.author,
      title: article.title,
      description: article.description,
      url: article.url,
      urlToImage: article.urlToImage,
      publishedAt: article.publishedAt,
      content: article.content,
      category: article.category,
    );
  }

  factory ArticleModel.fromHive(Map<dynamic, dynamic> map) {
    return ArticleModel(
      sourceId: map['sourceId'],
      sourceName: map['sourceName'],
      author: map['author'],
      title: map['title'] ?? 'No Title',
      description: map['description'],
      url: map['url'],
      urlToImage: map['urlToImage'],
      publishedAt: map['publishedAt'],
      content: map['content'],
      category: map['category'],
    );
  }

  Map<String, dynamic> toHiveMap() {
    return {
      'sourceId': sourceId,
      'sourceName': sourceName,
      'author': author,
      'title': title,
      'description': description,
      'url': url,
      'urlToImage': urlToImage,
      'publishedAt': publishedAt,
      'content': content,
      'category': category,
    };
  }

  static String? _resolveSourceName(String? rawSourceName, String? articleUrl) {
    final domain = _extractDomain(articleUrl);
    if (domain != null && domain.isNotEmpty) {
      return domain;
    }

    if (rawSourceName == null || rawSourceName.trim().isEmpty) {
      return null;
    }

    return rawSourceName.trim();
  }

  static String? _extractDomain(String? articleUrl) {
    if (articleUrl == null || articleUrl.trim().isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(articleUrl);
    final host = uri?.host;
    if (host == null || host.isEmpty) {
      return null;
    }

    return host.replaceFirst(RegExp(r'^www\.'), '');
  }
}
