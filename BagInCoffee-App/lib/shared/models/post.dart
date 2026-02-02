/// 게시물 작성자 정보
class Author {
  final String id;
  final String? username;
  final String? avatarUrl;

  const Author({required this.id, this.username, this.avatarUrl});

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      id: json['id'] as String,
      username: json['username'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'username': username, 'avatar_url': avatarUrl};
  }
}

/// 게시물
class Post {
  final String id;
  final String userId;
  final String content;
  final List<String> images;
  final List<String>? tags;
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Author? author;

  const Post({
    required this.id,
    required this.userId,
    required this.content,
    required this.images,
    this.tags,
    required this.likesCount,
    required this.commentsCount,
    required this.createdAt,
    required this.updatedAt,
    this.author,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String? ?? '',
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      likesCount: json['likes_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      author: json['author'] != null
          ? Author.fromJson(json['author'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'content': content,
      'images': images,
      'tags': tags,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'author': author?.toJson(),
    };
  }

  Post copyWith({
    String? id,
    String? userId,
    String? content,
    List<String>? images,
    List<String>? tags,
    int? likesCount,
    int? commentsCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    Author? author,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      images: images ?? this.images,
      tags: tags ?? this.tags,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      author: author ?? this.author,
    );
  }
}

/// 게시물 작성 DTO
class CreatePostDto {
  final String content;
  final List<String> images;
  final List<String>? tags;

  const CreatePostDto({
    required this.content,
    this.images = const [],
    this.tags,
  });

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'images': images,
      if (tags != null) 'tags': tags,
    };
  }
}

/// 게시물 수정 DTO
class UpdatePostDto {
  final String? content;
  final List<String>? images;
  final List<String>? tags;

  const UpdatePostDto({this.content, this.images, this.tags});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (content != null) map['content'] = content;
    if (images != null) map['images'] = images;
    if (tags != null) map['tags'] = tags;
    return map;
  }
}
