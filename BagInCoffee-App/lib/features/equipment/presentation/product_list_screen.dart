import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../api/api.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../data/product_provider.dart';
import '../data/brand_provider.dart';
import '../data/category_provider.dart';

/// 제품 목록 화면 (Equipment Database)
class ProductListScreen extends ConsumerStatefulWidget {
  final String? categoryId;
  final String? brandId;

  const ProductListScreen({super.key, this.categoryId, this.brandId});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  final _searchController = TextEditingController();
  String? _selectedCategoryId;
  String? _selectedBrandId;
  String _sortBy = 'created_at';
  String _order = 'desc';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.categoryId;
    _selectedBrandId = widget.brandId;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  ProductListParams get _currentParams => ProductListParams(
    categoryId: _selectedCategoryId,
    brandId: _selectedBrandId,
    search: _isSearching ? _searchController.text : null,
    sortBy: _sortBy,
    order: _order,
    limit: 50,
  );

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productListProvider(_currentParams));
    final categoriesAsync = ref.watch(rootCategoriesProvider);
    final brandsAsync = ref.watch(allBrandsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '장비 데이터베이스',
          style: GoogleFonts.notoSansKr(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.search),
            onPressed: () {
              setState(() => _isSearching = !_isSearching);
              if (!_isSearching) {
                _searchController.clear();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 검색바 (토글)
          if (_isSearching)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
                vertical: AppSpacing.sm,
              ),
              color: Colors.white,
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: '제품명, 모델명 검색...',
                  hintStyle: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  prefixIcon: const Icon(LucideIcons.search, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(LucideIcons.x, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.gray50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => setState(() {}),
              ),
            ),

          // 필터 영역
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: AppColors.gray100)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // 카테고리 필터
                  categoriesAsync.when(
                    loading: () => _FilterChip(
                      label: '카테고리',
                      icon: LucideIcons.folder,
                      isSelected: false,
                      onTap: () {},
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (categories) => _FilterDropdown(
                      label: _selectedCategoryId != null
                          ? categories
                                .firstWhere(
                                  (c) => c.id == _selectedCategoryId,
                                  orElse: () => categories.first,
                                )
                                .getLocalizedName()
                          : '카테고리',
                      icon: LucideIcons.folder,
                      isSelected: _selectedCategoryId != null,
                      items: [
                        const DropdownMenuItem(value: null, child: Text('전체')),
                        ...categories.map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.getLocalizedName()),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedCategoryId = value);
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),

                  // 브랜드 필터
                  brandsAsync.when(
                    loading: () => _FilterChip(
                      label: '브랜드',
                      icon: LucideIcons.tag,
                      isSelected: false,
                      onTap: () {},
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (brands) => _FilterDropdown(
                      label: _selectedBrandId != null
                          ? brands
                                .firstWhere(
                                  (b) => b.id == _selectedBrandId,
                                  orElse: () => brands.first,
                                )
                                .getLocalizedName()
                          : '브랜드',
                      icon: LucideIcons.tag,
                      isSelected: _selectedBrandId != null,
                      items: [
                        const DropdownMenuItem(value: null, child: Text('전체')),
                        ...brands.map(
                          (b) => DropdownMenuItem(
                            value: b.id,
                            child: Text(b.getLocalizedName()),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedBrandId = value);
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),

                  // 정렬 필터
                  _FilterDropdown(
                    label: _getSortLabel(),
                    icon: LucideIcons.arrowUpDown,
                    isSelected: _sortBy != 'created_at',
                    items: const [
                      DropdownMenuItem(value: 'created_at', child: Text('최신순')),
                      DropdownMenuItem(value: 'name', child: Text('이름순')),
                      DropdownMenuItem(value: 'price', child: Text('가격순')),
                      DropdownMenuItem(value: 'view_count', child: Text('조회순')),
                    ],
                    onChanged: (value) {
                      setState(() => _sortBy = value ?? 'created_at');
                    },
                  ),
                ],
              ),
            ),
          ),

          // 제품 목록
          Expanded(
            child: productsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => _ErrorState(
                onRetry: () =>
                    ref.invalidate(productListProvider(_currentParams)),
              ),
              data: (response) {
                if (response.data.isEmpty) {
                  return _EmptyState(isSearching: _isSearching);
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(productListProvider(_currentParams));
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.screenPadding),
                    itemCount: response.data.length,
                    itemBuilder: (context, index) =>
                        _ProductCard(product: response.data[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getSortLabel() {
    switch (_sortBy) {
      case 'name':
        return '이름순';
      case 'price':
        return '가격순';
      case 'view_count':
        return '조회순';
      default:
        return '최신순';
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.gray50,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final List<DropdownMenuItem<String?>> items;
  final ValueChanged<String?> onChanged;

  const _FilterDropdown({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String?>(
      onSelected: onChanged,
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      itemBuilder: (context) => items
          .map(
            (item) =>
                PopupMenuItem<String?>(value: item.value, child: item.child!),
          )
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.gray50,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              LucideIcons.chevronDown,
              size: 14,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ],
        ),
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
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.gray100),
      ),
      child: InkWell(
        onTap: () => context.push('/products/${product.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 이미지
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: product.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: product.imageUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          width: 80,
                          height: 80,
                          color: AppColors.gray100,
                        ),
                        errorWidget: (_, __, ___) => _PlaceholderImage(),
                      )
                    : _PlaceholderImage(),
              ),
              const SizedBox(width: AppSpacing.md),

              // 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 모델명
                    if (product.modelNumber != null)
                      Text(
                        product.modelNumber!,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),

                    // 제품명
                    Text(
                      product.getLocalizedName(),
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // 가격
                    if (product.formattedPriceRange != null)
                      Text(
                        product.formattedPriceRange!,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    const SizedBox(height: 8),

                    // 메타 정보
                    Row(
                      children: [
                        if (product.isVerified) ...[
                          Icon(
                            LucideIcons.badgeCheck,
                            size: 14,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '인증됨',
                            style: AppTypography.caption.copyWith(
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Icon(
                          LucideIcons.eye,
                          size: 12,
                          color: AppColors.gray400,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${product.viewCount}',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 화살표
              const Icon(
                LucideIcons.chevronRight,
                size: 20,
                color: AppColors.gray400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      color: AppColors.gray100,
      child: const Icon(LucideIcons.coffee, size: 32, color: AppColors.gray400),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isSearching;

  const _EmptyState({required this.isSearching});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching ? LucideIcons.searchX : LucideIcons.database,
            size: 64,
            color: AppColors.gray300,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            isSearching ? '검색 결과가 없습니다' : '등록된 제품이 없습니다',
            style: AppTypography.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            isSearching ? '다른 검색어를 시도해보세요' : '조건을 변경해보세요',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

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
          const SizedBox(height: AppSpacing.md),
          Text('제품 목록을 불러올 수 없습니다', style: AppTypography.bodyMedium),
          const SizedBox(height: AppSpacing.md),
          TextButton(onPressed: onRetry, child: const Text('다시 시도')),
        ],
      ),
    );
  }
}
