class Article {
  final String? sourceId;
  final String? sourceName;
  final String? author;
  final String title;
  final String? description;
  final String? url;
  final String? urlToImage;
  final String? publishedAt;
  final String? content;
  final String? category;

  const Article({
    this.sourceId,
    this.sourceName,
    this.author,
    required this.title,
    this.description,
    this.url,
    this.urlToImage,
    this.publishedAt,
    this.content,
    this.category,
  });

  String get uniqueKey => '${url ?? title}_${publishedAt ?? ''}';
}
