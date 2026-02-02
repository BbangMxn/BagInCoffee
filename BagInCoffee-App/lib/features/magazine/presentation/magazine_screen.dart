import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_colors.dart';
import '../../../api/api.dart';
import '../../guide/data/guide_provider.dart';

/// 선택된 카테고리 상태
final selectedCategoryProvider = StateProvider<String>((ref) => 'all');

/// 반응형 브레이크포인트
const double _kDesktopBreakpoint = 900;

/// 매거진 화면 - 노션 스타일 가이드 UI
class MagazineScreen extends ConsumerWidget {
  const MagazineScreen({super.key});

  static const _categories = [
    ('all', '전체'),
    ('brewing', '추출 방법'),
    ('beans', '원두 가이드'),
    ('equipment', '장비 사용법'),
    ('recipe', '레시피'),
    ('roasting', '로스팅'),
    ('barista', '바리스타'),
    ('science', '커피 과학'),
    ('culture', '커피 문화'),
    ('other', '기타'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= _kDesktopBreakpoint) {
          return _MagazineScreenDesktop(categories: _categories);
        }
        return _MagazineScreenMobile(categories: _categories);
      },
    );
  }
}

/// 모바일 매거진 화면
class _MagazineScreenMobile extends ConsumerWidget {
  final List<(String, String)> categories;

  const _MagazineScreenMobile({required this.categories});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final guidesAsync = ref.watch(guidesProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(guidesProvider);
      },
      child: CustomScrollView(
        slivers: [
          // 헤더
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.lg,
                AppSpacing.screenPadding,
                AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 클래식 뉴스 매거진 스타일 헤더
                  Text(
                    'COFFEE',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                      color: const Color(0xFF37352F),
                    ),
                  ),
                  Text(
                    'MAGAZINE',
                    style: GoogleFonts.libreBaskerville(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 6,
                      color: const Color(0xFF6B6B6B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 60,
                    height: 2,
                    color: const Color(0xFF37352F),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '커피에 대한 모든 것을 알아보세요',
                    style: GoogleFonts.notoSerifKr(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF9B9A97),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 카테고리 필터
          SliverToBoxAdapter(
            child: SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                  vertical: 8,
                ),
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = selectedCategory == category.$1;

                  return GestureDetector(
                    onTap: () {
                      ref.read(selectedCategoryProvider.notifier).state =
                          category.$1;
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFF7F6F3)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        category.$2,
                        style: AppTypography.labelMedium.copyWith(
                          color: isSelected
                              ? const Color(0xFF37352F)
                              : const Color(0xFF9B9A97),
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

          // 가이드 목록
          guidesAsync.when(
            loading: () => const SliverToBoxAdapter(
              child: SizedBox(
                height: 300,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF37352F),
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        '불러오는 중...',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF9B9A97),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            error: (error, _) => SliverToBoxAdapter(
              child: _buildEmptyState(
                icon: LucideIcons.alertTriangle,
                title: '오류가 발생했습니다',
                subtitle: error.toString(),
                actionLabel: '다시 시도',
                onAction: () => ref.invalidate(guidesProvider),
              ),
            ),
            data: (guides) {
              // 카테고리 필터링
              final filteredGuides = selectedCategory == 'all'
                  ? guides
                  : guides
                        .where((g) => g.category == selectedCategory)
                        .toList();

              if (filteredGuides.isEmpty) {
                return SliverToBoxAdapter(
                  child: _buildEmptyState(
                    icon: LucideIcons.fileText,
                    title: selectedCategory != 'all'
                        ? '선택한 카테고리에 가이드가 없습니다'
                        : '아직 작성된 가이드가 없습니다',
                    subtitle: null,
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final guide = filteredGuides[index];
                    final isLast = index == filteredGuides.length - 1;

                    return _GuideListItem(guide: guide, showBorder: !isLast);
                  }, childCount: filteredGuides.length),
                ),
              );
            },
          ),

          // 하단 여백
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxxl)),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    String? subtitle,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      padding: const EdgeInsets.symmetric(vertical: 64),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFFE5E2DE),
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F6F3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 28, color: const Color(0xFF9B9A97)),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTypography.titleSmall.copyWith(
              color: const Color(0xFF37352F),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTypography.bodySmall.copyWith(
                color: const Color(0xFF9B9A97),
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF37352F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              child: Text(actionLabel),
            ),
          ],
        ],
      ),
    );
  }
}

/// 노션 스타일 가이드 리스트 아이템
class _GuideListItem extends StatelessWidget {
  final CoffeeGuide guide;
  final bool showBorder;

