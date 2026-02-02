import 'client.dart';

/// 간단한 사용자 프로필
class CommentAuthor {
  final String id;
  final String? username;
  final String? avatarUrl;

  CommentAuthor({required this.id, this.username, this.avatarUrl});

  factory CommentAuthor.fromJson(Map<String, dynamic> json) {
    return CommentAuthor(
      id: json['id'],
      username: json['username'],
      avatarUrl: json['avatar_url'],
    );
  }
}

/// 댓글 모델
class Comment {
  final String id;
  final String userId;
  final String postId;
  final String? parentCommentId;
  final String content;
  final int repliesCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final CommentAuthor? author;
  final List<Comment>? replies;

  Comment({
    required this.id,
    required this.userId,
    required this.postId,
    this.parentCommentId,
    required this.content,
    this.repliesCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.author,
    this.replies,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      userId: json['user_id'] ?? json['author_id'],
      postId: json['post_id'],
      parentCommentId: json['parent_comment_id'],
      content: json['content'],
      repliesCount: json['replies_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      author: json['author'] != null
          ? CommentAuthor.fromJson(json['author'])
          : null,
      replies: json['replies'] != null
          ? (json['replies'] as List).map((e) => Comment.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'post_id': postId,
    'parent_comment_id': parentCommentId,
    'content': content,
    'replies_count': repliesCount,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}

/// 댓글 생성 DTO
class CreateCommentDto {
  final String postId;
  final String content;
  final String? parentCommentId;

  CreateCommentDto({
    required this.postId,
    required this.content,
    this.parentCommentId,
  });

  Map<String, dynamic> toJson() => {
    'post_id': postId,
    'content': content,
    if (parentCommentId != null) 'parent_comment_id': parentCommentId,
  };
}

/// 댓글 수정 DTO
class UpdateCommentDto {
  final String content;

  UpdateCommentDto({required this.content});

  Map<String, dynamic> toJson() => {'content': content};
}

/// Comments API
class CommentsApi {
  final ApiClient _client = ApiClient();

  /// 게시물의 댓글 목록 조회
  Future<List<Comment>> listByPost(
    String postId, {
    int? limit,
    int? offset,
  }) async {
    final queryParams = <String, dynamic>{};
    if (limit != null) queryParams['limit'] = limit;
    if (offset != null) queryParams['offset'] = offset;

    final response = await _client.get(
      '/api/posts/$postId/comments',
      queryParameters: queryParams,
    );
    return (response as List).map((e) => Comment.fromJson(e)).toList();
  }

  /// 댓글 상세 조회
  Future<Comment> getById(String id) async {
    final response = await _client.get('/api/comments/$id');
    return Comment.fromJson(response);
  }

  /// 대댓글 목록 조회
  Future<List<Comment>> getReplies(String commentId, {int? limit}) async {
    final queryParams = <String, dynamic>{};
    if (limit != null) queryParams['limit'] = limit;

    final response = await _client.get(
      '/api/comments/$commentId/replies',
      queryParameters: queryParams,
    );
    return (response as List).map((e) => Comment.fromJson(e)).toList();
  }

  /// 댓글 생성
  Future<Comment> create(CreateCommentDto dto) async {
    final response = await _client.post('/api/comments', data: dto.toJson());
    return Comment.fromJson(response);
  }

  /// 댓글 수정
  Future<Comment> update(String id, UpdateCommentDto dto) async {
    final response = await _client.put('/api/comments/$id', data: dto.toJson());
    return Comment.fromJson(response);
  }

  /// 댓글 삭제
  Future<void> delete(String id) async {
    await _client.delete('/api/comments/$id');
  }

  /// 사용자의 댓글 목록 조회
  Future<List<Comment>> listByUser(
    String userId, {
    int? limit,
    int? offset,
  }) async {
    final queryParams = <String, dynamic>{};
    if (limit != null) queryParams['limit'] = limit;
    if (offset != null) queryParams['offset'] = offset;

    final response = await _client.get(
      '/api/users/$userId/comments',
      queryParameters: queryParams,
    );
    return (response as List).map((e) => Comment.fromJson(e)).toList();
  }
}

final commentsApi = CommentsApi();
