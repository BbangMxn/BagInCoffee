/// 알림 타입
enum NotificationType {
  like,
  comment,
  follow,
  mention,
  system;

  factory NotificationType.fromString(String value) {
    return NotificationType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => NotificationType.system,
    );
  }
}

/// 알림 데이터
class NotificationData {
  final String? postId;
  final String? likerId;
  final String? commentId;
  final String? commenterId;
  final String? followerId;
  final String? mentionerId;
  final String? action;
  final Map<String, dynamic>? metadata;

  const NotificationData({
    this.postId,
    this.likerId,
    this.commentId,
    this.commenterId,
    this.followerId,
    this.mentionerId,
    this.action,
    this.metadata,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      postId: json['post_id'] as String?,
      likerId: json['liker_id'] as String?,
      commentId: json['comment_id'] as String?,
      commenterId: json['commenter_id'] as String?,
      followerId: json['follower_id'] as String?,
      mentionerId: json['mentioner_id'] as String?,
      action: json['action'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (postId != null) 'post_id': postId,
      if (likerId != null) 'liker_id': likerId,
      if (commentId != null) 'comment_id': commentId,
      if (commenterId != null) 'commenter_id': commenterId,
      if (followerId != null) 'follower_id': followerId,
      if (mentionerId != null) 'mentioner_id': mentionerId,
      if (action != null) 'action': action,
      if (metadata != null) 'metadata': metadata,
    };
  }
}

/// 알림
class AppNotification {
  final String id;
  final String userId;
  final NotificationType notificationType;
  final String title;
  final String message;
  final String? link;
  final NotificationData? data;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.notificationType,
    required this.title,
    required this.message,
    this.link,
    this.data,
    required this.isRead,
    required this.createdAt,
    this.readAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      notificationType: NotificationType.fromString(
        json['type'] ?? json['notification_type'] as String? ?? 'system',
      ),
      title: json['title'] as String,
      message: json['message'] as String,
      link: json['link'] as String?,
      data: json['data'] != null
          ? NotificationData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      readAt: json['read_at'] != null
          ? DateTime.parse(json['read_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': notificationType.name,
      'title': title,
      'message': message,
      'link': link,
      'data': data?.toJson(),
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
    };
  }
}
