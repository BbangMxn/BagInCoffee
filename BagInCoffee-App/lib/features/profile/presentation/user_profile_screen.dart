import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../api/api.dart';
import '../../home/data/post_provider.dart';

/// 다른 사용자의 프로필 Provider
final userProfileByIdProvider = FutureProvider.family<UserProfile?, String>((
  ref,
  userId,
) async {
  try {
    return await usersApi.getById(userId);
  } catch (e) {
    throw Exception('프로필을 불러올 수 없습니다: $e');
  }
});

/// 다른 사용자의 게시물 Provider
final userPostsProvider = FutureProvider.family<List<PostWithAuthor>, String>((
  ref,
  userId,
) async {
  try {
    // TODO: 백엔드에 사용자별 게시물 조회 API 추가 필요
    // 임시로 전체 게시물에서 필터링
    final allPosts = await postsApi.list();
    return allPosts.where((post) => post.authorId == userId).toList();
  } catch (e) {
    throw Exception('게시물을 불러올 수 없습니다: $e');
  }
});

/// 다른 사용자 프로필 화면 (Uber 디자인)
class UserProfileScreen extends ConsumerStatefulWidget {
  final String userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileByIdProvider(widget.userId));

    return Scaffold(
      backgroundColor: Colors.white,
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildError(error.toString()),
        data: (profile) => _buildProfileContent(context, profile),
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
          const SizedBox(height: 16),
          Text('프로필을 불러올 수 없습니다', style: AppTypography.bodyMedium),
          const SizedBox(height: 16),
          TextButton(onPressed: () => context.pop(), child: const Text('돌아가기')),
        ],
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, dynamic profile) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
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
                  LucideIcons.moreVertical,
                  color: AppColors.textPrimary,
                ),
                onPressed: () => _showMoreOptions(),
              ),
            ],
          ),

          // 프로필 헤더
          SliverToBoxAdapter(
            child: _UserProfileHeader(userId: widget.userId, profile: profile),
          ),

          // 탭바
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverTabBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: AppColors.textPrimary,
                unselectedLabelColor: AppColors.textTertiary,
                indicatorColor: AppColors.primary,
                indicatorWeight: 2,
                labelStyle: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                tabs: const [
                  Tab(text: '게시물'),
                  Tab(text: '리뷰'),
                ],
              ),
            ),
          ),
        ];
      },
      body: TabBarView(
        controller: _tabController,
        children: [
          // 게시물 탭
          _UserPostsTab(userId: widget.userId),
          // 리뷰 탭
          _UserReviewsTab(),
        ],
      ),
    );
  }

  void _showMoreOptions() {
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

              _BottomSheetItem(
                icon: LucideIcons.flag,
                iconColor: AppColors.textSecondary,
                label: '사용자 신고',
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
                iconColor: AppColors.error,
                label: '사용자 차단',
                labelColor: AppColors.error,
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('차단 기능은 준비 중입니다')),
                  );
                },
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

/// 사용자 프로필 헤더
class _UserProfileHeader extends StatelessWidget {
  final String userId;
  final dynamic profile;

  const _UserProfileHeader({required this.userId, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.gray200, width: 1)),
      ),
      child: Column(
        children: [
          // 아바타
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.gray200,
            backgroundImage: profile?.avatarUrl != null
                ? CachedNetworkImageProvider(
                    profile!.avatarUrl!,
                    maxWidth: 200,
                    maxHeight: 200,
                  )
                : null,
            child: profile?.avatarUrl == null
                ? const Icon(
                    LucideIcons.user,
                    size: 50,
                    color: AppColors.gray500,
                  )
                : null,
          ),

          const SizedBox(height: AppSpacing.lg),

          // 이름
          Text(
            profile?.username ?? '사용자',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          // Bio
          if (profile?.bio != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              profile!.bio!,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],

          const SizedBox(height: AppSpacing.lg),

          // 팔로우 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: 팔로우 기능
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('팔로우 기능은 준비 중입니다')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(LucideIcons.userPlus, size: 18),
              label: Text(
                '팔로우',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 사용자 게시물 탭
class _UserPostsTab extends ConsumerWidget {
  final String userId;

  const _UserPostsTab({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(userPostsProvider(userId));

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
            const SizedBox(height: 16),
            Text('게시물을 불러올 수 없습니다', style: AppTypography.bodyMedium),
          ],
        ),
      ),
      data: (posts) {
        if (posts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  LucideIcons.coffee,
                  size: 64,
                  color: AppColors.gray300,
                ),
                const SizedBox(height: 24),
                Text('작성한 게시물이 없습니다', style: AppTypography.headlineSmall),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          itemCount: posts.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final post = posts[index];
            return RepaintBoundary(
              child: Card(
                elevation: 0,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: AppColors.gray200, width: 1),
                ),
                child: InkWell(
                  onTap: () => context.push('/post/${post.id}'),
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 이미지
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
                              memCacheHeight: 450,
                              fadeInDuration: const Duration(milliseconds: 200),
                              fadeOutDuration: const Duration(
                                milliseconds: 100,
                              ),
                              placeholder: (_, __) => Container(
                                color: AppColors.gray100,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                              errorWidget: (_, __, ___) => Container(
                                color: AppColors.gray100,
                                child: const Icon(
                                  LucideIcons.image,
                                  size: 32,
                                  color: AppColors.gray400,
                                ),
                              ),
                            ),
                          ),
                        ),

                      // 본문
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.content,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                color: AppColors.textPrimary,
                                height: 1.5,
                              ),
                              maxLines: post.images.isEmpty ? 4 : 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(
                                  LucideIcons.heart,
                                  size: 16,
                                  color: AppColors.gray500,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${post.likesCount}',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: AppColors.gray600,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Icon(
                                  LucideIcons.messageCircle,
                                  size: 16,
                                  color: AppColors.gray500,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${post.commentsCount}',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: AppColors.gray600,
                                  ),
                                ),
                                if (post.images.length > 1) ...[
                                  const Spacer(),
                                  Icon(
                                    LucideIcons.image,
                                    size: 16,
                                    color: AppColors.gray500,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${post.images.length}',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: AppColors.gray600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
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

/// 사용자 리뷰 탭
class _UserReviewsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.star, size: 64, color: AppColors.gray300),
          const SizedBox(height: 24),
          Text('작성한 리뷰가 없습니다', style: AppTypography.headlineSmall),
        ],
      ),
    );
  }
}

/// Bottom Sheet Item
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

/// SliverTabBar Delegate
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => 48;

  @override
  double get maxExtent => 48;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.white, child: tabBar);
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}
