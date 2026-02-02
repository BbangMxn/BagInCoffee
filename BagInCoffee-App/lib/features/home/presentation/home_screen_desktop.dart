import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../api/api.dart';
import '../data/post_provider.dart';

/// PC 버전 홈 화면 (웹 최적화)
/// - 2단 레이아웃: 중앙 피드 (그리드) | 오른쪽 사이드바
/// - 넓은 화면 활용 그리드 레이아웃
/// - 깔끔하고 현대적인 카드 디자인
class HomeScreenDesktop extends ConsumerWidget {
  const HomeScreenDesktop({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(postsProvider);

    return Container(
      color: AppColors.gray50,
      child: Row(
        children: [
          // 중앙: 메인 피드 (그리드 레이아웃)
          Expanded(
            child: postsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              error: (error, stack) =>
                  _ErrorView(onRetry: () => ref.invalidate(postsProvider)),
              data: (posts) {
                if (posts.isEmpty) {
                  return const _EmptyState();
                }

                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(postsProvider),
                  child: CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.all(24),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 400,
                                childAspectRatio: 0.85,
                                mainAxisSpacing: 20,
                                crossAxisSpacing: 20,
                              ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) =>
                                _PostCardDesktop(post: posts[index]),
                            childCount: posts.length,
                          ),
                        ),
                      ),
                    ],
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

/// 웹 버전 포스트 카드 (그리드 최적화)
class _PostCardDesktop extends ConsumerWidget {
  final PostWithAuthor post;

  const _PostCardDesktop({required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () => context.push('/post/${post.id}'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gray200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지 (있는 경우)
            if (post.images.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: CachedNetworkImage(
                    imageUrl: post.images.first,
                    fit: BoxFit.cover,
                    memCacheWidth: 800,
                    placeholder: (context, url) => Container(
                      color: AppColors.gray100,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.gray100,
                      child: const Icon(
                        Icons.error_outline,
                        color: AppColors.gray400,
                      ),
                    ),
                  ),
                ),
              ),

            // 콘텐츠
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 헤더: 이름 + 시간 + 더보기
                    Row(
                      children: [
                        Text(
                          post.author?.username ?? '사용자',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '·',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            color: AppColors.gray400,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(post.createdAt),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => _showMoreOptions(context, ref, post),
                          icon: const Icon(
                            LucideIcons.moreHorizontal,
                            size: 18,
                          ),
                          color: AppColors.gray500,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          splashRadius: 18,
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // 본문
                    Expanded(
                      child: Text(
                        post.content,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          height: 1.5,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // 태그
                    if (post.tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: post.tags
                            .take(3)
                            .map(
                              (tag) => Text(
                                '#$tag',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],

                    const SizedBox(height: 12),

                    // 액션 바: 좋아요, 댓글
                    Row(
                      children: [
                        _ActionButton(
                          icon: LucideIcons.heart,
                          count: post.likesCount,
                          onTap: () {},
                        ),
                        const SizedBox(width: 24),
                        _ActionButton(
                          icon: LucideIcons.messageCircle,
                          count: post.commentsCount,
                          onTap: () => context.push('/post/${post.id}'),
                        ),
                        const SizedBox(width: 24),
                        _ActionButton(icon: LucideIcons.share2, onTap: () {}),
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inHours < 1) return '${diff.inMinutes}분';
    if (diff.inDays < 1) return '${diff.inHours}시간';
    if (diff.inDays < 7) return '${diff.inDays}일';
    return '${date.month}/${date.day}';
  }

  void _showMoreOptions(
    BuildContext context,
    WidgetRef ref,
    PostWithAuthor post,
  ) {
    final currentUserId = ref.read(currentUserProvider)?.id;
    final isOwner = currentUserId == post.authorId;

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(1000, 100, 0, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: [
        if (isOwner) ...[
          PopupMenuItem(
            onTap: () async {
              await Future.delayed(Duration.zero);
              final result = await context.push('/post/edit/${post.id}');
              if (result == true) {
                ref.invalidate(postsProvider);
              }
            },
            child: Row(
              children: [
                const Icon(
                  LucideIcons.pencil,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  '수정',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuItem(
            onTap: () => _confirmDelete(context, ref, post),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.trash2,
                  size: 18,
                  color: AppColors.error,
                ),
                const SizedBox(width: 12),
                Text(
                  '삭제',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          PopupMenuItem(
            child: Row(
              children: [
                const Icon(LucideIcons.flag, size: 18),
                const SizedBox(width: 12),
                Text('신고', style: GoogleFonts.inter(fontSize: 14)),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    PostWithAuthor post,
  ) async {
    await Future.delayed(Duration.zero);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          '게시물 삭제',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Text(
          '이 게시물을 삭제하시겠습니까?\n삭제한 게시물은 복구할 수 없습니다.',
          style: GoogleFonts.inter(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '취소',
              style: GoogleFonts.inter(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await postsApi.delete(post.id);
                ref.invalidate(postsProvider);
              } catch (e) {
                // 에러 처리
              }
            },
            child: Text('삭제', style: GoogleFonts.inter(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

/// 액션 버튼 (좋아요, 댓글, 공유)
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final int? count;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.gray600),
            if (count != null) ...[
              const SizedBox(width: 6),
              Text(
                '$count',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
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
          Text('피드를 불러올 수 없습니다', style: AppTypography.bodyMedium),
          const SizedBox(height: 16),
          TextButton(onPressed: onRetry, child: const Text('다시 시도')),
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
          Text('아직 게시물이 없습니다', style: AppTypography.headlineSmall),
          const SizedBox(height: 8),
          Text(
            '첫 번째 커피 이야기를 공유해보세요!',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
