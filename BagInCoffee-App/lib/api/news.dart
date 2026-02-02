import 'client.dart';

/// 뉴스 기사 모델
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

  NewsArticle({
    required this.id,
    this.authorId,
    required this.title,
    required this.content,
    this.excerpt,
    this.coverImage,
    this.tags = const [],
    this.published = false,
    this.viewsCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      id: json['id'],
      authorId: json['author_id'],
      title: json['title'],
      content: json['content'],
      excerpt: json['excerpt'],
      coverImage: json['cover_image'],
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      published: json['published'] ?? false,
      viewsCount: json['views_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
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

/// 뉴스 생성 DTO
class CreateNewsDto {
  final String title;
  final String content;
  final String? excerpt;
  final String? coverImage;
  final List<String>? tags;
  final bool? published;

  CreateNewsDto({
    required this.title,
    required this.content,
    this.excerpt,
    this.coverImage,
    this.tags,
    this.published,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'content': content,
    if (excerpt != null) 'excerpt': excerpt,
    if (coverImage != null) 'cover_image': coverImage,
    if (tags != null) 'tags': tags,
    if (published != null) 'published': published,
  };
}

/// 뉴스 수정 DTO
class UpdateNewsDto {
  final String? title;
  final String? content;
  final String? excerpt;
  final String? coverImage;
  final List<String>? tags;
  final bool? published;

  UpdateNewsDto({
    this.title,
    this.content,
    this.excerpt,
    this.coverImage,
    this.tags,
    this.published,
  });

  Map<String, dynamic> toJson() => {
    if (title != null) 'title': title,
    if (content != null) 'content': content,
    if (excerpt != null) 'excerpt': excerpt,
    if (coverImage != null) 'cover_image': coverImage,
    if (tags != null) 'tags': tags,
    if (published != null) 'published': published,
  };
}

/// News API
class NewsApi {
  final ApiClient _client = ApiClient();

  /// 뉴스 목록 조회
  Future<List<NewsArticle>> list({int? limit, int? offset}) async {
    final queryParams = <String, dynamic>{};
    if (limit != null) queryParams['limit'] = limit;
    if (offset != null) queryParams['offset'] = offset;

    final response = await _client.get(
      '/api/news',
      queryParameters: queryParams,
    );
    return (response as List).map((e) => NewsArticle.fromJson(e)).toList();
  }

  /// 발행된 뉴스만 조회
  Future<List<NewsArticle>> listPublished({int? limit, int? offset}) async {
    final queryParams = <String, dynamic>{'published': true};
    if (limit != null) queryParams['limit'] = limit;
    if (offset != null) queryParams['offset'] = offset;

    final response = await _client.get(
      '/api/news',
      queryParameters: queryParams,
    );
    return (response as List).map((e) => NewsArticle.fromJson(e)).toList();
  }

  /// 뉴스 상세 조회
  Future<NewsArticle> getById(String id) async {
    final response = await _client.get('/api/news/$id');
    return NewsArticle.fromJson(response);
  }

  /// 뉴스 생성
  Future<NewsArticle> create(CreateNewsDto dto) async {
    final response = await _client.post('/api/news', data: dto.toJson());
    return NewsArticle.fromJson(response);
  }

  /// 뉴스 수정
  Future<NewsArticle> update(String id, UpdateNewsDto dto) async {
    final response = await _client.put('/api/news/$id', data: dto.toJson());
    return NewsArticle.fromJson(response);
  }

  /// 뉴스 삭제
  Future<void> delete(String id) async {
    await _client.delete('/api/news/$id');
  }

  /// 태그로 뉴스 검색
  Future<List<NewsArticle>> getByTag(String tag, {int? limit}) async {
    final queryParams = <String, dynamic>{'tag': tag};
    if (limit != null) queryParams['limit'] = limit;

    final response = await _client.get(
      '/api/news/tag',
      queryParameters: queryParams,
    );
    return (response as List).map((e) => NewsArticle.fromJson(e)).toList();
  }

  /// 뉴스 검색
  Future<List<NewsArticle>> search(String query, {int? limit}) async {
    final queryParams = <String, dynamic>{'q': query};
    if (limit != null) queryParams['limit'] = limit;

    final response = await _client.get(
      '/api/news/search',
      queryParameters: queryParams,
    );
    return (response as List).map((e) => NewsArticle.fromJson(e)).toList();
  }
}

final newsApi = NewsApi();
