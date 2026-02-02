import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../api/api.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../data/product_provider.dart';
import '../data/brand_provider.dart';

/// 제품 상세 화면
class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailProvider(widget.productId));

    return Scaffold(
      backgroundColor: Colors.white,
      body: productAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _ErrorView(
          onRetry: () =>
              ref.invalidate(productDetailProvider(widget.productId)),
        ),
        data: (product) => _ProductDetailContent(
          product: product,
          currentImageIndex: _currentImageIndex,
          onImageChanged: (index) => setState(() => _currentImageIndex = index),
        ),
      ),
    );
  }
}

class _ProductDetailContent extends ConsumerWidget {
  final Product product;
  final int currentImageIndex;
  final ValueChanged<int> onImageChanged;

  const _ProductDetailContent({
    required this.product,
    required this.currentImageIndex,
    required this.onImageChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brandAsync = ref.watch(brandDetailProvider(product.brandId));
    final images =
        product.images ?? (product.imageUrl != null ? [product.imageUrl!] : []);

    return CustomScrollView(
      slivers: [
        // 앱바 + 이미지
        SliverAppBar(
          expandedHeight: 320,
          pinned: true,
          backgroundColor: Colors.white,
          foregroundColor: AppColors.gray900,
          elevation: 0,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.arrowLeft,
                size: 20,
                color: Colors.white,
              ),
            ),
            onPressed: () => context.pop(),
          ),
          actions: [
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.share2,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                // TODO: 공유 기능
              },
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: images.isNotEmpty
                ? Stack(
                    children: [
                      PageView.builder(
                        itemCount: images.length,
                        onPageChanged: onImageChanged,
                        // 성능 최적화
                        allowImplicitScrolling: false,
                        itemBuilder: (context, index) => CachedNetworkImage(
                          imageUrl: images[index],
                          fit: BoxFit.cover,
                          // 큰 이미지 캐싱 최적화
                          memCacheWidth: 1600,
                          memCacheHeight: 1200,
                          cacheKey: images[index],
                          fadeInDuration: const Duration(milliseconds: 200),
                          fadeOutDuration: const Duration(milliseconds: 100),
                          placeholder: (_, __) =>
                              Container(color: AppColors.gray100),
                          errorWidget: (_, __, ___) => _ImagePlaceholder(),
                        ),
                      ),
                      if (images.length > 1)
                        Positioned(
                          bottom: 16,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              images.length,
                              (index) => Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                ),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: currentImageIndex == index
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  )
                : _ImagePlaceholder(),
          ),
        ),

        // 컨텐츠
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 브랜드
                brandAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (brand) => GestureDetector(
                    onTap: () => context.push('/brands/${brand.id}'),
                    child: Row(
                      children: [
                        if (brand.logoUrl != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: CachedNetworkImage(
                              imageUrl: brand.logoUrl!,
                              width: 24,
                              height: 24,
                              fit: BoxFit.contain,
                            ),
                          ),
                        const SizedBox(width: 8),
                        Text(
                          brand.getLocalizedName(),
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (brand.verified)
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Icon(
                              LucideIcons.badgeCheck,
                              size: 16,
                              color: Colors.blue,
                            ),
                          ),
                        const SizedBox(width: 4),
                        Icon(
                          LucideIcons.chevronRight,
                          size: 16,
                          color: AppColors.gray400,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

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
                  style: GoogleFonts.notoSansKr(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // 가격
                if (product.formattedPriceRange != null) ...[
                  Row(
                    children: [
                      Text(
                        product.formattedPriceRange!,
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      if (product.currentPriceUpdatedAt != null)
                        Text(
                          _formatDate(product.currentPriceUpdatedAt!),
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],

                // 태그들
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (product.isVerified)
                      _Tag(
                        icon: LucideIcons.badgeCheck,
                        label: '인증됨',
                        color: Colors.blue,
                      ),
                    if (product.manufacturerCountry != null)
                      _Tag(
                        icon: LucideIcons.mapPin,
                        label: product.manufacturerCountry!,
                        color: AppColors.gray600,
                      ),
                    if (product.releaseDate != null)
                      _Tag(
                        icon: LucideIcons.calendar,
                        label: '${product.releaseDate!.year}년 출시',
                        color: AppColors.gray600,
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),

                // 설명
                if (product.getLocalizedDescription() != null) ...[
                  _SectionTitle(title: '제품 설명'),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    product.getLocalizedDescription()!,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],

                // 스펙
                if (product.specs != null && product.specs!.isNotEmpty) ...[
                  _SectionTitle(title: '제품 스펙'),
                  const SizedBox(height: AppSpacing.sm),
                  _SpecsTable(specs: product.specs!),
                  const SizedBox(height: AppSpacing.xl),
                ],

                // 물리 스펙
                if (_hasPhysicalSpecs(product)) ...[
                  _SectionTitle(title: '물리 스펙'),
                  const SizedBox(height: AppSpacing.sm),
                  _PhysicalSpecsTable(product: product),
                  const SizedBox(height: AppSpacing.xl),
                ],

                // 구매 링크
                if (product.purchaseLinks != null ||
                    product.officialUrl != null) ...[
                  _SectionTitle(title: '구매 링크'),
                  const SizedBox(height: AppSpacing.sm),
                  _PurchaseLinks(
                    purchaseLinks: product.purchaseLinks,
                    officialUrl: product.officialUrl,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],

                // 가격 추이 섹션
                _PriceHistory(productId: product.id),

                // 리뷰 섹션
                _ProductReviews(productId: product.id),

                // 메타 정보
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.gray50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _MetaItem(
                        icon: LucideIcons.eye,
                        label: '조회수',
                        value: '${product.viewCount}',
                      ),
                      _MetaItem(
                        icon: LucideIcons.edit,
                        label: '수정횟수',
                        value: '${product.editCount}',
                      ),
                      _MetaItem(
                        icon: LucideIcons.clock,
                        label: '업데이트',
                        value: _formatDate(product.updatedAt),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 100), // 하단 여백
              ],
            ),
          ),
        ),
      ],
    );
  }

  bool _hasPhysicalSpecs(Product product) {
    return product.dimensions != null ||
        product.weight != null ||
        product.powerWatts != null ||
        product.voltage != null;
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}

class _ImagePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.gray100,
      child: const Center(
        child: Icon(LucideIcons.coffee, size: 64, color: AppColors.gray400),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.notoSansKr(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Tag({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecsTable extends StatelessWidget {
  final Map<String, dynamic> specs;

  const _SpecsTable({required this.specs});

  @override
  Widget build(BuildContext context) {
    final entries = specs.entries.toList();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.gray200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: entries.asMap().entries.map((entry) {
          final index = entry.key;
          final spec = entry.value;
          final isLast = index == entries.length - 1;

          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : Border(bottom: BorderSide(color: AppColors.gray200)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    _formatSpecKey(spec.key),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    _formatSpecValue(spec.value),
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  String _formatSpecKey(String key) {
    // snake_case를 읽기 좋은 형태로 변환
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1)}'
              : '',
        )
        .join(' ');
  }

  String _formatSpecValue(dynamic value) {
    if (value is List) {
      return value.join(', ');
    }
    if (value is Map) {
      return value.values.join(', ');
    }
    if (value is bool) {
      return value ? '예' : '아니오';
    }
    return value.toString();
  }
}

class _PhysicalSpecsTable extends StatelessWidget {
  final Product product;

  const _PhysicalSpecsTable({required this.product});

  @override
  Widget build(BuildContext context) {
    final specs = <String, String>{};

    if (product.dimensions != null) {
      final d = product.dimensions!;
      if (d['width'] != null && d['depth'] != null && d['height'] != null) {
        specs['크기'] =
            '${d['width']} × ${d['depth']} × ${d['height']} ${d['unit'] ?? 'mm'}';
      }
    }

    if (product.weight != null) {
      final w = product.weight!;
      specs['무게'] = '${w['value']} ${w['unit'] ?? 'kg'}';
    }

    if (product.powerWatts != null) {
      specs['전력'] = '${product.powerWatts}W';
    }

    if (product.voltage != null) {
      specs['전압'] = product.voltage!;
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.gray200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: specs.entries.toList().asMap().entries.map((entry) {
          final index = entry.key;
          final spec = entry.value;
          final isLast = index == specs.length - 1;

          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : Border(bottom: BorderSide(color: AppColors.gray200)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    spec.key,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    spec.value,
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PurchaseLinks extends StatelessWidget {
  final Map<String, dynamic>? purchaseLinks;
  final String? officialUrl;

  const _PurchaseLinks({this.purchaseLinks, this.officialUrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (officialUrl != null)
          _LinkButton(
            icon: LucideIcons.globe,
            label: '공식 웹사이트',
            url: officialUrl!,
          ),
        if (purchaseLinks != null)
          ...purchaseLinks!.entries.map(
            (entry) => _LinkButton(
              icon: LucideIcons.shoppingCart,
              label: entry.key,
              url: entry.value.toString(),
            ),
          ),
      ],
    );
  }
}

class _LinkButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String url;

  const _LinkButton({
    required this.icon,
    required this.label,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: OutlinedButton(
        onPressed: () async {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          side: BorderSide(color: AppColors.gray200),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(label, style: AppTypography.bodyMedium)),
            const Icon(LucideIcons.externalLink, size: 16),
          ],
        ),
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetaItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.gray500),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        Text(
          label,
          style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
        ),
      ],
    );
  }
}

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
          const SizedBox(height: AppSpacing.md),
          Text('제품 정보를 불러올 수 없습니다', style: AppTypography.bodyMedium),
          const SizedBox(height: AppSpacing.md),
          TextButton(onPressed: onRetry, child: const Text('다시 시도')),
        ],
      ),
    );
  }
}

/// 가격 추이 섹션
class _PriceHistory extends ConsumerWidget {
  final String productId;

  const _PriceHistory({required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Provider를 사용하여 캐싱 및 중복 호출 방지
    final priceHistoryAsync = ref.watch(productPriceHistoryProvider(productId));

    return priceHistoryAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (priceHistory) {
        // 데이터가 없으면 아무것도 표시하지 않음
        if (priceHistory.isEmpty) {
          return const SizedBox.shrink();
        }

        final validPrices = priceHistory.where((p) => p.price != null).toList();

        if (validPrices.isEmpty) {
          return const SizedBox.shrink();
        }

        // 최저/최고 가격 계산
        final prices = validPrices.map((p) => p.price!).toList();
        final minPrice = prices.reduce((a, b) => a < b ? a : b);
        final maxPrice = prices.reduce((a, b) => a > b ? a : b);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(title: '가격 추이'),
            const SizedBox(height: AppSpacing.sm),

            // 가격 정보
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.gray50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _PriceInfo(
                        label: '최저가',
                        price: minPrice,
                        currency: validPrices.first.currency ?? 'KRW',
                        color: Colors.blue,
                      ),
                      Container(width: 1, height: 40, color: AppColors.gray200),
                      _PriceInfo(
                        label: '최고가',
                        price: maxPrice,
                        currency: validPrices.first.currency ?? 'KRW',
                        color: Colors.red,
                      ),
                      Container(width: 1, height: 40, color: AppColors.gray200),
                      _PriceInfo(
                        label: '현재가',
                        price: validPrices.last.price!,
                        currency: validPrices.last.currency ?? 'KRW',
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // 간단한 가격 추이 바
                  _SimplePriceChart(priceHistory: validPrices),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        );
      },
    );
  }
}

/// 가격 정보 위젯
class _PriceInfo extends StatelessWidget {
  final String label;
  final int price;
  final String currency;
  final Color color;

  const _PriceInfo({
    required this.label,
    required this.price,
    required this.currency,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final symbol = currency == 'KRW' ? '₩' : '\$';
    final formatted = _formatNumber(price);

    return Column(
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        Text(
          '$symbol$formatted',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}

/// 간단한 가격 추이 차트
class _SimplePriceChart extends StatelessWidget {
  final List<ProductPricing> priceHistory;

  const _SimplePriceChart({required this.priceHistory});

  @override
  Widget build(BuildContext context) {
    if (priceHistory.length < 2) {
      return const SizedBox.shrink();
    }

    final prices = priceHistory.map((p) => p.price!).toList();
    final minPrice = prices.reduce((a, b) => a < b ? a : b);
    final maxPrice = prices.reduce((a, b) => a > b ? a : b);
    final range = maxPrice - minPrice;

    return SizedBox(
      height: 80,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(priceHistory.length, (index) {
          final price = priceHistory[index].price!;
          final normalizedHeight = range > 0
              ? ((price - minPrice) / range) * 60 + 20
              : 40.0;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: Container(
                height: normalizedHeight,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// 상품 리뷰 섹션
class _ProductReviews extends ConsumerWidget {
  final String productId;

  const _ProductReviews({required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<Review>>(
      future: ReviewsApi().getItemReviews(
        itemId: productId,
        itemType: 'external_product',
        limit: 5,
      ),
      builder: (context, snapshot) {
        final reviews = snapshot.data ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _SectionTitle(title: '사용자 리뷰'),
                const Spacer(),
                TextButton.icon(
                  onPressed: () async {
                    final result = await context.push(
                      '/products/$productId/review/new',
                    );
                    if (result == true && context.mounted) {
                      // 리뷰 작성 후 새로고침
                      (context as Element).markNeedsBuild();
                    }
                  },
                  icon: const Icon(LucideIcons.plus, size: 16),
                  label: const Text('작성'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                FutureBuilder<double?>(
                  future: ReviewsApi().getItemAverageRating(
                    itemId: productId,
                    itemType: 'external_product',
                  ),
                  builder: (context, ratingSnapshot) {
                    if (!ratingSnapshot.hasData ||
                        ratingSnapshot.data == null) {
                      return const SizedBox.shrink();
                    }
                    return Row(
                      children: [
                        Icon(LucideIcons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          ratingSnapshot.data!.toStringAsFixed(1),
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          ' (${reviews.length})',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (reviews.isEmpty)
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Icon(
                      LucideIcons.messageSquare,
                      size: 48,
                      color: AppColors.gray300,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      '아직 리뷰가 없습니다',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '첫 리뷰를 작성해보세요!',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...reviews.map((review) => _ReviewCard(review: review)),
            const SizedBox(height: AppSpacing.xl),
          ],
        );
      },
    );
  }
}

/// 리뷰 카드
class _ReviewCard extends StatelessWidget {
  final Review review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.gray200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // 평점 표시
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < review.rating ? LucideIcons.star : LucideIcons.star,
                    size: 14,
                    color: index < review.rating
                        ? Colors.amber
                        : AppColors.gray300,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                _formatDate(review.createdAt),
                style: AppTypography.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          if (review.review != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              review.review!,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inHours < 1) return '${diff.inMinutes}분 전';
    if (diff.inDays < 1) return '${diff.inHours}시간 전';
    if (diff.inDays < 7) return '${diff.inDays}일 전';
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}
