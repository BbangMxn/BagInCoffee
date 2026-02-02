import 'client.dart';

/// 가이드 카테고리
enum GuideCategory {
  brewing,
  beans,
  equipment,
  recipe,
  roasting,
  barista,
  science,
  culture,
  other;

  String get label {
    switch (this) {
      case GuideCategory.brewing:
        return '추출 방법';
      case GuideCategory.beans:
        return '원두 가이드';
      case GuideCategory.equipment:
        return '장비 사용법';
      case GuideCategory.recipe:
        return '레시피';
      case GuideCategory.roasting:
        return '로스팅';
      case GuideCategory.barista:
        return '바리스타';
      case GuideCategory.science:
        return '커피 과학';
      case GuideCategory.culture:
        return '커피 문화';
      case GuideCategory.other:
        return '기타';
    }
  }
}

/// 가이드 난이도
enum GuideDifficulty {
  beginner,
  intermediate,
  advanced;

  String get label {
    switch (this) {
      case GuideDifficulty.beginner:
        return '초급';
      case GuideDifficulty.intermediate:
        return '중급';
      case GuideDifficulty.advanced:
        return '고급';
    }
  }
}

/// 커피 가이드 모델
class CoffeeGuide {
  final String id;
  final String title;
  final String slug;
  final String category;
  final String? difficulty;
  final String content;
  final String? excerpt;
  final String? coverImage;
  final int? readingTimeMinutes;
  final List<String> tags;
  final bool published;
  final bool featured;
  final String? publishedAt;
  final int viewsCount;
  final String? collectionId;
  final String? parentId;
  final int? orderIndex;
  final DateTime createdAt;
  final DateTime updatedAt;

