import 'client.dart';

/// BagInDB Brands API
class BrandsApi {
  final ApiClient _client;

  BrandsApi([ApiClient? client]) : _client = client ?? ApiClient();

  /// 브랜드 목록 조회
  Future<BrandListResponse> list({
    String? slug,
    String? country,
    bool? isActive,
    bool? featured,
    bool? verified,
    String? specialization,
    String? search,
    int? page,
    int? limit,
  }) async {
    final queryParams = <String, dynamic>{};

    if (slug != null) queryParams['slug'] = slug;
    if (country != null) queryParams['country'] = country;
    if (isActive != null) queryParams['is_active'] = isActive;
    if (featured != null) queryParams['featured'] = featured;
    if (verified != null) queryParams['verified'] = verified;
    if (specialization != null) queryParams['specialization'] = specialization;
    if (search != null) queryParams['search'] = search;
    if (page != null) queryParams['page'] = page;
    if (limit != null) queryParams['limit'] = limit;

    final response = await _client.getBaginDb(
      '/api/brands',
      queryParameters: queryParams,
    );

    return BrandListResponse.fromJson(response);
  }

  /// 단일 브랜드 조회
  Future<Brand> get(String id) async {
    final response = await _client.getBaginDb('/api/brands/$id');
    return Brand.fromJson(response['data']);
  }
}

/// Brand List Response
class BrandListResponse {
  final List<Brand> data;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  BrandListResponse({
    required this.data,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory BrandListResponse.fromJson(Map<String, dynamic> json) {
    return BrandListResponse(
      data: (json['data'] as List)
          .map((e) => Brand.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: json['page'] as int? ?? 0,
      limit: json['limit'] as int? ?? 20,
      total: json['total'] as int? ?? 0,
      totalPages: json['total_pages'] as int? ?? 0,
    );
  }
}

/// Brand Model
class Brand {
  final String id;
  final String slug;
  final Map<String, dynamic> name;
  final Map<String, dynamic>? description;
  final Map<String, dynamic>? headquarters;
  final String? logoUrl;
  final List<String>? images;
  final String? website;
  final String? country;
  final DateTime? foundedDate;
  final int? foundedYear;
  final List<String>? specialization;
  final bool isActive;
  final bool featured;
  final bool verified;
  final List<String>? availableLocales;
  final String? defaultLocale;
  final DateTime createdAt;
  final DateTime updatedAt;

  Brand({
    required this.id,
    required this.slug,
    required this.name,
    this.description,
    this.headquarters,
    this.logoUrl,
    this.images,
    this.website,
    this.country,
    this.foundedDate,
    this.foundedYear,
    this.specialization,
    this.isActive = true,
    this.featured = false,
    this.verified = false,
    this.availableLocales,
    this.defaultLocale,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['id'] as String,
      slug: json['slug'] as String,
      name: json['name'] as Map<String, dynamic>,
      description: json['description'] as Map<String, dynamic>?,
      headquarters: json['headquarters'] as Map<String, dynamic>?,
      logoUrl: json['logo_url'] as String?,
      images: (json['images'] as List<dynamic>?)?.cast<String>(),
      website: json['website'] as String?,
      country: json['country'] as String?,
      foundedDate: json['founded_date'] != null
          ? DateTime.parse(json['founded_date'] as String)
          : null,
      foundedYear: json['founded_year'] as int?,
      specialization: (json['specialization'] as List<dynamic>?)
          ?.cast<String>(),
      isActive: json['is_active'] as bool? ?? true,
      featured: json['featured'] as bool? ?? false,
      verified: json['verified'] as bool? ?? false,
      availableLocales: (json['available_locales'] as List<dynamic>?)
          ?.cast<String>(),
      defaultLocale: json['default_locale'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// 현재 로케일에 맞는 이름
  String getLocalizedName([String locale = 'ko']) {
    return name[locale] as String? ?? name['en'] as String? ?? slug;
  }

  /// 현재 로케일에 맞는 설명
  String? getLocalizedDescription([String locale = 'ko']) {
    if (description == null) return null;
    return description![locale] as String? ?? description!['en'] as String?;
  }

  /// 현재 로케일에 맞는 본사 위치
  String? getLocalizedHeadquarters([String locale = 'ko']) {
    if (headquarters == null) return null;
    return headquarters![locale] as String? ?? headquarters!['en'] as String?;
  }

  /// 국가 이모지
  String? get countryEmoji {
    if (country == null) return null;
    final countryEmojis = {
      'IT': '🇮🇹',
      'DE': '🇩🇪',
      'US': '🇺🇸',
      'JP': '🇯🇵',
      'KR': '🇰🇷',
      'CH': '🇨🇭',
      'UK': '🇬🇧',
      'GB': '🇬🇧',
      'FR': '🇫🇷',
      'NL': '🇳🇱',
      'AU': '🇦🇺',
      'CA': '🇨🇦',
      'ES': '🇪🇸',
      'CN': '🇨🇳',
      'TW': '🇹🇼',
    };
    return countryEmojis[country?.toUpperCase()];
  }
}

/// Global instance
final brandsApi = BrandsApi();
