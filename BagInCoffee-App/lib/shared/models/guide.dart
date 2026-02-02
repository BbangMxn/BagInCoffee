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

  factory GuideCategory.fromString(String value) {
    return GuideCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => GuideCategory.other,
    );
  }

  String get displayName {
    switch (this) {
      case GuideCategory.brewing:
        return '추출';
      case GuideCategory.beans:
        return '원두';
      case GuideCategory.equipment:
        return '장비';
      case GuideCategory.recipe:
        return '레시피';
      case GuideCategory.roasting:
        return '로스팅';
      case GuideCategory.barista:
        return '바리스타';
      case GuideCategory.science:
        return '과학';
      case GuideCategory.culture:
        return '문화';
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

  factory GuideDifficulty.fromString(String value) {
    return GuideDifficulty.values.firstWhere(
      (e) => e.name == value,
      orElse: () => GuideDifficulty.beginner,
    );
  }

  String get displayName {
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
  final List<GuideCollection>? children;
  final List<CoffeeGuide>? guides;

  const GuideCollection({
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
    this.children,
    this.guides,
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
      children: (json['children'] as List<dynamic>?)
          ?.map((e) => GuideCollection.fromJson(e as Map<String, dynamic>))
          .toList(),
      guides: (json['guides'] as List<dynamic>?)
          ?.map((e) => CoffeeGuide.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'description': description,
      'icon': icon,
      'cover_image': coverImage,
      'parent_id': parentId,
      'order_index': orderIndex,
      'published': published,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'children': children?.map((e) => e.toJson()).toList(),
      'guides': guides?.map((e) => e.toJson()).toList(),
    };
  }
}

/// 커피 가이드
class CoffeeGuide {
  final String id;
  final String title;
  final String slug;
  final String content;
  final String? excerpt;
  final GuideCategory category;
  final List<String> tags;
  final String? coverImage;
  final String? collectionId;
  final String? parentId;
  final int orderIndex;
  final bool published;
  final bool featured;
  final int viewsCount;
  final int? readingTimeMinutes;
  final GuideDifficulty? difficulty;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? publishedAt;

  const CoffeeGuide({
    required this.id,
    required this.title,
    required this.slug,
    required this.content,
    this.excerpt,
    required this.category,
    required this.tags,
    this.coverImage,
    this.collectionId,
    this.parentId,
    required this.orderIndex,
    required this.published,
    required this.featured,
    required this.viewsCount,
    this.readingTimeMinutes,
    this.difficulty,
    required this.createdAt,
    required this.updatedAt,
    this.publishedAt,
  });

  factory CoffeeGuide.fromJson(Map<String, dynamic> json) {
    return CoffeeGuide(
      id: json['id'] as String,
      title: json['title'] as String,
      slug: json['slug'] as String,
      content: json['content'] as String,
      excerpt: json['excerpt'] as String?,
      category: GuideCategory.fromString(
        json['category'] as String? ?? 'other',
      ),
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          [],
      coverImage: json['cover_image'] as String?,
      collectionId: json['collection_id'] as String?,
      parentId: json['parent_id'] as String?,
      orderIndex: json['order_index'] as int? ?? 0,
      published: json['published'] as bool? ?? false,
      featured: json['featured'] as bool? ?? false,
      viewsCount: json['views_count'] as int? ?? 0,
      readingTimeMinutes: json['reading_time_minutes'] as int?,
      difficulty: json['difficulty'] != null
          ? GuideDifficulty.fromString(json['difficulty'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      publishedAt: json['published_at'] != null
          ? DateTime.parse(json['published_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'content': content,
      'excerpt': excerpt,
      'category': category.name,
      'tags': tags,
      'cover_image': coverImage,
      'collection_id': collectionId,
      'parent_id': parentId,
      'order_index': orderIndex,
      'published': published,
      'featured': featured,
      'views_count': viewsCount,
      'reading_time_minutes': readingTimeMinutes,
      'difficulty': difficulty?.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'published_at': publishedAt?.toIso8601String(),
    };
  }
}
