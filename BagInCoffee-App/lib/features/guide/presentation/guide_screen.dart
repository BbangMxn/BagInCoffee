import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../api/api.dart';
import '../data/guide_provider.dart';

/// 반응형 브레이크포인트
const double _kDesktopBreakpoint = 900;

/// 가이드 화면 - 클래식 매거진 스타일
class GuideScreen extends ConsumerWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guidesAsync = ref.watch(guidesProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= _kDesktopBreakpoint;

        return Scaffold(
          backgroundColor: const Color(0xFFFAF9F7),
          body: guidesAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: Color(0xFF37352F)),
            ),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    LucideIcons.alertCircle,
                    size: 48,
                    color: Color(0xFF9B9A97),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    '가이드를 불러올 수 없습니다',
                    style: GoogleFonts.notoSerifKr(
                      fontSize: 16,
                      color: const Color(0xFF37352F),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextButton(
                    onPressed: () => ref.invalidate(guidesProvider),
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            ),
            data: (guides) {
              if (guides.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        LucideIcons.bookOpen,
                        size: 64,
                        color: Color(0xFFD3D1CB),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        '아직 가이드가 없습니다',
                        style: GoogleFonts.notoSerifKr(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF37352F),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return isDesktop
                  ? _GuideScreenDesktop(guides: guides, ref: ref)
                  : _GuideScreenMobile(guides: guides, ref: ref);
            },
          ),
        );
      },
    );
  }
}

/// 데스크톱 버전
class _GuideScreenDesktop extends StatelessWidget {
  final List<CoffeeGuide> guides;
  final WidgetRef ref;

  const _GuideScreenDesktop({required this.guides, required this.ref});