  CoffeeGuide({
    required this.id,
    required this.title,
    required this.slug,
    required this.category,
    this.difficulty,
    required this.content,
    this.excerpt,
    this.coverImage,
    this.readingTimeMinutes,
    required this.tags,
    required this.published,
    required this.featured,
    this.publishedAt,
    required this.viewsCount,
    this.collectionId,
    this.parentId,
    this.orderIndex,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CoffeeGuide.fromJson(Map<String, dynamic> json) {
    return CoffeeGuide(
      id: json['id'] as String,
      title: json['title'] as String,
      slug: json['slug'] as String,
      category: json['category'] as String,
      difficulty: json['difficulty'] as String?,
      content: json['content'] as String,
      excerpt: json['excerpt'] as String?,
      coverImage: json['cover_image'] as String?,
      readingTimeMinutes: json['reading_time_minutes'] as int?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      published: json['published'] as bool? ?? false,
      featured: json['featured'] as bool? ?? false,
      publishedAt: json['published_at'] as String?,
      viewsCount: json['views_count'] as int? ?? 0,
      collectionId: json['collection_id'] as String?,
      parentId: json['parent_id'] as String?,
      orderIndex: json['order_index'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  String get categoryLabel {
    switch (category) {
      case 'brewing':
        return '추출 방법';
      case 'beans':
        return '원두 가이드';
      case 'equipment':
        return '장비 사용법';
      case 'recipe':
        return '레시피';
      case 'roasting':
        return '로스팅';
      case 'barista':
        return '바리스타';
      case 'science':
        return '커피 과학';
      case 'culture':
        return '커피 문화';
      default:
        return '기타';
    }
  }

  String get difficultyLabel {
    switch (difficulty) {
      case 'beginner':
        return '초급';
      case 'intermediate':
        return '중급';
      case 'advanced':
        return '고급';
      default:
        return '';
    }
  }
}

/// 가이드 컬렉션
class GuideCollection {
  final String id;
  final String title;
  final String slug;
  final String? description;
  final String? icon;
  final String? coverImage;
  final String? parentId;
  final int orderIndex;
  final bool published;
  final DateTime createdAt;
  final DateTime updatedAt;

  GuideCollection({
    required this.id,
    required this.title,
    required this.slug,
    this.description,
    this.icon,
    this.coverImage,
    this.parentId,
    required this.orderIndex,
    required this.published,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GuideCollection.fromJson(Map<String, dynamic> json) {
    return GuideCollection(
      id: json['id'] as String,
      title: json['title'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      coverImage: json['cover_image'] as String?,
      parentId: json['parent_id'] as String?,
      orderIndex: json['order_index'] as int? ?? 0,
      published: json['published'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

/// 컬렉션 + 하위 항목
class CollectionWithChildren {
  final GuideCollection collection;
  final List<CollectionWithChildren> children;
  final List<CoffeeGuide> guides;

  CollectionWithChildren({
    required this.collection,
    required this.children,
    required this.guides,
  });

  factory CollectionWithChildren.fromJson(Map<String, dynamic> json) {
    return CollectionWithChildren(
      collection: GuideCollection.fromJson(
        json['collection'] as Map<String, dynamic>,
      ),
      children:
          (json['children'] as List<dynamic>?)
              ?.map(
                (e) =>
                    CollectionWithChildren.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      guides:
          (json['guides'] as List<dynamic>?)
              ?.map((e) => CoffeeGuide.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Guides API
class GuidesApi {
  final ApiClient _client = ApiClient();

  /// 발행된 가이드 목록 조회
  Future<List<CoffeeGuide>> list({int? page, int? limit}) async {
    final response = await _client.get(
      '/api/guides',
      queryParameters: {
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
      },
    );
    return (response as List).map((e) => CoffeeGuide.fromJson(e)).toList();
  }

  /// 가이드 상세 조회
  Future<CoffeeGuide> getById(String id) async {
    final response = await _client.get('/api/guides/$id');
    return CoffeeGuide.fromJson(response);
  }

  /// Slug로 가이드 조회
  Future<CoffeeGuide> getBySlug(String slug) async {
    final response = await _client.get('/api/guides/slug/$slug');
    return CoffeeGuide.fromJson(response);
  }

  /// 추천 가이드 조회
  Future<List<CoffeeGuide>> getFeatured({int? limit}) async {
    final response = await _client.get(
      '/api/guides/featured',
      queryParameters: {if (limit != null) 'limit': limit},
    );
    return (response as List).map((e) => CoffeeGuide.fromJson(e)).toList();
  }

  /// 인기 가이드 조회
  Future<List<CoffeeGuide>> getPopular({int? limit}) async {
    final response = await _client.get(
      '/api/guides/popular',
      queryParameters: {if (limit != null) 'limit': limit},
    );
    return (response as List).map((e) => CoffeeGuide.fromJson(e)).toList();
  }

  /// 최신 가이드 조회
  Future<List<CoffeeGuide>> getRecent({int? limit}) async {
    final response = await _client.get(
      '/api/guides/recent',
      queryParameters: {if (limit != null) 'limit': limit},
    );
    return (response as List).map((e) => CoffeeGuide.fromJson(e)).toList();
  }

  /// 가이드 검색
  Future<List<CoffeeGuide>> search(
    String query, {
    int? page,
    int? limit,
  }) async {
    final response = await _client.get(
      '/api/guides/search',
      queryParameters: {
        'q': query,
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
      },
    );
    return (response as List).map((e) => CoffeeGuide.fromJson(e)).toList();
  }

  /// 카테고리별 가이드 조회
  Future<List<CoffeeGuide>> getByCategory(
    String category, {
    int? page,
    int? limit,
  }) async {
    final response = await _client.get(
      '/api/guides/category',
      queryParameters: {
        'category': category,
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
      },
    );
    return (response as List).map((e) => CoffeeGuide.fromJson(e)).toList();
  }

  /// 난이도별 가이드 조회
  Future<List<CoffeeGuide>> getByDifficulty(
    String difficulty, {
    int? page,
    int? limit,
  }) async {
    final response = await _client.get(
      '/api/guides/difficulty',
      queryParameters: {
        'difficulty': difficulty,
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
      },
    );
    return (response as List).map((e) => CoffeeGuide.fromJson(e)).toList();
  }
}

/// Guide Collections API
class GuideCollectionsApi {
  final ApiClient _client = ApiClient();

  /// 컬렉션 트리 조회
  Future<List<CollectionWithChildren>> getTree() async {
    final response = await _client.get('/api/guide-collections');
    return (response as List)
        .map((e) => CollectionWithChildren.fromJson(e))
        .toList();
  }

  /// 컬렉션 상세 조회
  Future<GuideCollection> getById(String id) async {
    final response = await _client.get('/api/guide-collections/$id');
    return GuideCollection.fromJson(response);
  }

  /// 컬렉션 내 가이드 조회
  Future<List<CoffeeGuide>> getGuides(String id) async {
    final response = await _client.get('/api/guide-collections/$id/guides');
    return (response as List).map((e) => CoffeeGuide.fromJson(e)).toList();
  }
}

/// Guides API 싱글톤 인스턴스
final guidesApi = GuidesApi();
final guideCollectionsApi = GuideCollectionsApi();
