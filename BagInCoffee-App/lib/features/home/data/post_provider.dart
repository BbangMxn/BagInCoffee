import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api/api.dart';
import '../../../core/providers/auth_provider.dart';

/// 게시물 목록 Provider
final postsProvider = FutureProvider<List<PostWithAuthor>>((ref) async {
  try {
    return await postsApi.list();
  } catch (e) {
    print('Failed to fetch posts: $e');
    return [];
  }
});

/// 태그별 게시물 Provider
final postsByTagProvider = FutureProvider.family<List<PostWithAuthor>, String>((
  ref,
  tag,
) async {
  try {
    return await postsApi.list(tag: tag);
  } catch (e) {
    print('Failed to fetch posts by tag: $e');
    return [];
  }
});

/// 인기 게시물 Provider
final popularPostsProvider = FutureProvider<List<PostWithAuthor>>((ref) async {
  try {
    return await postsApi.getPopular();
  } catch (e) {
    print('Failed to fetch popular posts: $e');
    return [];
  }
});

/// 내 게시물 Provider
final myPostsProvider = FutureProvider<List<PostWithAuthor>>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  final user = supabase.auth.currentUser;
  if (user == null) return [];

  try {
    return await postsApi.getUserPosts(user.id);
  } catch (e) {
    print('Failed to fetch my posts: $e');
    return [];
  }
});

/// 게시물 상세 Provider
final postDetailProvider = FutureProvider.family<PostWithAuthor?, String>((
  ref,
  postId,
) async {
  try {
    return await postsApi.getById(postId);
  } catch (e) {
    print('Failed to fetch post detail: $e');
    return null;
  }
});

/// 게시물 검색 Provider
final searchPostsProvider = FutureProvider.family<List<Post>, String>((
  ref,
  query,
) async {
  try {
    return await postsApi.search(query);
  } catch (e) {
    print('Failed to search posts: $e');
    return [];
  }
});