  const _GuideListItem({required this.guide, this.showBorder = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: showBorder
            ? const Border(bottom: BorderSide(color: Color(0xFFE5E2DE)))
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/guide/${guide.id}'),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 커버 이미지
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 96,
                    height: 96,
                    child: guide.coverImage != null
                        ? CachedNetworkImage(
                            imageUrl: guide.coverImage!,
                            fit: BoxFit.cover,
                            placeholder: (_, __) =>
                                Container(color: const Color(0xFFF7F6F3)),
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
                      // 제목 - 아날로그 세리프 폰트
                      Text(
                        guide.title,
                        style: GoogleFonts.notoSerifKr(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF37352F),
                          height: 1.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      // 요약 - 세리프 폰트
                      Text(
                        guide.excerpt ?? _stripMarkdown(guide.content),
                        style: GoogleFonts.notoSerifKr(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF9B9A97),
                          height: 1.5,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 8),

                      // 태그들
                      Row(
                        children: [
                          // 카테고리
                          _buildTag(
                            guide.categoryLabel,
                            const Color(0xFFF7F6F3),
                            const Color(0xFF6B6B6B),
                          ),

                          const SizedBox(width: 6),

                          // 난이도
                          if (guide.difficulty != null)
                            _buildDifficultyTag(guide.difficulty!),

                          const Spacer(),

                          // 읽기 시간
                          if (guide.readingTimeMinutes != null)
                            Row(
                              children: [
                                const Icon(
                                  LucideIcons.clock,
                                  size: 12,
                                  color: Color(0xFF9B9A97),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${guide.readingTimeMinutes}분',
                                  style: AppTypography.caption.copyWith(
                                    color: const Color(0xFF9B9A97),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // 화살표
                const Icon(
                  LucideIcons.chevronRight,
                  size: 16,
                  color: Color(0xFF9B9A97),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFFF7F6F3),
      child: const Center(
        child: Icon(LucideIcons.fileText, size: 24, color: Color(0xFF9B9A97)),
      ),
    );
  }

  Widget _buildTag(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildDifficultyTag(String difficulty) {
    Color bgColor;
    Color textColor;

    switch (difficulty) {
      case 'beginner':
        bgColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF2E7D32);
        break;
      case 'intermediate':
        bgColor = const Color(0xFFE3F2FD);
        textColor = const Color(0xFF1565C0);
        break;
      case 'advanced':
        bgColor = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFEF6C00);
        break;
      default:
        bgColor = const Color(0xFFF7F6F3);
        textColor = const Color(0xFF6B6B6B);
    }

    String label;
    switch (difficulty) {
      case 'beginner':
        label = '초급';
        break;
      case 'intermediate':
        label = '중급';
        break;
      case 'advanced':
        label = '고급';
        break;
      default:
        label = difficulty;
    }

    return _buildTag(label, bgColor, textColor);
  }

  String _stripMarkdown(String text, {int maxLength = 100}) {
    if (text.isEmpty) return '';

    String stripped = text
        .replaceAll(RegExp(r'#{1,6}\s+'), '')
        .replaceAll(RegExp(r'\|'), ' ')
        .replaceAll(RegExp(r'[-]{3,}'), '')
        .replaceAll(RegExp(r'(\*\*|__)(.*?)\1'), r'$2')
        .replaceAll(RegExp(r'(\*|_)(.*?)\1'), r'$2')
        .replaceAll(RegExp(r'`([^`]+)`'), r'$1')
        .replaceAll(RegExp(r'```[\s\S]*?```'), '')
        .replaceAll(RegExp(r'\[([^\]]+)\]\([^)]+\)'), r'$1')
        .replaceAll(RegExp(r'!\[([^\]]*)\]\([^)]+\)'), '')
        .replaceAll(RegExp(r'^\s*[-*+]\s+', multiLine: true), '')
        .replaceAll(RegExp(r'^\s*\d+\.\s+', multiLine: true), '')
        .replaceAll(RegExp(r'^\s*>\s+', multiLine: true), '')
        .replaceAll(RegExp(r'^\s*[-*_]{3,}\s*$', multiLine: true), '')
        .replaceAll(RegExp(r'\n+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (stripped.length > maxLength) {
      stripped = '${stripped.substring(0, maxLength).trim()}...';
    }

    return stripped;
  }
}

/// 데스크톱 매거진 화면
class _MagazineScreenDesktop extends ConsumerWidget {
  final List<(String, String)> categories;

  const _MagazineScreenDesktop({required this.categories});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final guidesAsync = ref.watch(guidesProvider);

    return Row(
      children: [
        // 왼쪽 사이드바 (카테고리)
        Container(
          width: 240,
          decoration: BoxDecoration(
            color: const Color(0xFFFBFAF9),
            border: Border(right: BorderSide(color: AppColors.gray200)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'COFFEE',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                        color: const Color(0xFF37352F),
                      ),
                    ),
                    Text(
                      'MAGAZINE',
                      style: GoogleFonts.libreBaskerville(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 5,
                        color: const Color(0xFF6B6B6B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 40,
                      height: 2,
                      color: const Color(0xFF37352F),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // 카테고리 목록
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = selectedCategory == category.$1;

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          ref.read(selectedCategoryProvider.notifier).state =
                              category.$1;
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFF7F6F3)
                                : Colors.transparent,
                            border: Border(
                              left: BorderSide(
                                color: isSelected
                                    ? const Color(0xFF37352F)
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                          child: Text(
                            category.$2,
                            style: GoogleFonts.notoSansKr(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected
                                  ? const Color(0xFF37352F)
                                  : const Color(0xFF9B9A97),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // 메인 콘텐츠
        Expanded(
          child: guidesAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF37352F),
              ),
            ),
            error: (error, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    LucideIcons.alertTriangle,
                    size: 48,
                    color: Color(0xFF9B9A97),
                  ),
                  const SizedBox(height: 16),
                  Text('오류가 발생했습니다', style: AppTypography.titleSmall),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => ref.invalidate(guidesProvider),
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            ),
            data: (guides) {
              final filteredGuides = selectedCategory == 'all'
                  ? guides
                  : guides
                        .where((g) => g.category == selectedCategory)
                        .toList();

              if (filteredGuides.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        LucideIcons.fileText,
                        size: 64,
                        color: Color(0xFF9B9A97),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        selectedCategory != 'all'
                            ? '선택한 카테고리에 가이드가 없습니다'
                            : '아직 작성된 가이드가 없습니다',
                        style: AppTypography.titleSmall.copyWith(
                          color: const Color(0xFF9B9A97),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return CustomScrollView(
                slivers: [
                  // 상단 헤더
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(32, 32, 32, 16),
                      child: Row(
                        children: [
                          Text(
                            selectedCategory == 'all'
                                ? '전체 가이드'
                                : categories
                                      .firstWhere(
                                        (c) => c.$1 == selectedCategory,
                                      )
                                      .$2,
                            style: GoogleFonts.notoSerifKr(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF37352F),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F6F3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${filteredGuides.length}',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF6B6B6B),
                              ),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => ref.invalidate(guidesProvider),
                            icon: const Icon(LucideIcons.refreshCw, size: 18),
                            tooltip: '새로고침',
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 그리드 뷰
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 400,
                            mainAxisSpacing: 24,
                            crossAxisSpacing: 24,
                            childAspectRatio: 1.1,
                          ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final guide = filteredGuides[index];
                        return _GuideCardDesktop(guide: guide);
                      }, childCount: filteredGuides.length),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

/// 데스크톱용 가이드 카드
class _GuideCardDesktop extends StatelessWidget {
  final CoffeeGuide guide;

  const _GuideCardDesktop({required this.guide});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.gray200),
      ),
      child: InkWell(
        onTap: () => context.push('/guide/${guide.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 커버 이미지
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                color: const Color(0xFFF7F6F3),
                child: guide.coverImage != null
                    ? CachedNetworkImage(
                        imageUrl: guide.coverImage!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: const Color(0xFFF7F6F3),
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (_, __, ___) => const Center(
                          child: Icon(
                            LucideIcons.fileText,
                            size: 32,
                            color: Color(0xFF9B9A97),
                          ),
                        ),
                      )
                    : const Center(
                        child: Icon(
                          LucideIcons.fileText,
                          size: 32,
                          color: Color(0xFF9B9A97),
                        ),
                      ),
              ),
            ),

            // 정보
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 상단 정보
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 카테고리 & 난이도
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF7F6F3),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                guide.categoryLabel,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF6B6B6B),
                                ),
                              ),
                            ),
                            if (guide.difficulty != null) ...[
                              const SizedBox(width: 4),
                              _buildDifficultyBadge(guide.difficulty!),
                            ],
                          ],
                        ),

                        const SizedBox(height: 6),

                        // 제목
                        Text(
                          guide.title,
                          style: GoogleFonts.notoSerifKr(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF37352F),
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),

                    // 읽기 시간
                    if (guide.readingTimeMinutes != null)
                      Row(
                        children: [
                          const Icon(
                            LucideIcons.clock,
                            size: 11,
                            color: Color(0xFF9B9A97),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${guide.readingTimeMinutes}분',
                            style: AppTypography.caption.copyWith(
                              fontSize: 11,
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
    );
  }

  Widget _buildDifficultyBadge(String difficulty) {
    Color bgColor;
    Color textColor;
    String label;

    switch (difficulty) {
      case 'beginner':
        bgColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF2E7D32);
        label = '초급';
        break;
      case 'intermediate':
        bgColor = const Color(0xFFE3F2FD);
        textColor = const Color(0xFF1565C0);
        label = '중급';
        break;
      case 'advanced':
        bgColor = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFEF6C00);
        label = '고급';
        break;
      default:
        bgColor = const Color(0xFFF7F6F3);
        textColor = const Color(0xFF6B6B6B);
        label = difficulty;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }
}
