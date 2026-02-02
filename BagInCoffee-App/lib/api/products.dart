import 'client.dart';

/// BagInDB Products API
class ProductsApi {
  final ApiClient _client;

  ProductsApi([ApiClient? client]) : _client = client ?? ApiClient();

  /// 제품 목록 조회
  Future<ProductListResponse> list({
    String? locale,
    String? categoryId,
    String? brandId,
    bool? isVerified,
    String? search,
    int? page,
    int? limit,
    int? priceMin,
    int? priceMax,
    String? currency,
    String? sortBy,
    String? order,
    Map<String, String>? specFilters,
  }) async {
    final queryParams = <String, dynamic>{};

    if (locale != null) queryParams['locale'] = locale;
    if (categoryId != null) queryParams['category_id'] = categoryId;
    if (brandId != null) queryParams['brand_id'] = brandId;
    if (isVerified != null) queryParams['is_verified'] = isVerified;
    if (search != null) queryParams['search'] = search;
    if (page != null) queryParams['page'] = page;
    if (limit != null) queryParams['limit'] = limit;
    if (priceMin != null) queryParams['price_min'] = priceMin;
    if (priceMax != null) queryParams['price_max'] = priceMax;
    if (currency != null) queryParams['currency'] = currency;
    if (sortBy != null) queryParams['sort_by'] = sortBy;
    if (order != null) queryParams['order'] = order;

    // spec_* 필터 추가
    if (specFilters != null) {
      queryParams.addAll(specFilters);
    }

    final response = await _client.getBaginDb(
      '/api/products',
      queryParameters: queryParams,
    );

    // API가 배열을 직접 반환하는지, 객체를 반환하는지 확인
    if (response is List) {
      // 배열을 직접 반환하는 경우
      final products = <Product>[];
      for (final item in response) {
        if (item is Map<String, dynamic>) {
          products.add(Product.fromJson(item));
        }
      }

      return ProductListResponse(
        data: products,
        page: page ?? 1,
        limit: limit ?? 20,
        total: products.length,
        totalPages: 1,
      );
    } else if (response is Map<String, dynamic>) {
      // 객체를 반환하는 경우
      return ProductListResponse.fromJson(response);
    } else {
      // 예상치 못한 응답 형식
      throw Exception('Unexpected response format: ${response.runtimeType}');
    }
  }

  /// 단일 제품 조회
  Future<Product> get(String id) async {
    final response = await _client.getBaginDb('/api/products/$id');
    return Product.fromJson(response['data']);
  }

  /// 제품 스펙 조회
  Future<Map<String, dynamic>> getSpecs(String id) async {
    final response = await _client.getBaginDb('/api/products/$id/specs');
    return response['data'] as Map<String, dynamic>;
  }

