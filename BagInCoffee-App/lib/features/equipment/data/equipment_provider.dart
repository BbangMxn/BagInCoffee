import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../api/products.dart';
import 'equipment_model.dart';

/// 장비 목록 Provider - Rust API 사용
final equipmentListProvider = FutureProvider<List<Product>>((ref) async {
  try {
    if (kDebugMode) print('📦 장비 목록 로딩 시작...');
    final response = await productsApi.list(
      locale: 'ko',
      limit: 100,
      sortBy: 'created_at',
      order: 'desc',
    );
    if (kDebugMode) print('✅ 장비 ${response.data.length}개 로드 완료');
    return response.data;
  } catch (e) {
    if (kDebugMode) print('❌ 장비 목록 로드 실패: $e');
    rethrow; // 에러를 다시 던져서 UI에서 처리
  }
});

/// 내 판매 목록 Provider
final myEquipmentListProvider = FutureProvider<List<EquipmentItem>>((
  ref,
) async {
  final supabase = ref.watch(supabaseProvider);
  final user = supabase.auth.currentUser;
  if (user == null) return [];

  final response = await supabase
      .from('marketplace_items')
      .select('''
        *,
        seller:profiles!marketplace_items_seller_id_fkey(id, username, avatar_url)
      ''')
      .eq('seller_id', user.id)
      .order('created_at', ascending: false);

  return (response as List).map((e) => EquipmentItem.fromJson(e)).toList();
});

/// 상태별 장비 목록 Provider
final equipmentByStatusProvider =
    FutureProvider.family<List<EquipmentItem>, String>((ref, status) async {
      final supabase = ref.watch(supabaseProvider);

      final response = await supabase
          .from('marketplace_items')
          .select('''
        *,
        seller:profiles!marketplace_items_seller_id_fkey(id, username, avatar_url)
      ''')
          .eq('status', status)
          .order('created_at', ascending: false);

      return (response as List).map((e) => EquipmentItem.fromJson(e)).toList();
    });

/// 단일 장비 상세 Provider
final equipmentDetailProvider = FutureProvider.family<EquipmentItem?, String>((
  ref,
  itemId,
) async {
  final supabase = ref.watch(supabaseProvider);

  final response = await supabase
      .from('marketplace_items')
      .select('''
        *,
        seller:profiles!marketplace_items_seller_id_fkey(id, username, avatar_url)
      ''')
      .eq('id', itemId)
      .single();

  return EquipmentItem.fromJson(response);
});

/// 검색 Provider
final equipmentSearchProvider =
    FutureProvider.family<List<EquipmentItem>, String>((ref, query) async {
      final supabase = ref.watch(supabaseProvider);

      final response = await supabase
          .from('marketplace_items')
          .select('''
        *,
        seller:profiles!marketplace_items_seller_id_fkey(id, username, avatar_url)
      ''')
          .eq('status', 'active')
          .ilike('title', '%$query%')
          .order('created_at', ascending: false);

      return (response as List).map((e) => EquipmentItem.fromJson(e)).toList();
    });
