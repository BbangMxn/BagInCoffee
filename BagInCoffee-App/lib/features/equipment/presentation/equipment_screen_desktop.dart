import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../api/products.dart';
import '../data/equipment_provider.dart';

/// PC 버전 장비 마켓 화면 (Uber 디자인)
/// - 넓은 그리드 레이아웃 (4-5열)
/// - 큰 검색바
/// - 필터 사이드바
class EquipmentScreenDesktop extends ConsumerStatefulWidget {
  const EquipmentScreenDesktop({super.key});

  @override
  ConsumerState<EquipmentScreenDesktop> createState() =>
      _EquipmentScreenDesktopState();
}

class _EquipmentScreenDesktopState
    extends ConsumerState<EquipmentScreenDesktop> {
  final _searchController = TextEditingController();
  String? _selectedCategory;
  String? _selectedBrand;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final equipmentAsync = ref.watch(equipmentListProvider);

    return Container(
      color: Colors.white,
      child: Row(
        children: [
          // 왼쪽: 필터 사이드바 (선택적, 280px)
          Container(
            width: 280,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                right: BorderSide(color: AppColors.gray200, width: 1),
              ),
            ),
            child: _buildFilterSidebar(),
          ),

          // 중앙: 메인 콘텐츠
          Expanded(
            child: Column(
              children: [
                // 헤더 & 검색
                _buildHeader(),

                // 장비 그리드
                Expanded(
                  child: equipmentAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    error: (error, stack) => _ErrorView(
                      onRetry: () => ref.invalidate(equipmentListProvider),
                    ),
                    data: (products) {
                      if (products.isEmpty) {
                        return const _EmptyState();
                      }

                      // 검색 필터링
                      var filteredProducts = products;
                      if (_searchController.text.isNotEmpty) {
                        final query = _searchController.text.toLowerCase();
                        filteredProducts = products.where((p) {
                          final name = p.getLocalizedName().toLowerCase();
                          return name.contains(query);
                        }).toList();
                      }

                      return _buildProductGrid(filteredProducts);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.gray200, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 타이틀
          Text(
            'Coffee Equipment',
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '전문가들이 사용하는 커피 장비를 탐색해보세요',
            style: GoogleFonts.notoSansKr(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // 검색바
          Container(
            constraints: const BoxConstraints(maxWidth: 600),
            decoration: BoxDecoration(
              color: AppColors.gray50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gray200),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search equipment...',
                hintStyle: GoogleFonts.inter(
                  fontSize: 15,
                  color: AppColors.textTertiary,
                ),
                prefixIcon: const Icon(
                  LucideIcons.search,
                  size: 20,
                  color: AppColors.gray500,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(LucideIcons.x, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSidebar() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Filters',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 24),

        // 카테고리
        Text(
          'CATEGORY',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textTertiary,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 12),
        _FilterItem(label: 'Espresso Machines', count: 45),
        _FilterItem(label: 'Grinders', count: 32),
        _FilterItem(label: 'Brewers', count: 28),
        _FilterItem(label: 'Accessories', count: 67),

        const SizedBox(height: 32),

        // 브랜드
        Text(
          'BRAND',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textTertiary,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 12),
        _FilterItem(label: 'La Marzocco', count: 12),
        _FilterItem(label: 'Mahlkönig', count: 8),
        _FilterItem(label: 'Rocket', count: 15),
        _FilterItem(label: 'Breville', count: 22),
      ],
    );
  }

  Widget _buildProductGrid(List<Product> products) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(equipmentListProvider);
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(32),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4, // 4열 그리드
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 0.75,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return RepaintBoundary(
            child: _ProductCardDesktop(product: products[index]),
          );
        },
      ),
    );
  }
}

/// 필터 아이템
class _FilterItem extends StatelessWidget {
  final String label;
  final int count;

  const _FilterItem({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Text(
              '$count',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// PC 버전 제품 카드 (Uber 미니멀 스타일)
class _ProductCardDesktop extends StatelessWidget {
  final Product product;

  const _ProductCardDesktop({required this.product});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/products/${product.id}'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gray200, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: product.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: product.imageUrl!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        memCacheWidth: 500,
                        memCacheHeight: 500,
                        fadeInDuration: const Duration(milliseconds: 200),
                        placeholder: (_, __) =>
                            Container(color: AppColors.gray100),
                        errorWidget: (_, __, ___) => Container(
                          color: AppColors.gray100,
                          child: const Center(
                            child: Icon(
                              LucideIcons.coffee,
                              size: 40,
                              color: AppColors.gray400,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        color: AppColors.gray100,
                        child: const Center(
                          child: Icon(
                            LucideIcons.coffee,
                            size: 40,
                            color: AppColors.gray400,
                          ),
                        ),
                      ),
              ),
            ),

            // 정보
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제품명
                  Text(
                    product.getLocalizedName(),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // 가격
                  if (product.formattedPriceRange != null)
                    Text(
                      product.formattedPriceRange!,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    )
                  else if (product.modelNumber != null)
                    Text(
                      product.modelNumber!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 에러 뷰
class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            LucideIcons.alertCircle,
            size: 48,
            color: AppColors.gray400,
          ),
          const SizedBox(height: 16),
          Text('Failed to load equipment', style: AppTypography.bodyMedium),
          const SizedBox(height: 16),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

/// 빈 상태
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.coffee, size: 64, color: AppColors.gray300),
          const SizedBox(height: 24),
          Text('No equipment found', style: AppTypography.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Check back later for updates',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
