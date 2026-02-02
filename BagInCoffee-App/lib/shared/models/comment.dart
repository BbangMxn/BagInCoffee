import 'user_profile.dart';

/// 댓글
class Comment {
  final String id;
  final String userId;
  final String postId;
  final String? parentCommentId;
  final String content;
  final int repliesCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserProfileSimple? author;
  final List<Comment>? replies;

  const Comment({
    required this.id,
    required this.userId,
    required this.postId,
    this.parentCommentId,
    required this.content,
    required this.repliesCount,
    required this.createdAt,
    required this.updatedAt,
    this.author,
    this.replies,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as String,
      userId: json['user_id'] ?? json['author_id'] as String,
      postId: json['post_id'] as String,
      parentCommentId: json['parent_comment_id'] as String?,
      content: json['content'] as String,
      repliesCount: json['replies_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      author: json['author'] != null
          ? UserProfileSimple.fromJson(json['author'] as Map<String, dynamic>)
          : null,
      replies: (json['replies'] as List<dynamic>?)
          ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'post_id': postId,
      'parent_comment_id': parentCommentId,
      'content': content,
      'replies_count': repliesCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'author': author?.toJson(),
      'replies': replies?.map((e) => e.toJson()).toList(),
    };
  }
}

/// 댓글 작성 DTO
class CreateCommentDto {
  final String postId;
  final String content;
  final String? parentCommentId;

  const CreateCommentDto({
    required this.postId,
    required this.content,
    this.parentCommentId,
  });

  Map<String, dynamic> toJson() {
    return {
      'post_id': postId,
      'content': content,
      if (parentCommentId != null) 'parent_comment_id': parentCommentId,
    };
  }
}

/// 댓글 수정 DTO
class UpdateCommentDto {
  final String content;

  const UpdateCommentDto({required this.content});

  Map<String, dynamic> toJson() {
    return {'content': content};
  }
}
