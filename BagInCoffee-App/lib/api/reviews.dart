import 'client.dart';

/// 리뷰 API
class ReviewsApi {
  final ApiClient _client;

  ReviewsApi([ApiClient? client]) : _client = client ?? ApiClient();

  /// 아이템별 리뷰 목록 조회
  Future<List<Review>> getItemReviews({
    required String itemId,
    String itemType = 'external_product',
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _client.get(
      '/reviews/item/$itemId',
      queryParameters: {
        'item_type': itemType,
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );

    if (response is List) {
      return response.map((json) => Review.fromJson(json)).toList();
    }
    return [];
  }

  /// 아이템 평균 평점 조회
  Future<double?> getItemAverageRating({
    required String itemId,
    String itemType = 'external_product',
  }) async {
    final response = await _client.get(
      '/reviews/item/$itemId/average',
      queryParameters: {'item_type': itemType},
    );

    if (response == null) return null;
    if (response is num) return response.toDouble();
    return null;
  }

  /// 리뷰 작성
  Future<Review> createReview(CreateReviewDto dto) async {
    final response = await _client.post('/reviews', data: dto.toJson());
    return Review.fromJson(response);
  }

  /// 리뷰 수정
  Future<Review> updateReview(String reviewId, UpdateReviewDto dto) async {
    final response = await _client.put(
      '/reviews/$reviewId',
      data: dto.toJson(),
    );
    return Review.fromJson(response);
  }

  /// 리뷰 삭제
  Future<void> deleteReview(String reviewId) async {
    await _client.delete('/reviews/$reviewId');
  }
}

/// 리뷰 모델
class Review {
  final String id;
  final String userId;
  final String itemType;
  final String itemId;
  final int rating;
  final String? review;
  final DateTime createdAt;
  final DateTime updatedAt;

  Review({
    required this.id,
    required this.userId,
    required this.itemType,
    required this.itemId,
    required this.rating,
    this.review,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      itemType: json['item_type'] as String,
      itemId: json['item_id'] as String,
      rating: json['rating'] as int,
      review: json['review'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'item_type': itemType,
      'item_id': itemId,
      'rating': rating,
      'review': review,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// 리뷰 작성 DTO
class CreateReviewDto {
  final String itemType;
  final String itemId;
  final int rating;
  final String? review;

  CreateReviewDto({
    required this.itemType,
    required this.itemId,
    required this.rating,
    this.review,
  });

  Map<String, dynamic> toJson() {
    return {
      'item_type': itemType,
      'item_id': itemId,
      'rating': rating,
      if (review != null) 'review': review,
    };
  }
}

/// 리뷰 수정 DTO
class UpdateReviewDto {
  final int? rating;
  final String? review;

  UpdateReviewDto({this.rating, this.review});

  Map<String, dynamic> toJson() {
    return {
      if (rating != null) 'rating': rating,
      if (review != null) 'review': review,
    };
  }
}
