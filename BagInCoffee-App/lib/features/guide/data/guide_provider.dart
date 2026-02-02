import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api/api.dart';

/// 가이드 목록 Provider
final guidesProvider = FutureProvider<List<CoffeeGuide>>((ref) async {
  try {
    return await guidesApi.list();
  } catch (e) {
    if (kDebugMode) print('❌ Failed to fetch guides: $e');
    return [];
  }
});

/// Featured 가이드 Provider
final featuredGuidesProvider = FutureProvider<List<CoffeeGuide>>((ref) async {
  try {
    return await guidesApi.getFeatured();
  } catch (e) {
    if (kDebugMode) print('❌ Failed to fetch featured guides: $e');
    return [];
  }
});

/// 인기 가이드 Provider
final popularGuidesProvider = FutureProvider<List<CoffeeGuide>>((ref) async {
  try {
    return await guidesApi.getPopular();
  } catch (e) {
    if (kDebugMode) print('❌ Failed to fetch popular guides: $e');
    return [];
  }
});

/// 최근 가이드 Provider
final recentGuidesProvider = FutureProvider<List<CoffeeGuide>>((ref) async {
  try {
    return await guidesApi.getRecent();
  } catch (e) {
    if (kDebugMode) print('❌ Failed to fetch recent guides: $e');
    return [];
  }
});

/// 카테고리별 가이드 Provider
final guidesByCategoryProvider =
    FutureProvider.family<List<CoffeeGuide>, String>((ref, category) async {
      try {
        return await guidesApi.getByCategory(category);
      } catch (e) {
        if (kDebugMode) print('❌ Failed to fetch guides by category: $e');
        return [];
      }
    });

/// 난이도별 가이드 Provider
final guidesByDifficultyProvider =
    FutureProvider.family<List<CoffeeGuide>, String>((ref, difficulty) async {
      try {
        return await guidesApi.getByDifficulty(difficulty);
      } catch (e) {
        if (kDebugMode) print('❌ Failed to fetch guides by difficulty: $e');
        return [];
      }
    });

/// 단일 가이드 Provider
final guideDetailProvider = FutureProvider.family<CoffeeGuide?, String>((
  ref,
  guideId,
) async {
  try {
    return await guidesApi.getById(guideId);
  } catch (e) {
    if (kDebugMode) print('❌ Failed to fetch guide detail: $e');
    return null;
  }
});

/// 가이드 검색 Provider
final searchGuidesProvider = FutureProvider.family<List<CoffeeGuide>, String>((
  ref,
  query,
) async {
  try {
    return await guidesApi.search(query);
  } catch (e) {
    if (kDebugMode) print('❌ Failed to search guides: $e');
    return [];
  }
});

/// 가이드 컬렉션 트리 Provider
final guideCollectionsProvider = FutureProvider<List<CollectionWithChildren>>((
  ref,
) async {
  try {
    return await guideCollectionsApi.getTree();
  } catch (e) {
    if (kDebugMode) print('❌ Failed to fetch guide collections: $e');
    return [];
  }
});

/// 컬렉션 내 가이드 Provider
final guidesByCollectionProvider =
    FutureProvider.family<List<CoffeeGuide>, String>((ref, collectionId) async {
      try {
        return await guideCollectionsApi.getGuides(collectionId);
      } catch (e) {
        if (kDebugMode) print('❌ Failed to fetch guides by collection: $e');
        return [];
      }
    });
