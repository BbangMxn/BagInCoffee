import 'client.dart';

/// BagInDB Product Categories API
class CategoriesApi {
  final ApiClient _client;

  CategoriesApi([ApiClient? client]) : _client = client ?? ApiClient();

  /// 카테고리 목록 조회
  Future<CategoryListResponse> list({
    String? locale,
    String? parentId,
    int? level,
    bool? isActive,
    String? search,
    int? page,
    int? limit,
  }) async {
    final queryParams = <String, dynamic>{};

    if (locale != null) queryParams['locale'] = locale;
    if (parentId != null) queryParams['parent_id'] = parentId;
    if (level != null) queryParams['level'] = level;
    if (isActive != null) queryParams['is_active'] = isActive;
    if (search != null) queryParams['search'] = search;
    if (page != null) queryParams['page'] = page;
    if (limit != null) queryParams['limit'] = limit;

    final response = await _client.getBaginDb(
      '/api/categories',
      queryParameters: queryParams,
    );

    return CategoryListResponse.fromJson(response);
  }

  /// 단일 카테고리 조회
  Future<ProductCategory> get(String id) async {
    final response = await _client.getBaginDb('/api/categories/$id');
    return ProductCategory.fromJson(response['data']);
  }

  /// 루트 카테고리 조회 (level = 0)
  Future<List<ProductCategory>> getRootCategories() async {
    final response = await list(level: 0, isActive: true);
    return response.data;
  }

  /// 하위 카테고리 조회
  Future<List<ProductCategory>> getSubCategories(String parentId) async {
    final response = await list(parentId: parentId, isActive: true);
    return response.data;
  }
}

/// Category List Response
class CategoryListResponse {
  final List<ProductCategory> data;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  CategoryListResponse({
    required this.data,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory CategoryListResponse.fromJson(Map<String, dynamic> json) {
    return CategoryListResponse(
      data: (json['data'] as List)
          .map((e) => ProductCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: json['page'] as int? ?? 0,
      limit: json['limit'] as int? ?? 20,
      total: json['total'] as int? ?? 0,
      totalPages: json['total_pages'] as int? ?? 0,
    );
  }
}

/// Product Category Model
class ProductCategory {
  final String id;
  final String slug;
  final String? parentId;
  final int level;
  final String? path;
  final Map<String, dynamic> name;
  final Map<String, dynamic>? description;
  final String? specTableName;
  final Map<String, dynamic>? specSchema;
  final String? iconUrl;
  final String? imageUrl;
  final int productCount;
  final int displayOrder;
  final bool isActive;
  final bool isAccessory;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductCategory({
    required this.id,
    required this.slug,
    this.parentId,
    this.level = 0,
    this.path,
    required this.name,
    this.description,
    this.specTableName,
    this.specSchema,
    this.iconUrl,
    this.imageUrl,
    this.productCount = 0,
    this.displayOrder = 0,
    this.isActive = true,
    this.isAccessory = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['id'] as String,
      slug: json['slug'] as String,
      parentId: json['parent_id'] as String?,
      level: json['level'] as int? ?? 0,
      path: json['path'] as String?,
      name: json['name'] as Map<String, dynamic>,
      description: json['description'] as Map<String, dynamic>?,
      specTableName: json['spec_table_name'] as String?,
      specSchema: json['spec_schema'] as Map<String, dynamic>?,
      iconUrl: json['icon_url'] as String?,
      imageUrl: json['image_url'] as String?,
      productCount: json['product_count'] as int? ?? 0,
      displayOrder: json['display_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      isAccessory: json['is_accessory'] as bool? ?? false,
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
}

/// Global instance
final categoriesApi = CategoriesApi();
