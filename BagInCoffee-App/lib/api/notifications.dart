import 'client.dart';

/// 알림 타입
enum NotificationType {
  like,
  comment,
  follow,
  mention,
  system;

  String toJson() => name;

  static NotificationType fromJson(String json) {
    switch (json) {
      case 'like':
        return NotificationType.like;
      case 'comment':
        return NotificationType.comment;
      case 'follow':
        return NotificationType.follow;
      case 'mention':
        return NotificationType.mention;
      case 'system':
        return NotificationType.system;
      default:
        return NotificationType.system;
    }
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

  NotificationData({
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
      postId: json['post_id'],
      likerId: json['liker_id'],
      commentId: json['comment_id'],
      commenterId: json['commenter_id'],
      followerId: json['follower_id'],
      mentionerId: json['mentioner_id'],
      action: json['action'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() => {
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

/// 알림 모델
class Notification {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String message;
  final String? link;
  final NotificationData? data;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  Notification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.link,
    this.data,
    this.isRead = false,
    required this.createdAt,
    this.readAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      userId: json['user_id'],
      type: NotificationType.fromJson(
        json['type'] ?? json['notification_type'] ?? 'system',
      ),
      title: json['title'],
      message: json['message'],
      link: json['link'],
      data: json['data'] != null
          ? NotificationData.fromJson(json['data'])
          : null,
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'type': type.toJson(),
    'title': title,
    'message': message,
    'link': link,
    'data': data?.toJson(),
    'is_read': isRead,
    'created_at': createdAt.toIso8601String(),
    'read_at': readAt?.toIso8601String(),
  };
}

/// Notifications API
class NotificationsApi {
  final ApiClient _client = ApiClient();

  /// 알림 목록 조회
  Future<List<Notification>> list({
    int? limit,
    int? offset,
    bool? unreadOnly,
  }) async {
    final queryParams = <String, dynamic>{};
    if (limit != null) queryParams['limit'] = limit;
    if (offset != null) queryParams['offset'] = offset;
    if (unreadOnly == true) queryParams['unread_only'] = true;

    final response = await _client.get(
      '/api/notifications',
      queryParameters: queryParams,
      requiresAuth: true,
    );
    return (response as List).map((e) => Notification.fromJson(e)).toList();
  }

  /// 읽지 않은 알림 개수
  Future<int> getUnreadCount() async {
    final response = await _client.get(
      '/api/notifications/unread-count',
      requiresAuth: true,
    );
    return (response as Map<String, dynamic>)['count'] ?? 0;
  }

  /// 알림 읽음 처리
  Future<void> markAsRead(String id) async {
    await _client.put('/api/notifications/$id/read');
  }

  /// 모든 알림 읽음 처리
  Future<void> markAllAsRead() async {
    await _client.put('/api/notifications/read-all');
  }

  /// 알림 삭제
  Future<void> delete(String id) async {
    await _client.delete('/api/notifications/$id');
  }

  /// 모든 알림 삭제
  Future<void> deleteAll() async {
    await _client.delete('/api/notifications/all');
  }

  /// 알림 설정 조회
  Future<Map<String, dynamic>> getSettings() async {
    final response = await _client.get(
      '/api/notifications/settings',
      requiresAuth: true,
    );
    return response as Map<String, dynamic>;
  }

  /// 알림 설정 업데이트
  Future<void> updateSettings(Map<String, dynamic> settings) async {
    await _client.put('/api/notifications/settings', data: settings);
  }

  /// 디바이스 토큰 등록 (푸시 알림용)
  Future<void> registerDeviceToken(String token, String platform) async {
    await _client.post(
      '/api/notifications/device-token',
      data: {'token': token, 'platform': platform},
    );
  }

  /// 디바이스 토큰 삭제
  Future<void> removeDeviceToken(String token) async {
    await _client.delete('/api/notifications/device-token/$token');
  }
}

final notificationsApi = NotificationsApi();
