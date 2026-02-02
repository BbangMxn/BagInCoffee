import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../api/api.dart';
import '../../home/data/post_provider.dart';

/// 데스크톱 프로필 화면
class ProfileScreenDesktop extends StatelessWidget {
  final TabController tabController;
  final dynamic profile;
  final dynamic currentUser;

  const ProfileScreenDesktop({
    super.key,
    required this.tabController,
    required this.profile,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 좌측: 프로필 정보 사이드바
          _ProfileSidebar(profile: profile, currentUser: currentUser),

          // 우측: 콘텐츠 영역
          Expanded(
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  // 탭바
                  _ProfileTabBar(tabController: tabController),
                  // 탭 콘텐츠
                  Expanded(
                    child: TabBarView(
                      controller: tabController,
                      children: [_MyPostsGrid(), _MyReviewsEmpty()],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 프로필 사이드바
class _ProfileSidebar extends StatelessWidget {
  final dynamic profile;
  final dynamic currentUser;

  const _ProfileSidebar({required this.profile, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: AppColors.gray200, width: 1)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // 아바타
            _buildAvatar(),
            const SizedBox(height: 20),
            // 이름
            _buildName(),
            // 이메일
            if (currentUser?.email != null) _buildEmail(),
            // Bio
            if (profile?.bio != null) _buildBio(),
            // 위치 & 웹사이트
            _buildLocationAndWebsite(),
            const SizedBox(height: 24),
            // 버튼들
            _buildButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 60,
      backgroundColor: AppColors.gray200,
      backgroundImage: profile?.avatarUrl != null
          ? CachedNetworkImageProvider(profile!.avatarUrl!)
          : null,
      child: profile?.avatarUrl == null
          ? const Icon(LucideIcons.user, size: 60, color: AppColors.gray500)
          : null,
    );
  }

  Widget _buildName() {
    return Text(
      profile?.username ?? currentUser?.email?.split('@')[0] ?? '사용자',
      style: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildEmail() {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        currentUser!.email!,
        style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildBio() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Text(
        profile!.bio!,
        style: GoogleFonts.inter(
          fontSize: 14,
          color: AppColors.textPrimary,
          height: 1.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildLocationAndWebsite() {
    if (profile?.location == null && profile?.website == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          if (profile?.location != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  LucideIcons.mapPin,
                  size: 14,
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
            ),
          if (profile?.website != null) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  LucideIcons.link,
                  size: 14,
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
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => context.push('/profile/edit'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: BorderSide(color: AppColors.gray300, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(LucideIcons.pencil, size: 18),
            label: Text(
              '프로필 수정',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => context.push('/settings'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: BorderSide(color: AppColors.gray300, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(LucideIcons.settings, size: 18),
            label: Text(
              '설정',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 프로필 탭바
class _ProfileTabBar extends StatelessWidget {
  final TabController tabController;

  const _ProfileTabBar({required this.tabController});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.gray200, width: 1)),
      ),
      child: TabBar(
        controller: tabController,
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
    );
  }
}

/// 내 게시물 그리드
class _MyPostsGrid extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(myPostsProvider);

    return postsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildError(ref),
      data: (posts) {
        if (posts.isEmpty) return _buildEmpty();
        return _buildGrid(context, posts);
      },
    );
  }

  Widget _buildError(WidgetRef ref) {
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
          Text('게시물을 불러올 수 없습니다', style: AppTypography.bodyMedium),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => ref.invalidate(myPostsProvider),
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.coffee, size: 64, color: AppColors.gray300),
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

  Widget _buildGrid(BuildContext context, List<PostWithAuthor> posts) {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 350,
        childAspectRatio: 1.0,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) => _PostCard(post: posts[index]),
    );
  }
}

/// 게시물 카드
class _PostCard extends StatelessWidget {
  final PostWithAuthor post;

  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
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
            Expanded(flex: 3, child: _buildImage()),
            // 콘텐츠
            Expanded(flex: 2, child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: SizedBox(
        width: double.infinity,
        child: post.images.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: post.images.first,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: AppColors.gray100),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.gray100,
                  child: const Icon(
                    LucideIcons.image,
                    color: AppColors.gray400,
                  ),
                ),
              )
            : Container(
                color: AppColors.gray50,
                child: const Center(
                  child: Icon(
                    LucideIcons.fileText,
                    size: 32,
                    color: AppColors.gray300,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              post.content,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _buildStats(),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        const Icon(LucideIcons.heart, size: 14, color: AppColors.gray500),
        const SizedBox(width: 4),
        Text(
          '${post.likesCount}',
          style: GoogleFonts.inter(fontSize: 12, color: AppColors.gray600),
        ),
        const SizedBox(width: 12),
        const Icon(
          LucideIcons.messageCircle,
          size: 14,
          color: AppColors.gray500,
        ),
        const SizedBox(width: 4),
        Text(
          '${post.commentsCount}',
          style: GoogleFonts.inter(fontSize: 12, color: AppColors.gray600),
        ),
      ],
    );
  }
}

/// 내 리뷰 빈 상태
class _MyReviewsEmpty extends StatelessWidget {
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
