import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api/api.dart';

/// 제품 목록 Provider
final productListProvider =
    FutureProvider.family<ProductListResponse, ProductListParams>((
      ref,
      params,
    ) async {
      return await productsApi.list(
        locale: params.locale,
        categoryId: params.categoryId,
        brandId: params.brandId,
        isVerified: params.isVerified,
        search: params.search,
        page: params.page,
        limit: params.limit,
        priceMin: params.priceMin,
        priceMax: params.priceMax,
        currency: params.currency,
        sortBy: params.sortBy,
        order: params.order,
        specFilters: params.specFilters,
      );
    });

/// 제품 목록 파라미터
class ProductListParams {
  final String? locale;
  final String? categoryId;
  final String? brandId;
  final bool? isVerified;
  final String? search;
  final int? page;
  final int? limit;
  final int? priceMin;
  final int? priceMax;
  final String? currency;
  final String? sortBy;
  final String? order;
  final Map<String, String>? specFilters;

  const ProductListParams({
    this.locale = 'ko',
    this.categoryId,
    this.brandId,
    this.isVerified,
    this.search,
    this.page,
    this.limit,
    this.priceMin,
    this.priceMax,
    this.currency,
    this.sortBy,
    this.order,
    this.specFilters,
  });

  ProductListParams copyWith({
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
  }) {
    return ProductListParams(
      locale: locale ?? this.locale,
      categoryId: categoryId ?? this.categoryId,
      brandId: brandId ?? this.brandId,
      isVerified: isVerified ?? this.isVerified,
      search: search ?? this.search,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      priceMin: priceMin ?? this.priceMin,
      priceMax: priceMax ?? this.priceMax,
      currency: currency ?? this.currency,
      sortBy: sortBy ?? this.sortBy,
      order: order ?? this.order,
      specFilters: specFilters ?? this.specFilters,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductListParams &&
        other.locale == locale &&
        other.categoryId == categoryId &&
        other.brandId == brandId &&
        other.isVerified == isVerified &&
        other.search == search &&
        other.page == page &&
        other.limit == limit &&
        other.priceMin == priceMin &&
        other.priceMax == priceMax &&
        other.currency == currency &&
        other.sortBy == sortBy &&
        other.order == order;
  }

  @override
  int get hashCode => Object.hash(
    locale,
    categoryId,
    brandId,
    isVerified,
    search,
    page,
    limit,
    priceMin,
    priceMax,
    currency,
    sortBy,
    order,
  );
}

/// 단일 제품 상세 Provider
final productDetailProvider = FutureProvider.family<Product, String>((
  ref,
  productId,
) async {
  return await productsApi.get(productId);
});

/// 제품 스펙 Provider
final productSpecsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, productId) async {
      return await productsApi.getSpecs(productId);
    });

/// 브랜드별 제품 목록 Provider
final productsByBrandProvider =
    FutureProvider.family<ProductListResponse, String>((ref, brandId) async {
      return await productsApi.list(brandId: brandId, limit: 50);
    });

/// 카테고리별 제품 목록 Provider
final productsByCategoryProvider =
    FutureProvider.family<ProductListResponse, String>((ref, categoryId) async {
      return await productsApi.list(categoryId: categoryId, limit: 50);
    });

/// 제품 검색 Provider
final productSearchProvider =
    FutureProvider.family<ProductListResponse, String>((ref, query) async {
      return await productsApi.list(search: query, limit: 50);
    });

/// 제품 가격 추이 Provider (캐싱됨)
final productPriceHistoryProvider =
    FutureProvider.family<List<ProductPricing>, String>((ref, productId) async {
      return await ProductsApi().getPriceHistory(productId);
    });
