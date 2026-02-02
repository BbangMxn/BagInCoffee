import 'client.dart';

/// 게시물 모델
class Post {
  final String id;
  final String authorId;
  final String? title;
  final String content;
  final List<String> images;
  final List<String> tags;
  final int likesCount;
  final int commentsCount;
  final int viewsCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Post({
    required this.id,
    required this.authorId,
    this.title,
    required this.content,
    required this.images,
    required this.tags,
    required this.likesCount,
    required this.commentsCount,
    required this.viewsCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      authorId: json['author_id'] ?? json['user_id'] ?? '',
      title: json['title'] as String?,
      content: json['content'] as String,
      images: (json['images'] as List<dynamic>?)?.cast<String>() ?? [],
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      likesCount: json['likes_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      viewsCount: json['views_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

/// 게시물 + 작성자 정보
class PostWithAuthor extends Post {
  final PostAuthor? author;
  final bool? hasLiked;

  PostWithAuthor({
    required super.id,
    required super.authorId,
    super.title,
    required super.content,
    required super.images,
    required super.tags,
    required super.likesCount,
    required super.commentsCount,
    required super.viewsCount,
    required super.createdAt,
    required super.updatedAt,
    this.author,
    this.hasLiked,
  });

  factory PostWithAuthor.fromJson(Map<String, dynamic> json) {
    return PostWithAuthor(
      id: json['id'] as String,
      authorId: json['author_id'] ?? json['user_id'] ?? '',
      title: json['title'] as String?,
      content: json['content'] as String,
      images: (json['images'] as List<dynamic>?)?.cast<String>() ?? [],
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      likesCount: json['likes_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      viewsCount: json['views_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      author: json['author'] != null
          ? PostAuthor.fromJson(json['author'] as Map<String, dynamic>)
          : null,
      hasLiked: json['has_liked'] as bool?,
    );
  }
}

/// 게시물 작성자
class PostAuthor {
  final String id;
  final String? username;
  final String? avatarUrl;

  PostAuthor({required this.id, this.username, this.avatarUrl});

  factory PostAuthor.fromJson(Map<String, dynamic> json) {
    return PostAuthor(
      id: json['id'] as String,
      username: json['username'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}

/// 게시물 생성 DTO
class CreatePostDto {
  final String? title;
  final String content;
  final List<String>? images;
  final List<String>? tags;

  CreatePostDto({this.title, required this.content, this.images, this.tags});

  Map<String, dynamic> toJson() => {
    if (title != null) 'title': title,
    'content': content,
    if (images != null) 'images': images,
    if (tags != null) 'tags': tags,
  };
}

/// 게시물 수정 DTO
class UpdatePostDto {
  final String? title;
  final String? content;
  final List<String>? images;
  final List<String>? tags;

  UpdatePostDto({this.title, this.content, this.images, this.tags});

  Map<String, dynamic> toJson() => {
    if (title != null) 'title': title,
    if (content != null) 'content': content,
    if (images != null) 'images': images,
    if (tags != null) 'tags': tags,
  };
}

/// Posts API
class PostsApi {
  final ApiClient _client = ApiClient();

  /// 게시물 목록 조회
  Future<List<PostWithAuthor>> list({
    int? page,
    int? limit,
    String? tag,
  }) async {
    final response = await _client.get(
      '/api/posts',
      queryParameters: {
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
        if (tag != null) 'tag': tag,
      },
    );
    return (response as List).map((e) => PostWithAuthor.fromJson(e)).toList();
  }

  /// 인기 게시물 조회
  Future<List<PostWithAuthor>> getPopular({int? limit}) async {
    final response = await _client.get(
      '/api/posts/popular',
      queryParameters: {if (limit != null) 'limit': limit},
    );
    return (response as List).map((e) => PostWithAuthor.fromJson(e)).toList();
  }

  /// 게시물 검색
  Future<List<Post>> search(String query, {int? page, int? limit}) async {
    final response = await _client.get(
      '/api/posts/search',
      queryParameters: {
        'q': query,
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
      },
    );
    return (response as List).map((e) => Post.fromJson(e)).toList();
  }

  /// 사용자별 게시물 조회
  Future<List<PostWithAuthor>> getUserPosts(
    String userId, {
    int? page,
    int? limit,
  }) async {
    final response = await _client.get(
      '/api/posts/user/$userId',
      queryParameters: {
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
      },
    );
    return (response as List).map((e) => PostWithAuthor.fromJson(e)).toList();
  }

  /// 게시물 상세 조회
  Future<PostWithAuthor> getById(String id) async {
    final response = await _client.get('/api/posts/$id');
    return PostWithAuthor.fromJson(response);
  }

  /// 게시물 작성
  Future<Post> create(CreatePostDto dto) async {
    final response = await _client.post('/api/posts', data: dto.toJson());
    return Post.fromJson(response);
  }

  /// 게시물 수정
  Future<Post> update(String id, UpdatePostDto dto) async {
    final response = await _client.put('/api/posts/$id', data: dto.toJson());
    return Post.fromJson(response);
  }

  /// 게시물 삭제
  Future<void> delete(String id) async {
    await _client.delete('/api/posts/$id');
  }

  /// 좋아요 토글
  Future<Map<String, dynamic>> toggleLike(String postId) async {
    final response = await _client.post('/api/posts/$postId/like');
    return response as Map<String, dynamic>;
  }
}

/// Posts API 싱글톤 인스턴스
final postsApi = PostsApi();
