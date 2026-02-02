import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../home/data/post_provider.dart';
import 'profile_screen_desktop.dart';

/// 반응형 브레이크포인트
const double _kDesktopBreakpoint = 900;

/// 프로필 화면 (Uber 디자인)
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
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
    final isLoggedIn = ref.watch(isLoggedInProvider);
    final currentUser = ref.watch(currentUserProvider);
    final profileAsync = ref.watch(userProfileProvider);

    if (!isLoggedIn) {
      return _LoginPrompt();
    }

    return profileAsync.when(
      loading: () => const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: Colors.white,
        body: Center(
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
              TextButton(
                onPressed: () => ref.invalidate(userProfileProvider),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      ),
      data: (profile) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop =
                kIsWeb && constraints.maxWidth >= _kDesktopBreakpoint;
            if (isDesktop) {
              return ProfileScreenDesktop(
                tabController: _tabController,
                profile: profile,
                currentUser: currentUser,
              );
            }
            return _buildProfileContent(context, profile, currentUser);
          },
        );
      },
    );
  }

  /// 모바일 프로필 레이아웃
  Widget _buildProfileContent(
    BuildContext context,
    dynamic profile,
    dynamic currentUser,
  ) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // 프로필 헤더
            SliverToBoxAdapter(
              child: _ProfileHeader(profile: profile, currentUser: currentUser),
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
            // 내 게시물 탭
            _MyPostsTab(),
            // 내 리뷰 탭
            _MyReviewsTab(),
          ],
        ),
      ),
    );
  }
}

/// 프로필 헤더
class _ProfileHeader extends StatelessWidget {
  final dynamic profile;
  final dynamic currentUser;

  const _ProfileHeader({required this.profile, required this.currentUser});

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
          const SizedBox(height: 8),

          // 아바타
          Stack(
            children: [
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
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    LucideIcons.camera,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // 이름
          Text(
            profile?.username ?? currentUser?.email?.split('@')[0] ?? '사용자',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          if (currentUser?.email != null) ...[
            const SizedBox(height: 4),
            Text(
              currentUser!.email!,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],

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

          // Location & Website
          if (profile?.location != null || profile?.website != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (profile?.location != null) ...[
                  const Icon(
                    LucideIcons.mapPin,
                    size: 16,
                    color: AppColors.gray500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    profile!.location!,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                if (profile?.location != null && profile?.website != null)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '·',
                      style: TextStyle(color: AppColors.gray400),
                    ),
                  ),
                if (profile?.website != null) ...[
                  const Icon(
                    LucideIcons.link,
                    size: 16,
                    color: AppColors.gray500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    profile!.website!,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ],
            ),
          ],

          const SizedBox(height: AppSpacing.lg),

          // 프로필 수정 & 설정 버튼
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/profile/edit'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: BorderSide(color: AppColors.gray300, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(LucideIcons.pencil, size: 18),
                  label: Text(
                    '프로필 수정',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 52,
                height: 52,
                child: OutlinedButton(
                  onPressed: () => context.push('/settings'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: BorderSide(color: AppColors.gray300, width: 1.5),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Icon(LucideIcons.settings, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 내 게시물 탭
class _MyPostsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(myPostsProvider);

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
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => ref.invalidate(myPostsProvider),
              child: const Text('다시 시도'),
            ),
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
                Text('아직 작성한 게시물이 없습니다', style: AppTypography.headlineSmall),
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
                      // 이미지가 있으면 표시
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

/// 내 리뷰 탭
class _MyReviewsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.star, size: 64, color: AppColors.gray300),
          const SizedBox(height: 24),
          Text('아직 작성한 리뷰가 없습니다', style: AppTypography.headlineSmall),
          const SizedBox(height: 8),
          Text(
            '사용해본 장비의 리뷰를 남겨보세요!',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// 로그인 프롬프트
class _LoginPrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.user, size: 80, color: AppColors.gray400),
            const SizedBox(height: AppSpacing.lg),
            Text(
              '로그인이 필요합니다',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '로그인하고 나만의 커피 기록을 시작하세요',
              style: GoogleFonts.inter(
                fontSize: 15,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.push('/login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  '로그인',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => context.push('/signup'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: AppColors.gray300, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  '회원가입',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
