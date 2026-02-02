import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api/api.dart';

/// 카테고리 목록 Provider
final categoryListProvider =
    FutureProvider.family<CategoryListResponse, CategoryListParams>((
      ref,
      params,
    ) async {
      return await categoriesApi.list(
        locale: params.locale,
        parentId: params.parentId,
        level: params.level,
        isActive: params.isActive,
        search: params.search,
        page: params.page,
        limit: params.limit,
      );
    });

/// 카테고리 목록 파라미터
class CategoryListParams {
  final String? locale;
  final String? parentId;
  final int? level;
  final bool? isActive;
  final String? search;
  final int? page;
  final int? limit;

  const CategoryListParams({
    this.locale = 'ko',
    this.parentId,
    this.level,
    this.isActive,
    this.search,
    this.page,
    this.limit,
  });

  CategoryListParams copyWith({
    String? locale,
    String? parentId,
    int? level,
    bool? isActive,
    String? search,
    int? page,
    int? limit,
  }) {
    return CategoryListParams(
      locale: locale ?? this.locale,
      parentId: parentId ?? this.parentId,
      level: level ?? this.level,
      isActive: isActive ?? this.isActive,
      search: search ?? this.search,
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryListParams &&
        other.locale == locale &&
        other.parentId == parentId &&
        other.level == level &&
        other.isActive == isActive &&
        other.search == search &&
        other.page == page &&
        other.limit == limit;
  }

  @override
  int get hashCode =>
      Object.hash(locale, parentId, level, isActive, search, page, limit);
}

/// 루트 카테고리 목록 Provider (최상위 카테고리)
final rootCategoriesProvider = FutureProvider<List<ProductCategory>>((
  ref,
) async {
  return await categoriesApi.getRootCategories();
});

/// 하위 카테고리 목록 Provider
final subCategoriesProvider =
    FutureProvider.family<List<ProductCategory>, String>((ref, parentId) async {
      return await categoriesApi.getSubCategories(parentId);
    });

/// 단일 카테고리 상세 Provider
final categoryDetailProvider = FutureProvider.family<ProductCategory, String>((
  ref,
  categoryId,
) async {
  return await categoriesApi.get(categoryId);
});

/// 전체 카테고리 목록 Provider (활성화된 카테고리만)
final allCategoriesProvider = FutureProvider<List<ProductCategory>>((
  ref,
) async {
  final response = await categoriesApi.list(isActive: true, limit: 100);
  return response.data;
});
