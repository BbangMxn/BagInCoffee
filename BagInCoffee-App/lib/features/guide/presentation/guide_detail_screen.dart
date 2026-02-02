import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../api/api.dart';

/// 가이드 상세 Provider
final guideDetailProvider = FutureProvider.family<CoffeeGuide?, String>((
  ref,
  id,
) async {
  try {
    return await guidesApi.getById(id);
  } catch (e) {
    print('Failed to fetch guide: $e');
    return null;
  }
});

/// 가이드 상세 화면
class GuideDetailScreen extends ConsumerWidget {
  final String guideId;

  const GuideDetailScreen({super.key, required this.guideId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guideAsync = ref.watch(guideDetailProvider(guideId));

    return Scaffold(
      backgroundColor: Colors.white,
      body: guideAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildError(context, error.toString()),
        data: (guide) {
          if (guide == null) {
            return _buildError(context, '가이드를 찾을 수 없습니다');
          }
          return _GuideDetailView(guide: guide);
        },
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
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
}

class _GuideDetailView extends StatelessWidget {
  final CoffeeGuide guide;

  const _GuideDetailView({required this.guide});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // 앱바 + 커버 이미지
        SliverAppBar(
          expandedHeight: guide.coverImage != null ? 280 : 120,
          pinned: true,
          backgroundColor: const Color(0xFF37352F),
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.arrowLeft,
                color: Colors.white,
                size: 20,
              ),
            ),
            onPressed: () => context.pop(),
          ),
          actions: [
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.share2,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              onPressed: () {
                // TODO: 공유 기능
              },
            ),
            const SizedBox(width: 8),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: guide.coverImage != null
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: guide.coverImage!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            Container(color: const Color(0xFFF7F6F3)),
                        errorWidget: (_, __, ___) => Container(
                          color: const Color(0xFFF7F6F3),
                          child: const Icon(
                            LucideIcons.image,
                            size: 48,
                            color: Color(0xFF9B9A97),
                          ),
                        ),
                      ),
                      // 그라데이션 오버레이
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.5),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : Container(color: const Color(0xFF37352F)),
          ),
        ),

        // 헤더 정보
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 카테고리 & 난이도 태그
                Row(
                  children: [
                    _buildTag(
                      guide.categoryLabel,
                      const Color(0xFFF7F6F3),
                      const Color(0xFF37352F),
                    ),
                    if (guide.difficulty != null) ...[
                      const SizedBox(width: 8),
                      _buildDifficultyTag(guide.difficulty!),
                    ],
                    const Spacer(),
                    // 조회수
                    Row(
                      children: [
                        const Icon(
                          LucideIcons.eye,
                          size: 14,
                          color: Color(0xFF9B9A97),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${guide.viewsCount}',
                          style: AppTypography.caption.copyWith(
                            color: const Color(0xFF9B9A97),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                // 제목
                Text(
                  guide.title,
                  style: AppTypography.headlineMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF37352F),
                    height: 1.3,
                  ),
                ),

                // 요약
                if (guide.excerpt != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    guide.excerpt!,
                    style: AppTypography.bodyMedium.copyWith(
                      color: const Color(0xFF9B9A97),
                      height: 1.5,
                    ),
                  ),
                ],

                const SizedBox(height: AppSpacing.md),

                // 메타 정보
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F6F3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      // 읽기 시간
                      if (guide.readingTimeMinutes != null)
                        Expanded(
                          child: _buildMetaItem(
                            LucideIcons.clock,
                            '읽기 시간',
                            '${guide.readingTimeMinutes}분',
                          ),
                        ),

                      // 작성일
                      Expanded(
                        child: _buildMetaItem(
                          LucideIcons.calendar,
                          '작성일',
                          _formatDate(guide.createdAt),
                        ),
                      ),

                      // 업데이트
                      Expanded(
                        child: _buildMetaItem(
                          LucideIcons.refreshCw,
                          '업데이트',
                          _formatDate(guide.updatedAt),
                        ),
                      ),
                    ],
                  ),
                ),

                // 태그들
                if (guide.tags.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: guide.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8E8E8),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              LucideIcons.hash,
                              size: 12,
                              color: Color(0xFF6B6B6B),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              tag,
                              style: AppTypography.caption.copyWith(
                                color: const Color(0xFF6B6B6B),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: AppSpacing.lg),
                const Divider(color: Color(0xFFE5E2DE)),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),

        // 본문 (마크다운)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding,
            ),
            child: MarkdownBody(
              data: guide.content,
              styleSheet: MarkdownStyleSheet(
                h1: AppTypography.headlineMedium.copyWith(
                  color: const Color(0xFF37352F),
                  fontWeight: FontWeight.w700,
                ),
                h2: AppTypography.headlineSmall.copyWith(
                  color: const Color(0xFF37352F),
                  fontWeight: FontWeight.w600,
                ),
                h3: AppTypography.titleMedium.copyWith(
                  color: const Color(0xFF37352F),
                  fontWeight: FontWeight.w600,
                ),
                p: AppTypography.bodyMedium.copyWith(
                  color: const Color(0xFF37352F),
                  height: 1.7,
                ),
                listBullet: AppTypography.bodyMedium.copyWith(
                  color: const Color(0xFF37352F),
                ),
                blockquote: AppTypography.bodyMedium.copyWith(
                  color: const Color(0xFF6B6B6B),
                  fontStyle: FontStyle.italic,
                ),
                blockquoteDecoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: const Color(0xFF37352F).withOpacity(0.3),
                      width: 4,
                    ),
                  ),
                ),
                code: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  color: const Color(0xFFEB5757),
                  backgroundColor: const Color(0xFFF7F6F3),
                ),
                codeblockDecoration: BoxDecoration(
                  color: const Color(0xFFF7F6F3),
                  borderRadius: BorderRadius.circular(8),
                ),
                horizontalRuleDecoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: const Color(0xFFE5E2DE), width: 1),
                  ),
                ),
              ),
              onTapLink: (text, href, title) {
                // TODO: 링크 처리
              },
            ),
          ),
        ),

        // 하단 여백
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildTag(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
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

  Widget _buildMetaItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF9B9A97)),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.caption.copyWith(color: const Color(0xFF9B9A97)),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.labelSmall.copyWith(
            color: const Color(0xFF37352F),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}