  /// 제품 가격 추이 조회
  Future<List<ProductPricing>> getPriceHistory(String productId) async {
    try {
      final response = await _client.getBaginDb(
        '/api/products/$productId/pricing/history',
      );

      if (response is Map && response['data'] is List) {
        return (response['data'] as List)
            .map(
              (json) => ProductPricing.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}

/// Product List Response
class ProductListResponse {
  final List<Product> data;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  ProductListResponse({
    required this.data,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory ProductListResponse.fromJson(Map<String, dynamic> json) {
    return ProductListResponse(
      data: (json['data'] as List)
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: json['page'] as int? ?? 0,
      limit: json['limit'] as int? ?? 20,
      total: json['total'] as int? ?? 0,
      totalPages: json['total_pages'] as int? ?? 0,
    );
  }
}

/// Product Model
class Product {
  final String id;
  final String slug;
  final String categoryId;
  final String brandId;
  final Map<String, dynamic> name;
  final Map<String, dynamic>? description;
  final String? modelNumber;
  final Map<String, dynamic>? identifiers;
  final String? imageUrl;
  final List<String>? images;
  final String? manufacturerCountry;
  final DateTime? releaseDate;
  final DateTime? discontinuedDate;
  final int viewCount;
  final int editCount;
  final bool isVerified;
  final List<String> availableLocales;
  final String defaultLocale;
  final Map<String, dynamic>? dimensions;
  final Map<String, dynamic>? weight;
  final int? powerWatts;
  final String? voltage;
  final Map<String, dynamic>? specs;
  final int? currentPriceMin;
  final int? currentPriceMax;
  final String? currentPriceCurrency;
  final DateTime? currentPriceUpdatedAt;
  final Map<String, dynamic>? purchaseLinks;
  final String? officialUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.slug,
    required this.categoryId,
    required this.brandId,
    required this.name,
    this.description,
    this.modelNumber,
    this.identifiers,
    this.imageUrl,
    this.images,
    this.manufacturerCountry,
    this.releaseDate,
    this.discontinuedDate,
    this.viewCount = 0,
    this.editCount = 0,
    this.isVerified = false,
    this.availableLocales = const ['ko', 'en'],
    this.defaultLocale = 'ko',
    this.dimensions,
    this.weight,
    this.powerWatts,
    this.voltage,
    this.specs,
    this.currentPriceMin,
    this.currentPriceMax,
    this.currentPriceCurrency,
    this.currentPriceUpdatedAt,
    this.purchaseLinks,
    this.officialUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // name 필드를 안전하게 변환
    Map<String, dynamic> parseName(dynamic value) {
      if (value is Map<String, dynamic>) return value;
      if (value is String) return {'ko': value, 'en': value};
      return {'ko': '', 'en': ''};
    }

    // description 필드를 안전하게 변환
    Map<String, dynamic>? parseDescription(dynamic value) {
      if (value == null) return null;
      if (value is Map<String, dynamic>) return value;
      if (value is String) return {'ko': value, 'en': value};
      return null;
    }

    // Map 타입 필드를 안전하게 변환
    Map<String, dynamic>? parseMap(dynamic value) {
      if (value == null) return null;
      if (value is Map<String, dynamic>) return value;
      return null;
    }

    return Product(
      id: json['id'] as String,
      slug: json['slug'] as String,
      categoryId: json['category_id'] as String,
      brandId: json['brand_id'] as String,
      name: parseName(json['name']),
      description: parseDescription(json['description']),
      modelNumber: json['model_number'] as String?,
      identifiers: parseMap(json['identifiers']),
      imageUrl: json['image_url'] as String?,
      images: (json['images'] as List<dynamic>?)?.cast<String>(),
      manufacturerCountry: json['manufacturer_country'] as String?,
      releaseDate: json['release_date'] != null
          ? DateTime.parse(json['release_date'] as String)
          : null,
      discontinuedDate: json['discontinued_date'] != null
          ? DateTime.parse(json['discontinued_date'] as String)
          : null,
      viewCount: json['view_count'] as int? ?? 0,
      editCount: json['edit_count'] as int? ?? 0,
      isVerified: json['is_verified'] as bool? ?? false,
      availableLocales:
          (json['available_locales'] as List<dynamic>?)?.cast<String>() ??
          ['ko', 'en'],
      defaultLocale: json['default_locale'] as String? ?? 'ko',
      dimensions: parseMap(json['dimensions']),
      weight: parseMap(json['weight']),
      powerWatts: json['power_watts'] as int?,
      voltage: json['voltage'] as String?,
      specs: parseMap(json['specs']),
      currentPriceMin: json['current_price_min'] as int?,
      currentPriceMax: json['current_price_max'] as int?,
      currentPriceCurrency: json['current_price_currency'] as String?,
      currentPriceUpdatedAt: json['current_price_updated_at'] != null
          ? DateTime.parse(json['current_price_updated_at'] as String)
          : null,
      purchaseLinks: parseMap(json['purchase_links']),
      officialUrl: json['official_url'] as String?,
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

  /// 가격 범위 포맷
  String? get formattedPriceRange {
    if (currentPriceMin == null && currentPriceMax == null) return null;

    final currency = currentPriceCurrency ?? 'KRW';
    final symbol = currency == 'KRW' ? '₩' : '\$';

    if (currentPriceMin == currentPriceMax || currentPriceMax == null) {
      return '$symbol${_formatNumber(currentPriceMin!)}';
    }

    if (currentPriceMin == null) {
      return '~$symbol${_formatNumber(currentPriceMax!)}';
    }

    return '$symbol${_formatNumber(currentPriceMin!)} ~ $symbol${_formatNumber(currentPriceMax!)}';
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}

/// 가격 추이 모델
class ProductPricing {
  final String id;
  final String productId;
  final String? currency;
  final int? price;
  final String? market;
  final String? marketplace;
  final String? priceType;
  final DateTime? validFrom;
  final DateTime? validUntil;
  final String? source;
  final String? notes;
  final bool isCurrent;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductPricing({
    required this.id,
    required this.productId,
    this.currency,
    this.price,
    this.market,
    this.marketplace,
    this.priceType,
    this.validFrom,
    this.validUntil,
    this.source,
    this.notes,
    required this.isCurrent,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductPricing.fromJson(Map<String, dynamic> json) {
    return ProductPricing(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      currency: json['currency'] as String?,
      price: json['price'] as int?,
      market: json['market'] as String?,
      marketplace: json['marketplace'] as String?,
      priceType: json['price_type'] as String?,
      validFrom: json['valid_from'] != null
          ? DateTime.parse(json['valid_from'] as String)
          : null,
      validUntil: json['valid_until'] != null
          ? DateTime.parse(json['valid_until'] as String)
          : null,
      source: json['source'] as String?,
      notes: json['notes'] as String?,
      isCurrent: json['is_current'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// 가격 포맷
  String get formattedPrice {
    if (price == null) return '-';
    final symbol = currency == 'KRW' ? '₩' : '\$';
    return '$symbol${_formatNumber(price!)}';
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}

/// Global instance
final productsApi = ProductsApi();
