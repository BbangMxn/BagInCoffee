import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/widgets/animated_list_item.dart' show FadeInWidget;
import '../../../api/api.dart';
import '../data/post_provider.dart';

import 'home_screen_desktop.dart';

// 반응형 레이아웃 상수
class _ResponsiveBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1024;
}

/// 선택된 해시태그 Provider
final selectedHashtagProvider = StateProvider<String?>((ref) => null);

/// 홈 화면 (피드)
/// PC에서는 HomeScreenDesktop, 모바일에서는 모바일 레이아웃 사용
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // PC 버전
        if (constraints.maxWidth >= _ResponsiveBreakpoints.desktop) {
          return const HomeScreenDesktop();
        }

        // 모바일/태블릿 버전
        return const _HomeScreenMobile();
      },
    );
  }
}

/// 모바일 홈 화면
class _HomeScreenMobile extends ConsumerWidget {
  const _HomeScreenMobile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTag = ref.watch(selectedHashtagProvider);
    final postsAsync = selectedTag == null
        ? ref.watch(postsProvider)
        : ref.watch(postsByTagProvider(selectedTag));

    return postsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              LucideIcons.alertCircle,
              size: 48,
              color: AppColors.gray400,
            ),
            const SizedBox(height: AppSpacing.md),
            Text('피드를 불러올 수 없습니다', style: AppTypography.bodyMedium),
            const SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: () => ref.invalidate(postsProvider),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
      data: (posts) {
        return LayoutBuilder(
          builder: (context, constraints) {
            // 화면 크기에 따라 최대 너비 제한 (PC 버전 지원)
            final maxWidth =
                constraints.maxWidth > _ResponsiveBreakpoints.desktop
                ? 800.0
                : constraints.maxWidth > _ResponsiveBreakpoints.tablet
                ? 700.0
                : double.infinity;

            return RefreshIndicator(
              onRefresh: () async {
                final selectedTag = ref.read(selectedHashtagProvider);
                if (selectedTag == null) {
                  ref.invalidate(postsProvider);
                } else {
                  ref.invalidate(postsByTagProvider(selectedTag));
                }
              },
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: CustomScrollView(
                    slivers: [
                      // 해시태그 필터
                      SliverToBoxAdapter(child: _HashtagFilter()),

                      // 게시물 목록
                      SliverPadding(
                        padding: EdgeInsets.all(
                          constraints.maxWidth > _ResponsiveBreakpoints.tablet
                              ? AppSpacing.lg
                              : AppSpacing.screenPadding,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: index < posts.length - 1
                                    ? AppSpacing.md
                                    : 0,
                              ),
                              child: RepaintBoundary(
                                child: _PostCard(post: posts[index]),
                              ),
                            );
                          }, childCount: posts.length),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// 해시태그 필터 위젯
class _HashtagFilter extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTag = ref.watch(selectedHashtagProvider);

    // 고정 해시태그 목록
    final popularTags = ['전체', '일상', '카페탐방', '질문', '장비추천', '브루잉', '에스프레소'];

    return FadeInWidget(
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: AppColors.gray200, width: 1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.hash, size: 18, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  '해시태그',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (selectedTag != null)
                  TextButton(
                    onPressed: () =>
                        ref.read(selectedHashtagProvider.notifier).state = null,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      '전체보기',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: popularTags.map((tag) {
                  final isSelected = selectedTag == tag;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(tag == '전체' ? tag : '#$tag'),
                      selected: tag == '전체' ? selectedTag == null : isSelected,
                      onSelected: (selected) {
                        if (tag == '전체') {
                          ref.read(selectedHashtagProvider.notifier).state =
                              null;
                        } else {
                          ref.read(selectedHashtagProvider.notifier).state =
                              selected ? tag : null;
                        }
                      },
                      backgroundColor: Colors.white,
                      selectedColor: AppColors.primary.withValues(alpha: 0.15),
                      checkmarkColor: AppColors.primary,
                      labelStyle: AppTypography.labelMedium.copyWith(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.gray300,
                        width: isSelected ? 1.5 : 1,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 게시물 카드 위젯
class _PostCard extends ConsumerWidget {
  final PostWithAuthor post;

  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.gray200, width: 1),
      ),
      child: InkWell(
        onTap: () => context.push('/post/${post.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 작성자 정보
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.gray200,
                    backgroundImage: post.author?.avatarUrl != null
                        ? CachedNetworkImageProvider(
                            post.author!.avatarUrl!,
                            maxWidth: 72,
                            maxHeight: 72,
                          )
                        : null,
                    child: post.author?.avatarUrl == null
                        ? const Icon(
                            LucideIcons.user,
                            size: 18,
                            color: AppColors.gray500,
                          )
                        : null,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.author?.username ?? '사용자',
                          style: AppTypography.labelLarge,
                        ),
                        Text(
                          _formatDate(post.createdAt),
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showMoreOptions(context, ref, post),
                    icon: const Icon(LucideIcons.moreHorizontal, size: 20),
                    color: AppColors.gray500,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // 본문
              Text(
                post.content,
                style: AppTypography.bodyMedium.copyWith(
                  height: 1.6,
                  color: AppColors.textSecondary,
                  fontSize: 15,
                ),
                maxLines: post.images.isEmpty ? 10 : 4,
                overflow: TextOverflow.ellipsis,
              ),

              // 이미지
              if (post.images.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                _PostImageCarousel(images: post.images),
              ],

              // 태그
              if (post.tags.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.xs,
                  children: post.tags
                      .map(
                        (tag) => Text(
                          '#$tag',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.accent,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],

              const SizedBox(height: AppSpacing.md),

              // 좋아요, 댓글, 시간
              Row(
                children: [
                  Icon(LucideIcons.heart, size: 20, color: AppColors.gray500),
                  const SizedBox(width: 6),
                  Text(
                    '${post.likesCount}',
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    LucideIcons.messageCircle,
                    size: 20,
                    color: AppColors.gray500,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${post.commentsCount}',
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(post.createdAt),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inHours < 1) return '${diff.inMinutes}분 전';
    if (diff.inDays < 1) return '${diff.inHours}시간 전';
    if (diff.inDays < 7) return '${diff.inDays}일 전';
    return '${date.month}/${date.day}';
  }

  static void _showMoreOptions(
    BuildContext context,
    WidgetRef ref,
    PostWithAuthor post,
  ) {
    final currentUserId = ref.read(currentUserProvider)?.id;
    final isOwner = currentUserId == post.authorId;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.gray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              if (isOwner) ...[
                _BottomSheetItem(
                  icon: LucideIcons.pencil,
                  iconColor: AppColors.primary,
                  label: '게시물 수정',
                  onTap: () async {
                    Navigator.pop(context);
                    final result = await context.push('/post/edit/${post.id}');
                    if (result == true) {
                      ref.invalidate(postsProvider);
                    }
                  },
                ),
                const Divider(height: 1, indent: 58),
                _BottomSheetItem(
                  icon: LucideIcons.trash2,
                  iconColor: AppColors.error,
                  label: '게시물 삭제',
                  labelColor: AppColors.error,
                  onTap: () {
                    Navigator.pop(context);
                    _confirmDelete(context, ref, post);
                  },
                ),
              ] else ...[
                _BottomSheetItem(
                  icon: LucideIcons.flag,
                  iconColor: AppColors.textSecondary,
                  label: '게시물 신고',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('신고 기능은 준비 중입니다')),
                    );
                  },
                ),
                const Divider(height: 1, indent: 58),
                _BottomSheetItem(
                  icon: LucideIcons.userX,
                  iconColor: AppColors.textSecondary,
                  label: '사용자 차단',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('차단 기능은 준비 중입니다')),
                    );
                  },
                ),
              ],

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  static void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    PostWithAuthor post,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('게시물 삭제'),
        content: const Text('이 게시물을 삭제하시겠습니까?\n삭제한 게시물은 복구할 수 없습니다.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text('삭제 중...'),
                    ],
                  ),
                  duration: Duration(seconds: 2),
                ),
              );

              try {
                await postsApi.delete(post.id);
                ref.invalidate(postsProvider);
                ref.invalidate(popularPostsProvider);
                ref.invalidate(myPostsProvider);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('게시물이 삭제되었습니다'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('삭제 실패: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('삭제', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

/// Post 이미지 캐러셀
class _PostImageCarousel extends StatefulWidget {
  final List<String> images;

  const _PostImageCarousel({required this.images});

  @override
  State<_PostImageCarousel> createState() => _PostImageCarouselState();
}

class _PostImageCarouselState extends State<_PostImageCarousel> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 이미지 페이지뷰
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 320,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemCount: widget.images.length,
              // 성능 최적화: 한 번에 하나의 페이지만 빌드
              allowImplicitScrolling: false,
              itemBuilder: (context, index) {
                return CachedNetworkImage(
                  imageUrl: widget.images[index],
                  width: double.infinity,
                  fit: BoxFit.cover,
                  // 메모리 캐시 최적화
                  memCacheWidth: 1200,
                  memCacheHeight: 800,
                  // 캐시 우선 사용
                  cacheKey: widget.images[index],
                  // 빠른 fade-in 애니메이션
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
                      LucideIcons.image,
                      size: 48,
                      color: AppColors.gray400,
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // 페이지 인디케이터 (2개 이상일 때만)
        if (widget.images.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.images.length,
                (index) => Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        // 이미지 개수 표시 (우측 상단)
        if (widget.images.length > 1)
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_currentPage + 1}/${widget.images.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _BottomSheetItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final Color? labelColor;
  final VoidCallback onTap;

  const _BottomSheetItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.labelColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 22, color: iconColor),
            const SizedBox(width: 16),
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: labelColor ?? AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
