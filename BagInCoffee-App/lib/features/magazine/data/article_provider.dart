import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api/api.dart';

/// 매거진 기사 목록 Provider
final articlesProvider = FutureProvider<List<NewsArticle>>((ref) async {
  try {
    return await newsApi.listPublished();
  } catch (e) {
    print('Failed to fetch articles: $e');
    return [];
  }
});

/// 인기 기사 Provider
final popularArticlesProvider = FutureProvider<List<NewsArticle>>((ref) async {
  try {
    return await newsApi.listPublished(limit: 10);
  } catch (e) {
    print('Failed to fetch popular articles: $e');
    return [];
  }
});

/// 최근 기사 Provider
final recentArticlesProvider = FutureProvider<List<NewsArticle>>((ref) async {
  try {
    return await newsApi.listPublished(limit: 20);
  } catch (e) {
    print('Failed to fetch recent articles: $e');
    return [];
  }
});

/// 단일 기사 Provider
final articleDetailProvider = FutureProvider.family<NewsArticle?, String>((
  ref,
  articleId,
) async {
  try {
    return await newsApi.getById(articleId);
  } catch (e) {
    print('Failed to fetch article detail: $e');
    return null;
  }
});

/// 기사 검색 Provider
final searchArticlesProvider = FutureProvider.family<List<NewsArticle>, String>(
  (ref, query) async {
    try {
      return await newsApi.search(query);
    } catch (e) {
      print('Failed to search articles: $e');
      return [];
    }
  },
);

/// 태그별 기사 Provider
final articlesByTagProvider = FutureProvider.family<List<NewsArticle>, String>((
  ref,
  tag,
) async {
  try {
    return await newsApi.getByTag(tag);
  } catch (e) {
    print('Failed to fetch articles by tag: $e');
    return [];
  }
});