  @override
  Widget build(BuildContext context) {
    // 카테고리별 그룹화
    final categories = <String, List<CoffeeGuide>>{};
    for (final guide in guides) {
      final category = guide.category ?? 'etc';
      categories.putIfAbsent(category, () => []).add(guide);
    }

    return Row(
      children: [
        // 메인 콘텐츠
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => ref.invalidate(guidesProvider),
            color: const Color(0xFF37352F),
            child: CustomScrollView(
              slivers: [
                // 헤더
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(32, 32, 32, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'COFFEE GUIDE',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 3,
                            color: const Color(0xFF37352F),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 60,
                          height: 3,
                          color: const Color(0xFF37352F),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '커피의 모든 것을 알아보세요',
                          style: GoogleFonts.notoSerifKr(
                            fontSize: 16,
                            color: const Color(0xFF9B9A97),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 피쳐드 가이드 (첫번째)
                if (guides.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: _FeaturedGuideCardDesktop(guide: guides.first),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 40)),

                // 나머지 가이드 그리드
                if (guides.length > 1)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 400,
                            childAspectRatio: 0.85,
                            mainAxisSpacing: 24,
                            crossAxisSpacing: 24,
                          ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            _GuideCardDesktop(guide: guides[index + 1]),
                        childCount: guides.length - 1,
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          ),
        ),

        // 사이드바
        Container(
          width: 320,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              left: BorderSide(color: const Color(0xFFE8E7E4), width: 1),
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 카테고리 섹션
                _CategorySection(categories: categories),
                const SizedBox(height: 32),
                // 인기 가이드
                _PopularGuidesSection(guides: guides),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// 데스크톱용 피쳐드 카드
class _FeaturedGuideCardDesktop extends StatelessWidget {
  final CoffeeGuide guide;

  const _FeaturedGuideCardDesktop({required this.guide});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/guide/${guide.id}'),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 이미지
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(8),
                  ),
                  child: AspectRatio(
                    aspectRatio: 4 / 3,
                    child: guide.coverImage != null
                        ? CachedNetworkImage(
                            imageUrl: guide.coverImage!,
                            fit: BoxFit.cover,
                            placeholder: (_, __) =>
                                Container(color: const Color(0xFFF5F5F3)),
                            errorWidget: (_, __, ___) => _buildPlaceholder(),
                          )
                        : _buildPlaceholder(),
                  ),
                ),
              ),

              // 콘텐츠
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Featured 뱃지
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF37352F),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'FEATURED',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 카테고리
                      Text(
                        guide.categoryLabel.toUpperCase(),
                        style: GoogleFonts.notoSansKr(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                          color: const Color(0xFF9B9A97),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // 제목
                      Text(
                        guide.title,
                        style: GoogleFonts.notoSerifKr(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                          color: const Color(0xFF37352F),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // 요약
                      if (guide.excerpt != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          guide.excerpt!,
                          style: GoogleFonts.notoSerifKr(
                            fontSize: 15,
                            height: 1.7,
                            color: const Color(0xFF6B6B6B),
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      const SizedBox(height: 24),

                      // 읽기 버튼
                      Row(
                        children: [
                          Text(
                            '자세히 보기',
                            style: GoogleFonts.notoSansKr(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF37352F),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            LucideIcons.arrowRight,
                            size: 18,
                            color: Color(0xFF37352F),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFFF5F5F3),
      child: const Center(
        child: Icon(LucideIcons.bookOpen, size: 48, color: Color(0xFFD3D1CB)),
      ),
    );
  }
}

/// 데스크톱용 가이드 카드
class _GuideCardDesktop extends StatelessWidget {
  final CoffeeGuide guide;

  const _GuideCardDesktop({required this.guide});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/guide/${guide.id}'),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE8E7E4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 이미지
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: guide.coverImage != null
                        ? CachedNetworkImage(
                            imageUrl: guide.coverImage!,
                            fit: BoxFit.cover,
                            placeholder: (_, __) =>
                                Container(color: const Color(0xFFF5F5F3)),
                            errorWidget: (_, __, ___) => _buildPlaceholder(),
                          )
                        : _buildPlaceholder(),
                  ),
                ),
              ),

              // 콘텐츠
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 카테고리 & 난이도
                      Row(
                        children: [
                          Text(
                            guide.categoryLabel.toUpperCase(),
                            style: GoogleFonts.notoSansKr(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                              color: const Color(0xFF9B9A97),
                            ),
                          ),
                          if (guide.difficulty != null) ...[
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _getDifficultyColor(guide.difficulty!),
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Text(
                                guide.difficultyLabel,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: _getDifficultyColor(guide.difficulty!),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 12),

                      // 제목
                      Expanded(
                        child: Text(
                          guide.title,
                          style: GoogleFonts.notoSerifKr(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                            color: const Color(0xFF37352F),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // 메타 정보
                      Row(
                        children: [
                          if (guide.readingTimeMinutes != null) ...[
                            Icon(
                              LucideIcons.clock,
                              size: 14,
                              color: const Color(0xFF9B9A97),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${guide.readingTimeMinutes}분',
                              style: GoogleFonts.notoSansKr(
                                fontSize: 12,
                                color: const Color(0xFF9B9A97),
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                          Icon(
                            LucideIcons.eye,
                            size: 14,
                            color: const Color(0xFF9B9A97),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${guide.viewsCount}',
                            style: GoogleFonts.notoSansKr(
                              fontSize: 12,
                              color: const Color(0xFF9B9A97),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFFF5F5F3),
      child: const Center(
        child: Icon(LucideIcons.bookOpen, size: 32, color: Color(0xFFD3D1CB)),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'beginner':
        return const Color(0xFF2E7D32);
      case 'intermediate':
        return const Color(0xFFEF6C00);
      case 'advanced':
        return const Color(0xFFC62828);
      default:
        return const Color(0xFF9B9A97);
    }
  }
}

/// 카테고리 섹션
class _CategorySection extends StatelessWidget {
  final Map<String, List<CoffeeGuide>> categories;

  const _CategorySection({required this.categories});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF9F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '카테고리',
            style: GoogleFonts.notoSerifKr(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF37352F),
            ),
          ),
          const SizedBox(height: 16),
          ...categories.entries.map((entry) {
            final label = _getCategoryLabel(entry.key);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFF37352F),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: GoogleFonts.notoSansKr(
                        fontSize: 14,
                        color: const Color(0xFF37352F),
                      ),
                    ),
                  ),
                  Text(
                    '${entry.value.length}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF9B9A97),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'brewing':
        return '추출 가이드';
      case 'beans':
        return '원두 가이드';
      case 'equipment':
        return '장비 가이드';
      case 'recipes':
        return '레시피';
      default:
        return '기타';
    }
  }
}

/// 인기 가이드 섹션
class _PopularGuidesSection extends StatelessWidget {
  final List<CoffeeGuide> guides;

  const _PopularGuidesSection({required this.guides});

  @override
  Widget build(BuildContext context) {
    final popularGuides = List<CoffeeGuide>.from(guides)
      ..sort((a, b) => b.viewsCount.compareTo(a.viewsCount));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E7E4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '인기 가이드',
            style: GoogleFonts.notoSerifKr(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF37352F),
            ),
          ),
          const SizedBox(height: 16),
          ...popularGuides.take(5).map((guide) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: InkWell(
                onTap: () => context.push('/guide/${guide.id}'),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: SizedBox(
                        width: 60,
                        height: 60,
                        child: guide.coverImage != null
                            ? CachedNetworkImage(
                                imageUrl: guide.coverImage!,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: const Color(0xFFF5F5F3),
                                child: const Icon(
                                  LucideIcons.bookOpen,
                                  size: 20,
                                  color: Color(0xFFD3D1CB),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            guide.title,
                            style: GoogleFonts.notoSerifKr(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF37352F),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${guide.viewsCount} views',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF9B9A97),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// 모바일 버전 (기존)
class _GuideScreenMobile extends StatelessWidget {
  final List<CoffeeGuide> guides;
  final WidgetRef ref;

  const _GuideScreenMobile({required this.guides, required this.ref});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(guidesProvider),
      color: const Color(0xFF37352F),
      child: CustomScrollView(
        slivers: [
          // 헤더
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'COFFEE GUIDE',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                      color: const Color(0xFF37352F),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 40,
                    height: 2,
                    color: const Color(0xFF37352F),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '커피의 모든 것을 알아보세요',
                    style: GoogleFonts.notoSerifKr(
                      fontSize: 14,
                      color: const Color(0xFF9B9A97),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 피쳐드 가이드 (첫번째)
          if (guides.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _FeaturedGuideCard(guide: guides.first),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // 나머지 가이드 리스트
          if (guides.length > 1)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final guide = guides[index + 1];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _GuideListItem(guide: guide),
                  );
                }, childCount: guides.length - 1),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

/// 피쳐드 가이드 카드 (대형) - 모바일
class _FeaturedGuideCard extends StatelessWidget {
  final CoffeeGuide guide;

  const _FeaturedGuideCard({required this.guide});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/guide/${guide.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: guide.coverImage != null
                    ? CachedNetworkImage(
                        imageUrl: guide.coverImage!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            Container(color: const Color(0xFFF5F5F3)),
                        errorWidget: (_, __, ___) => _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
            ),

            // 콘텐츠
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 카테고리 & 난이도
                  Row(
                    children: [
                      Text(
                        guide.categoryLabel.toUpperCase(),
                        style: GoogleFonts.notoSansKr(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                          color: const Color(0xFF9B9A97),
                        ),
                      ),
                      if (guide.difficulty != null) ...[
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _getDifficultyColor(guide.difficulty!),
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Text(
                            guide.difficultyLabel,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: _getDifficultyColor(guide.difficulty!),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 제목
                  Text(
                    guide.title,
                    style: GoogleFonts.notoSerifKr(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                      color: const Color(0xFF37352F),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // 요약
                  if (guide.excerpt != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      guide.excerpt!,
                      style: GoogleFonts.notoSerifKr(
                        fontSize: 14,
                        height: 1.6,
                        color: const Color(0xFF6B6B6B),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: 16),

                  // 메타 정보
                  Row(
                    children: [
                      if (guide.readingTimeMinutes != null) ...[
                        Icon(
                          LucideIcons.clock,
                          size: 14,
                          color: const Color(0xFF9B9A97),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${guide.readingTimeMinutes}분 읽기',
                          style: GoogleFonts.notoSansKr(
                            fontSize: 12,
                            color: const Color(0xFF9B9A97),
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      Icon(
                        LucideIcons.eye,
                        size: 14,
                        color: const Color(0xFF9B9A97),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${guide.viewsCount}',
                        style: GoogleFonts.notoSansKr(
                          fontSize: 12,
                          color: const Color(0xFF9B9A97),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFFF5F5F3),
      child: const Center(
        child: Icon(LucideIcons.bookOpen, size: 40, color: Color(0xFFD3D1CB)),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'beginner':
        return const Color(0xFF2E7D32);
      case 'intermediate':
        return const Color(0xFFEF6C00);
      case 'advanced':
        return const Color(0xFFC62828);
      default:
        return const Color(0xFF9B9A97);
    }
  }
}

/// 가이드 리스트 아이템 - 모바일
class _GuideListItem extends StatelessWidget {
  final CoffeeGuide guide;

  const _GuideListItem({required this.guide});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/guide/${guide.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFFE8E7E4)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 썸네일
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                width: 80,
                height: 80,
                child: guide.coverImage != null
                    ? CachedNetworkImage(
                        imageUrl: guide.coverImage!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            Container(color: const Color(0xFFF5F5F3)),
                        errorWidget: (_, __, ___) => _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
            ),

            const SizedBox(width: 16),

            // 콘텐츠
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 카테고리
                  Text(
                    guide.categoryLabel.toUpperCase(),
                    style: GoogleFonts.notoSansKr(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: const Color(0xFF9B9A97),
                    ),
                  ),

                  const SizedBox(height: 4),

                  // 제목
                  Text(
                    guide.title,
                    style: GoogleFonts.notoSerifKr(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                      color: const Color(0xFF37352F),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // 메타 정보
                  Row(
                    children: [
                      if (guide.difficulty != null) ...[
                        Text(
                          guide.difficultyLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: _getDifficultyColor(guide.difficulty!),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: const BoxDecoration(
                            color: Color(0xFFD3D1CB),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (guide.readingTimeMinutes != null)
                        Text(
                          '${guide.readingTimeMinutes}분',
                          style: GoogleFonts.notoSansKr(
                            fontSize: 11,
                            color: const Color(0xFF9B9A97),
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
              size: 18,
              color: Color(0xFFD3D1CB),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFFF5F5F3),
      child: const Center(
        child: Icon(LucideIcons.bookOpen, size: 24, color: Color(0xFFD3D1CB)),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'beginner':
        return const Color(0xFF2E7D32);
      case 'intermediate':
        return const Color(0xFFEF6C00);
      case 'advanced':
        return const Color(0xFFC62828);
      default:
        return const Color(0xFF9B9A97);
    }
  }
}
