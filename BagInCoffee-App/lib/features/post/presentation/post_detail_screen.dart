import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../api/api.dart';
import '../../home/data/post_provider.dart';

/// 게시물 상세 화면
class PostDetailScreen extends ConsumerStatefulWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  bool _isLiking = false;
  bool? _hasLiked;
  int? _likesCount;

  @override
  Widget build(BuildContext context) {
    final postAsync = ref.watch(postDetailProvider(widget.postId));

    return Scaffold(
      backgroundColor: Colors.white,
      body: postAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildError(error.toString()),
        data: (post) {
          if (post == null) {
            return _buildError('게시물을 찾을 수 없습니다');
          }

          // 초기값 설정
          _hasLiked ??= post.hasLiked;
          _likesCount ??= post.likesCount;

          return _buildContent(post);
        },
      ),
    );
  }

  Widget _buildError(String message) {
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
          Text(message, style: AppTypography.bodyMedium),
          const SizedBox(height: AppSpacing.md),
          TextButton(onPressed: () => context.pop(), child: const Text('돌아가기')),
        ],
      ),
    );
  }

  Widget _buildContent(PostWithAuthor post) {
    return CustomScrollView(
      slivers: [
        // 앱바
        SliverAppBar(
          pinned: true,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              LucideIcons.arrowLeft,
              color: AppColors.textPrimary,
            ),
            onPressed: () => context.pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                LucideIcons.share2,
                color: AppColors.textPrimary,
              ),
              onPressed: () {
                // TODO: 공유
              },
            ),
            IconButton(
              icon: const Icon(
                LucideIcons.moreVertical,
                color: AppColors.textPrimary,
              ),
              onPressed: () {
                _showMoreOptions(post);
              },
            ),
          ],
        ),

        // 이미지 갤러리
        if (post.images.isNotEmpty)
          SliverToBoxAdapter(
            child: SizedBox(
              height: 300,
              child: PageView.builder(
                itemCount: post.images.length,
                itemBuilder: (context, index) {
                  return CachedNetworkImage(
                    imageUrl: post.images[index],
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: AppColors.gray100,
                      child: const Center(child: CircularProgressIndicator()),
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

        // 콘텐츠
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 작성자 정보
                _buildAuthorSection(post),

                const SizedBox(height: AppSpacing.lg),

                // 제목
                if (post.title != null && post.title!.isNotEmpty) ...[
                  Text(
                    post.title!,
                    style: AppTypography.headlineSmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],

                // 본문
                Text(
                  post.content,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.7,
                  ),
                ),

                // 태그
                if (post.tags.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: post.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '#$tag',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: AppSpacing.lg),
                const Divider(color: AppColors.gray200),
                const SizedBox(height: AppSpacing.md),

                // 통계
                _buildStatsSection(post),

                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),

        // 댓글 섹션
        SliverToBoxAdapter(child: _buildCommentsSection(post)),

        // 하단 여백
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildAuthorSection(PostWithAuthor post) {
    return InkWell(
      onTap: () {
        if (post.authorId != null) {
          context.push('/user/${post.authorId}');
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            // 아바타
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.gray200,
              backgroundImage: post.author?.avatarUrl != null
                  ? CachedNetworkImageProvider(post.author!.avatarUrl!)
                  : null,
              child: post.author?.avatarUrl == null
                  ? const Icon(LucideIcons.user, color: AppColors.gray400)
                  : null,
            ),
            const SizedBox(width: AppSpacing.md),

            // 이름 & 시간
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.author?.username ?? '익명',
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _formatTimeAgo(post.createdAt),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // 팔로우 버튼 (추후 구현)
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(PostWithAuthor post) {
    final isLoggedIn = ref.watch(isLoggedInProvider);

    return Row(
      children: [
        // 좋아요
        _buildStatButton(
          icon: (_hasLiked ?? false) ? LucideIcons.heart : LucideIcons.heart,
          iconColor: (_hasLiked ?? false) ? Colors.red : AppColors.gray500,
          filled: _hasLiked ?? false,
          label: '${_likesCount ?? post.likesCount}',
          onTap: isLoggedIn ? () => _toggleLike(post) : null,
        ),

        const SizedBox(width: AppSpacing.lg),

        // 댓글
        _buildStatButton(
          icon: LucideIcons.messageCircle,
          iconColor: AppColors.gray500,
          label: '${post.commentsCount}',
          onTap: () {
            // TODO: 댓글로 스크롤
          },
        ),

        const SizedBox(width: AppSpacing.lg),

        // 조회수
        _buildStatButton(
          icon: LucideIcons.eye,
          iconColor: AppColors.gray500,
          label: '${post.viewsCount}',
        ),

        const Spacer(),

        // 북마크
        IconButton(
          icon: const Icon(LucideIcons.bookmark, color: AppColors.gray500),
          onPressed: () {
            // TODO: 북마크
          },
        ),
      ],
    );
  }

  Widget _buildStatButton({
    required IconData icon,
    required Color iconColor,
    required String label,
    bool filled = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsSection(PostWithAuthor post) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      decoration: const BoxDecoration(
        color: AppColors.gray50,
        border: Border(top: BorderSide(color: AppColors.gray200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '댓글',
                style: AppTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.gray200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${post.commentsCount}',
                  style: AppTypography.labelSmall,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // 댓글 입력
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gray200),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.gray200,
                  child: Icon(
                    LucideIcons.user,
                    size: 16,
                    color: AppColors.gray400,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '댓글을 입력하세요...',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.gray400,
                    ),
                  ),
                ),
                const Icon(
                  LucideIcons.send,
                  size: 20,
                  color: AppColors.gray400,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // 댓글 목록 (더미)
          if (post.commentsCount == 0)
            Center(
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.lg),
                  const Icon(
                    LucideIcons.messageCircle,
                    size: 40,
                    color: AppColors.gray300,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '아직 댓글이 없습니다',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '첫 번째 댓글을 남겨보세요!',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.gray400,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _toggleLike(PostWithAuthor post) async {
    if (_isLiking) return;

    setState(() {
      _isLiking = true;
      _hasLiked = !(_hasLiked ?? false);
      _likesCount = (_likesCount ?? post.likesCount) + (_hasLiked! ? 1 : -1);
    });

    try {
      await postsApi.toggleLike(post.id);
    } catch (e) {
      // 롤백
      setState(() {
        _hasLiked = !_hasLiked!;
        _likesCount = _likesCount! + (_hasLiked! ? 1 : -1);
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('오류: $e')));
      }
    } finally {
      setState(() => _isLiking = false);
    }
  }

  void _showMoreOptions(PostWithAuthor post) {
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
                    // 수정 완료 시 화면 새로고침
                    if (result == true) {
                      ref.invalidate(postDetailProvider(post.id));
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
                    _confirmDelete(post);
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

  void _confirmDelete(PostWithAuthor post) {
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

              // 로딩 표시
              if (mounted) {
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
              }

              try {
                await postsApi.delete(post.id);

                // Provider 새로고침
                ref.invalidate(postsProvider);
                ref.invalidate(popularPostsProvider);
                ref.invalidate(myPostsProvider);

                if (mounted) {
                  context.pop(); // 상세 화면 닫기
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('게시물이 삭제되었습니다'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
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

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 365) {
      return '${diff.inDays ~/ 365}년 전';
    } else if (diff.inDays > 30) {
      return '${diff.inDays ~/ 30}개월 전';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}일 전';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}시간 전';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }
}

/// Bottom Sheet Item Widget - Uber Style
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
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyMedium.copyWith(
                  color: labelColor ?? AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
