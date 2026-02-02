/// 뉴스/매거진 기사
class NewsArticle {
  final String id;
  final String? authorId;
  final String title;
  final String content;
  final String? excerpt;
  final String? coverImage;
  final List<String> tags;
  final bool published;
  final int viewsCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NewsArticle({
    required this.id,
    this.authorId,
    required this.title,
    required this.content,
    this.excerpt,
    this.coverImage,
    required this.tags,
    required this.published,
    required this.viewsCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      id: json['id'] as String,
      authorId: json['author_id'] as String?,
      title: json['title'] as String,
      content: json['content'] as String,
      excerpt: json['excerpt'] as String?,
      coverImage: json['cover_image'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          [],
      published: json['published'] as bool? ?? false,
      viewsCount: json['views_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author_id': authorId,
      'title': title,
      'content': content,
      'excerpt': excerpt,
      'cover_image': coverImage,
      'tags': tags,
      'published': published,
      'views_count': viewsCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
