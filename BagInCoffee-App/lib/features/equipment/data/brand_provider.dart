import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api/api.dart';

/// 브랜드 목록 Provider
final brandListProvider =
    FutureProvider.family<BrandListResponse, BrandListParams>((
      ref,
      params,
    ) async {
      return await brandsApi.list(
        slug: params.slug,
        country: params.country,
        isActive: params.isActive,
        featured: params.featured,
        verified: params.verified,
        specialization: params.specialization,
        search: params.search,
        page: params.page,
        limit: params.limit,
      );
    });

/// 브랜드 목록 파라미터
class BrandListParams {
  final String? slug;
  final String? country;
  final bool? isActive;
  final bool? featured;
  final bool? verified;
  final String? specialization;
  final String? search;
  final int? page;
  final int? limit;

  const BrandListParams({
    this.slug,
    this.country,
    this.isActive,
    this.featured,
    this.verified,
    this.specialization,
    this.search,
    this.page,
    this.limit,
  });

  BrandListParams copyWith({
    String? slug,
    String? country,
    bool? isActive,
    bool? featured,
    bool? verified,
    String? specialization,
    String? search,
    int? page,
    int? limit,
  }) {
    return BrandListParams(
      slug: slug ?? this.slug,
      country: country ?? this.country,
      isActive: isActive ?? this.isActive,
      featured: featured ?? this.featured,
      verified: verified ?? this.verified,
      specialization: specialization ?? this.specialization,
      search: search ?? this.search,
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BrandListParams &&
        other.slug == slug &&
        other.country == country &&
        other.isActive == isActive &&
        other.featured == featured &&
        other.verified == verified &&
        other.specialization == specialization &&
        other.search == search &&
        other.page == page &&
        other.limit == limit;
  }

  @override
  int get hashCode => Object.hash(
    slug,
    country,
    isActive,
    featured,
    verified,
    specialization,
    search,
    page,
    limit,
  );
}

/// 전체 브랜드 목록 Provider (활성화된 브랜드만)
final allBrandsProvider = FutureProvider<List<Brand>>((ref) async {
  final response = await brandsApi.list(isActive: true, limit: 100);
  return response.data;
});

/// Featured 브랜드 목록 Provider
final featuredBrandsProvider = FutureProvider<List<Brand>>((ref) async {
  final response = await brandsApi.list(featured: true, isActive: true);
  return response.data;
});

/// 단일 브랜드 상세 Provider
final brandDetailProvider = FutureProvider.family<Brand, String>((
  ref,
  brandId,
) async {
  return await brandsApi.get(brandId);
});

/// 브랜드 검색 Provider
final brandSearchProvider = FutureProvider.family<BrandListResponse, String>((
  ref,
  query,
) async {
  return await brandsApi.list(search: query, isActive: true, limit: 50);
});

/// 국가별 브랜드 목록 Provider
final brandsByCountryProvider =
    FutureProvider.family<BrandListResponse, String>((ref, country) async {
      return await brandsApi.list(country: country, isActive: true, limit: 50);
    });
