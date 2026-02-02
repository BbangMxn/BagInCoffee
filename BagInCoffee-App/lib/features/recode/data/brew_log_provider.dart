import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api/api.dart';
import '../../../core/providers/auth_provider.dart';

/// 내 추출 기록 Provider
final myBrewLogsProvider = FutureProvider<List<Recode>>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  final user = supabase.auth.currentUser;
  if (user == null) return [];

  try {
    return await recodesApi.list();
  } catch (e) {
    print('Failed to fetch brew logs: $e');
    return [];
  }
});

/// 즐겨찾기 추출 기록 Provider
final favoriteBrewLogsProvider = FutureProvider<List<Recode>>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  final user = supabase.auth.currentUser;
  if (user == null) return [];

  try {
    return await recodesApi.getFavorites();
  } catch (e) {
    print('Failed to fetch favorite brew logs: $e');
    return [];
  }
});

/// 추출 방법별 기록 Provider
final brewLogsByMethodProvider = FutureProvider.family<List<Recode>, String>((
  ref,
  method,
) async {
  final supabase = ref.watch(supabaseProvider);
  final user = supabase.auth.currentUser;
  if (user == null) return [];

  try {
    return await recodesApi.getByBrewMethod(method);
  } catch (e) {
    print('Failed to fetch brew logs by method: $e');
    return [];
  }
});

/// 원두별 기록 Provider
final brewLogsByBeanProvider = FutureProvider.family<List<Recode>, String>((
  ref,
  bean,
) async {
  final supabase = ref.watch(supabaseProvider);
  final user = supabase.auth.currentUser;
  if (user == null) return [];

  try {
    return await recodesApi.getByBean(bean);
  } catch (e) {
    print('Failed to fetch brew logs by bean: $e');
    return [];
  }
});

/// 단일 추출 기록 Provider
final brewLogDetailProvider = FutureProvider.family<Recode?, String>((
  ref,
  logId,
) async {
  final supabase = ref.watch(supabaseProvider);
  final user = supabase.auth.currentUser;
  if (user == null) return null;

  try {
    return await recodesApi.getById(logId);
  } catch (e) {
    print('Failed to fetch brew log detail: $e');
    return null;
  }
});

/// 추출 기록 검색 Provider
final searchBrewLogsProvider = FutureProvider.family<List<Recode>, String>((
  ref,
  query,
) async {
  final supabase = ref.watch(supabaseProvider);
  final user = supabase.auth.currentUser;
  if (user == null) return [];

  try {
    return await recodesApi.search(query);
  } catch (e) {
    print('Failed to search brew logs: $e');
    return [];
  }
});
