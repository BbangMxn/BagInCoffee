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
import '../data/brand_provider.dart';

/// 브랜드 목록 화면
class BrandListScreen extends ConsumerStatefulWidget {
  const BrandListScreen({super.key});

  @override
  ConsumerState<BrandListScreen> createState() => _BrandListScreenState();
}

class _BrandListScreenState extends ConsumerState<BrandListScreen> {
  final _searchController = TextEditingController();
  String? _selectedCountry;
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  BrandListParams get _currentParams => BrandListParams(
    country: _selectedCountry,
    search: _isSearching ? _searchController.text : null,
    isActive: true,
    limit: 100,
  );

  @override
  Widget build(BuildContext context) {
    final brandsAsync = ref.watch(brandListProvider(_currentParams));

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
          '브랜드',
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
          // 검색바
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
                  hintText: '브랜드 검색...',
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
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),

          // 국가 필터
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
                  _CountryChip(
                    label: '전체',
                    isSelected: _selectedCountry == null,
                    onTap: () => setState(() => _selectedCountry = null),
                  ),
                  _CountryChip(
                    emoji: '🇮🇹',
                    label: '이탈리아',
                    isSelected: _selectedCountry == 'IT',
                    onTap: () => setState(() => _selectedCountry = 'IT'),
                  ),
                  _CountryChip(
                    emoji: '🇩🇪',
                    label: '독일',
                    isSelected: _selectedCountry == 'DE',
                    onTap: () => setState(() => _selectedCountry = 'DE'),
                  ),
                  _CountryChip(
                    emoji: '🇺🇸',
                    label: '미국',
                    isSelected: _selectedCountry == 'US',
                    onTap: () => setState(() => _selectedCountry = 'US'),
                  ),
                  _CountryChip(
                    emoji: '🇯🇵',
                    label: '일본',
                    isSelected: _selectedCountry == 'JP',
                    onTap: () => setState(() => _selectedCountry = 'JP'),
                  ),
                  _CountryChip(
                    emoji: '🇬🇧',
                    label: '영국',
                    isSelected: _selectedCountry == 'GB',
                    onTap: () => setState(() => _selectedCountry = 'GB'),
                  ),
                  _CountryChip(
                    emoji: '🇨🇭',
                    label: '스위스',
                    isSelected: _selectedCountry == 'CH',
                    onTap: () => setState(() => _selectedCountry = 'CH'),
                  ),
                ],
              ),
            ),
          ),

          // 브랜드 목록
          Expanded(
            child: brandsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => _ErrorState(
                onRetry: () =>
                    ref.invalidate(brandListProvider(_currentParams)),
              ),
              data: (response) {
                if (response.data.isEmpty) {
                  return _EmptyState(isSearching: _isSearching);
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(brandListProvider(_currentParams));
                  },
                  child: GridView.builder(
                    padding: const EdgeInsets.all(AppSpacing.screenPadding),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: AppSpacing.sm,
                          mainAxisSpacing: AppSpacing.sm,
                          childAspectRatio: 0.85,
                        ),
                    itemCount: response.data.length,
                    itemBuilder: (context, index) =>
                        _BrandCard(brand: response.data[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CountryChip extends StatelessWidget {
  final String? emoji;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CountryChip({
    this.emoji,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.xs),
      child: InkWell(
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
              if (emoji != null) ...[
                Text(emoji!, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandCard extends StatelessWidget {
  final Brand brand;

  const _BrandCard({required this.brand});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.gray100),
      ),
      child: InkWell(
        onTap: () => context.push('/brands/${brand.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 로고
              Expanded(
                child: Center(
                  child: brand.logoUrl != null
                      ? CachedNetworkImage(
                          imageUrl: brand.logoUrl!,
                          fit: BoxFit.contain,
                          placeholder: (_, __) => _LogoPlaceholder(),
                          errorWidget: (_, __, ___) => _LogoPlaceholder(),
                        )
                      : _LogoPlaceholder(),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // 브랜드명
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      brand.getLocalizedName(),
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (brand.verified)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Icon(
                        LucideIcons.badgeCheck,
                        size: 14,
                        color: Colors.blue,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),

              // 국가 & 설립연도
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (brand.countryEmoji != null) ...[
                    Text(
                      brand.countryEmoji!,
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 4),
                  ],
                  if (brand.foundedYear != null)
                    Text(
                      '${brand.foundedYear}',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                ],
              ),

              // 전문 분야
              if (brand.specialization != null &&
                  brand.specialization!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  brand.specialization!.take(2).join(', '),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        LucideIcons.building2,
        size: 28,
        color: AppColors.gray400,
      ),
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
            isSearching ? LucideIcons.searchX : LucideIcons.building2,
            size: 64,
            color: AppColors.gray300,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            isSearching ? '검색 결과가 없습니다' : '등록된 브랜드가 없습니다',
            style: AppTypography.headlineSmall,
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
          Text('브랜드 목록을 불러올 수 없습니다', style: AppTypography.bodyMedium),
          const SizedBox(height: AppSpacing.md),
          TextButton(onPressed: onRetry, child: const Text('다시 시도')),
        ],
      ),
    );
  }
}
