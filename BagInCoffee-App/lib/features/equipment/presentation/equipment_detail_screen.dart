import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../data/equipment_model.dart';
import '../data/equipment_provider.dart';

/// 장비 상세 화면
class EquipmentDetailScreen extends ConsumerStatefulWidget {
  final String itemId;

  const EquipmentDetailScreen({super.key, required this.itemId});

  @override
  ConsumerState<EquipmentDetailScreen> createState() =>
      _EquipmentDetailScreenState();
}

class _EquipmentDetailScreenState extends ConsumerState<EquipmentDetailScreen> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemAsync = ref.watch(equipmentDetailProvider(widget.itemId));

    return Scaffold(
      backgroundColor: Colors.white,
      body: itemAsync.when(
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
              Text('장비 정보를 불러올 수 없습니다', style: AppTypography.bodyMedium),
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('돌아가기'),
              ),
            ],
          ),
        ),
        data: (item) {
          if (item == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    LucideIcons.packageX,
                    size: 64,
                    color: AppColors.gray300,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('장비를 찾을 수 없습니다', style: AppTypography.headlineSmall),
                  const SizedBox(height: AppSpacing.md),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('돌아가기'),
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              // 이미지 갤러리
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    // 이미지 페이지뷰
                    SizedBox(
                      height: 400,
                      child: item.images.isNotEmpty
                          ? PageView.builder(
                              controller: _pageController,
                              itemCount: item.images.length,
                              onPageChanged: (index) {
                                setState(() => _currentImageIndex = index);
                              },
                              itemBuilder: (context, index) {
                                return CachedNetworkImage(
                                  imageUrl: item.images[index],
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) =>
                                      Container(color: AppColors.gray100),
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
                            )
                          : Container(
                              color: AppColors.gray100,
                              child: Center(
                                child: Icon(
                                  LucideIcons.coffee,
                                  size: 64,
                                  color: AppColors.gray400,
                                ),
                              ),
                            ),
                    ),

                    // 뒤로가기 버튼
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 8,
                      left: 16,
                      child: _CircleButton(
                        icon: LucideIcons.arrowLeft,
                        onPressed: () => context.pop(),
                      ),
                    ),

                    // 공유 버튼
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 8,
                      right: 16,
                      child: _CircleButton(
                        icon: LucideIcons.share2,
                        onPressed: () {
                          // TODO: 공유 기능
                        },
                      ),
                    ),

                    // 이미지 인디케이터
                    if (item.images.length > 1)
                      Positioned(
                        bottom: 16,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            item.images.length,
                            (index) => Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: index == _currentImageIndex
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                        ),
                      ),

                    // 상태 배지
                    if (item.status != EquipmentStatus.active)
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 16,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: item.status == EquipmentStatus.sold
                                  ? Colors.black
                                  : Colors.orange,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              item.status.label,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // 상품 정보
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.screenPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 판매자 정보
                      if (item.seller != null)
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.gray100,
                              backgroundImage: item.seller!.avatarUrl != null
                                  ? CachedNetworkImageProvider(
                                      item.seller!.avatarUrl!,
                                    )
                                  : null,
                              child: item.seller!.avatarUrl == null
                                  ? const Icon(
                                      LucideIcons.user,
                                      size: 20,
                                      color: AppColors.gray400,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.seller!.username ?? '판매자',
                                    style: AppTypography.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (item.location != null)
                                    Row(
                                      children: [
                                        const Icon(
                                          LucideIcons.mapPin,
                                          size: 12,
                                          color: AppColors.gray500,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          item.location!,
                                          style: AppTypography.caption,
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: AppSpacing.lg),

                      // 제목
                      Text(
                        item.title,
                        style: GoogleFonts.notoSansKr(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.sm),

                      // 상태 & 등록 시간
                      Row(
                        children: [
                          if (item.condition != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.gray100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                item.condition!.label,
                                style: AppTypography.labelSmall,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                          ],
                          Text(
                            _formatRelativeTime(item.createdAt),
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // 가격
                      Text(
                        item.formattedPrice,
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),
                      Divider(color: AppColors.gray100),
                      const SizedBox(height: AppSpacing.xl),

                      // 설명
                      Text(
                        '상품 정보',
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        item.description ?? '상품 설명이 없습니다.',
                        style: AppTypography.bodyMedium.copyWith(
                          color: item.description != null
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: 100), // 하단 버튼 공간
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      // 하단 버튼
      bottomNavigationBar: itemAsync.valueOrNull != null
          ? Container(
              padding: EdgeInsets.only(
                left: AppSpacing.screenPadding,
                right: AppSpacing.screenPadding,
                top: AppSpacing.md,
                bottom: MediaQuery.of(context).padding.bottom + AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.gray100)),
              ),
              child: Row(
                children: [
                  // 찜 버튼
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.gray200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: const Icon(LucideIcons.heart),
                      onPressed: () {
                        // TODO: 찜하기 기능
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  // 채팅하기 버튼
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          itemAsync.valueOrNull?.status ==
                              EquipmentStatus.active
                          ? () {
                              // TODO: 채팅하기 기능
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        '채팅하기',
                        style: GoogleFonts.notoSansKr(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) {
      return '방금 전';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}분 전';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}시간 전';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}일 전';
    } else if (diff.inDays < 30) {
      return '${(diff.inDays / 7).floor()}주 전';
    } else {
      return '${dateTime.month}월 ${dateTime.day}일';
    }
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _CircleButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 20),
        onPressed: onPressed,
        color: AppColors.textPrimary,
      ),
    );
  }
}
