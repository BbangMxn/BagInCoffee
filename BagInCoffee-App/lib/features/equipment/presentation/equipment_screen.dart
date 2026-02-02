import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
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
import 'equipment_screen_desktop.dart';

/// 반응형 브레이크포인트
const double _kDesktopBreakpoint = 1024;

/// 장비 마켓 화면 - Uber Design Guidelines
/// PC에서는 EquipmentScreenDesktop, 모바일에서는 모바일 레이아웃 사용
class EquipmentScreen extends ConsumerWidget {
  const EquipmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // PC 버전
        if (constraints.maxWidth >= _kDesktopBreakpoint) {
          return const EquipmentScreenDesktop();
        }

        // 모바일/태블릿 버전
        return const _EquipmentScreenMobile();
      },
    );
  }
}

/// 모바일 장비 마켓 화면
class _EquipmentScreenMobile extends ConsumerStatefulWidget {
  const _EquipmentScreenMobile();

  @override
  ConsumerState<_EquipmentScreenMobile> createState() =>
      _EquipmentScreenMobileState();
}

class _EquipmentScreenMobileState
    extends ConsumerState<_EquipmentScreenMobile> {
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
    // Rust API에서 장비 데이터 가져오기
    final equipmentAsync = ref.watch(equipmentListProvider);

    return Column(
      children: [
        // 헤더 & 검색 - Uber style
        Container(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: AppColors.gray100)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 타이틀
              Text(
                'Equipment',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '커피 장비 카탈로그',
                style: GoogleFonts.notoSansKr(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // 검색바 - Uber minimal style
              Container(
                decoration: BoxDecoration(
                  color: AppColors.gray50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.gray200),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search equipment...',
                    hintStyle: AppTypography.bodyMedium.copyWith(
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
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                  onChanged: (value) => setState(() {}),
                ),
              ),
            ],
          ),
        ),

        // 장비 목록
        Expanded(
          child: equipmentAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
            error: (error, stack) {
              if (kDebugMode) print('❌ 장비 로드 에러: $error');
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      LucideIcons.alertCircle,
                      size: 48,
                      color: AppColors.gray400,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Failed to load equipment',
                      style: AppTypography.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      error.toString(),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextButton(
                      onPressed: () => ref.invalidate(equipmentListProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            },
            data: (products) {
              if (products.isEmpty) {
                return _EmptyState();
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

              return LayoutBuilder(
                builder: (context, constraints) {
                  // 화면 크기에 따라 그리드 열 개수 조정 (PC 버전 지원)
                  int crossAxisCount;
                  if (constraints.maxWidth > 1200) {
                    crossAxisCount = 4; // 데스크탑
                  } else if (constraints.maxWidth > 900) {
                    crossAxisCount = 3; // 태블릿
                  } else {
                    crossAxisCount = 2; // 모바일
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(equipmentListProvider);
                    },
                    child: GridView.builder(
                      padding: EdgeInsets.all(
                        constraints.maxWidth > 900
                            ? AppSpacing.lg
                            : AppSpacing.screenPadding,
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: AppSpacing.md,
                        mainAxisSpacing: AppSpacing.md,
                        childAspectRatio: 0.70,
                      ),
                      // 성능 최적화
                      addAutomaticKeepAlives: true,
                      addRepaintBoundaries: true,
                      cacheExtent: 600,
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        // RepaintBoundary로 각 카드를 독립적으로 렌더링
                        return RepaintBoundary(
                          child: _ProductCard(product: filteredProducts[index]),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.coffee, size: 64, color: AppColors.gray300),
          const SizedBox(height: AppSpacing.lg),
          Text('No equipment found', style: AppTypography.headlineSmall),
          const SizedBox(height: AppSpacing.sm),
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

class _ProductCard extends StatelessWidget {
  final Product product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.gray200, width: 1),
      ),
      child: InkWell(
        onTap: () {
          context.push('/products/${product.id}');
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지
            AspectRatio(
              aspectRatio: 1,
              child: product.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: product.imageUrl!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      // 메모리 캐시 최적화 (그리드는 작은 썸네일)
                      memCacheWidth: 400,
                      memCacheHeight: 400,
                      cacheKey: product.imageUrl!,
                      // 빠른 페이드 애니메이션
                      fadeInDuration: const Duration(milliseconds: 200),
                      fadeOutDuration: const Duration(milliseconds: 100),
                      placeholder: (_, __) => Container(
                        color: AppColors.gray100,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: AppColors.gray100,
                        child: const Icon(
                          LucideIcons.coffee,
                          size: 32,
                          color: AppColors.gray400,
                        ),
                      ),
                    )
                  : Container(
                      color: AppColors.gray100,
                      child: Center(
                        child: Icon(
                          LucideIcons.coffee,
                          size: 32,
                          color: AppColors.gray400,
                        ),
                      ),
                    ),
            ),

            // 정보 - Uber minimal style
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 제품명
                  Text(
                    product.getLocalizedName(),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),

                  // 모델 번호 또는 가격
                  if (product.formattedPriceRange != null)
                    Text(
                      product.formattedPriceRange!,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  else if (product.modelNumber != null)
                    Text(
                      product.modelNumber!,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
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
