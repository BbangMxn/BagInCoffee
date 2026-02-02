import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/flavor_radar_chart.dart';
import '../../../api/api.dart';
import '../data/brew_method.dart';
import '../data/brew_log_provider.dart';

/// 추출 기록 상세 보기 화면
class RecodeDetailScreen extends ConsumerWidget {
  final String recodeId;

  const RecodeDetailScreen({super.key, required this.recodeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recodeAsync = ref.watch(brewLogDetailProvider(recodeId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: recodeAsync.when(
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
              Text('기록을 불러올 수 없습니다', style: AppTypography.bodyMedium),
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('돌아가기'),
              ),
            ],
          ),
        ),
        data: (recode) {
          if (recode == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    LucideIcons.coffee,
                    size: 48,
                    color: AppColors.gray400,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text('기록을 찾을 수 없습니다', style: AppTypography.bodyMedium),
                  const SizedBox(height: AppSpacing.md),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('돌아가기'),
                  ),
                ],
              ),
            );
          }
          return _RecodeDetailView(recode: recode);
        },
      ),
    );
  }
}

class _RecodeDetailView extends ConsumerWidget {
  final Recode recode;

  const _RecodeDetailView({required this.recode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final method = BrewMethod.fromValue(recode.brewMethod);
    final hasFlavorProfile = _hasFlavorProfile();

    return CustomScrollView(
      slivers: [
        // 앱바
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          backgroundColor: AppColors.primary,
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          actions: [
            IconButton(
              icon: Icon(
                recode.isFavorite ? LucideIcons.star : LucideIcons.star,
                color: recode.isFavorite ? Colors.amber : Colors.white,
              ),
              onPressed: () async {
                try {
                  await recodesApi.toggleFavorite(recode.id);
                  ref.invalidate(brewLogDetailProvider(recode.id));
                  ref.invalidate(myBrewLogsProvider);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('오류: $e')));
                  }
                }
              },
            ),
            IconButton(
              icon: const Icon(LucideIcons.pencil, color: Colors.white),
              onPressed: () => context.push('/recode/edit/${recode.id}'),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // 추출 방식 아이콘과 이름
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              method?.category.icon ?? LucideIcons.coffee,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  method?.label ?? recode.brewMethodLabel,
                                  style: AppTypography.headlineSmall.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  _formatDate(recode.createdAt),
                                  style: AppTypography.bodySmall.copyWith(
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (recode.rating != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    LucideIcons.star,
                                    size: 16,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    recode.rating!.toStringAsFixed(1),
                                    style: AppTypography.labelMedium.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
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
                // 원두 정보 카드
                if (recode.beanName != null) ...[
                  _buildSectionCard(
                    icon: LucideIcons.leaf,
                    title: '원두 정보',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recode.beanName!,
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (recode.roaster != null ||
                            recode.origin != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            [
                              recode.roaster,
                              recode.origin,
                            ].whereType<String>().join(' · '),
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],

                // 추출 설정 카드
                _buildSectionCard(
                  icon: LucideIcons.settings2,
                  title: '추출 설정',
                  child: _buildBrewSettings(),
                ),
                const SizedBox(height: AppSpacing.md),

                // 추출 단계 카드
                if (recode.extractionSteps.isNotEmpty) ...[
                  _buildSectionCard(
                    icon: LucideIcons.listOrdered,
                    title: '추출 단계',
                    child: _buildExtractionSteps(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],

                // 맛 프로필 카드
                if (hasFlavorProfile) ...[
                  _buildSectionCard(
                    icon: LucideIcons.palette,
                    title: '맛 프로필',
                    child: _buildFlavorProfile(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],

                // 메모 카드
                if (recode.memo != null && recode.memo!.isNotEmpty) ...[
                  _buildSectionCard(
                    icon: LucideIcons.fileText,
                    title: '메모',
                    child: Text(recode.memo!, style: AppTypography.bodyMedium),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],

                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }

  Widget _buildBrewSettings() {
    final settings = <_SettingItem>[];

    if (recode.dose != null) {
      settings.add(
        _SettingItem(
          icon: LucideIcons.scale,
          label: '원두량',
          value: '${recode.dose}g',
        ),
      );
    }
    if (recode.waterTemp != null) {
      settings.add(
        _SettingItem(
          icon: LucideIcons.thermometer,
          label: '물 온도',
          value: '${recode.waterTemp}°C',
        ),
      );
    }
    if (recode.totalWater != null) {
      settings.add(
        _SettingItem(
          icon: LucideIcons.droplet,
          label: '총 물량',
          value: '${recode.totalWater!.toInt()}ml',
        ),
      );
    }
    if (recode.totalTime != null) {
      settings.add(
        _SettingItem(
          icon: LucideIcons.clock,
          label: '추출 시간',
          value: _formatTime(recode.totalTime!),
        ),
      );
    }
    if (recode.grindSize != null) {
      settings.add(
        _SettingItem(
          icon: LucideIcons.settings2,
          label: '분쇄도',
          value: recode.grindSize!,
        ),
      );
    }
    if (recode.grinder != null) {
      settings.add(
        _SettingItem(
          icon: LucideIcons.cog,
          label: '그라인더',
          value: recode.grinder!,
        ),
      );
    }

    if (settings.isEmpty) {
      return Text(
        '설정 정보가 없습니다',
        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
      );
    }

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: settings.map((s) => _buildSettingChip(s)).toList(),
    );
  }

  Widget _buildSettingChip(_SettingItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(item.icon, size: 14, color: AppColors.gray600),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.label,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                item.value,
                style: AppTypography.labelSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExtractionSteps() {
    return Column(
      children: List.generate(recode.extractionSteps.length, (index) {
        final step = recode.extractionSteps[index];
        final isLast = index == recode.extractionSteps.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 타임라인
            SizedBox(
              width: 40,
              child: Column(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: AppTypography.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 40,
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                ],
              ),
            ),
            // 내용
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: AppSpacing.sm,
                  bottom: isLast ? 0 : AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildStepInfo(
                          LucideIcons.droplet,
                          '${step.water?.toInt() ?? 0}ml',
                        ),
                        const SizedBox(width: AppSpacing.md),
                        _buildStepInfo(LucideIcons.clock, '${step.time ?? 0}초'),
                      ],
                    ),
                    if (step.note != null && step.note!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        step.note!,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStepInfo(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.gray500),
        const SizedBox(width: 4),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildFlavorProfile() {
    return Row(
      children: [
        // 레이더 차트
        SizedBox(
          width: 140,
          height: 140,
          child: FlavorRadarChart(
            profile: FlavorProfile(
              acidity: recode.acidity ?? 0,
              sweetness: recode.sweetness ?? 0,
              bitterness: recode.bitterness ?? 0,
              body: recode.body ?? 0,
              aroma: recode.aroma ?? 0,
            ),
            size: 140,
            showLabels: true,
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        // 수치 표시
        Expanded(
          child: Column(
            children: [
              _buildFlavorBar('산미', recode.acidity ?? 0),
              _buildFlavorBar('단맛', recode.sweetness ?? 0),
              _buildFlavorBar('쓴맛', recode.bitterness ?? 0),
              _buildFlavorBar('바디', recode.body ?? 0),
              _buildFlavorBar('향미', recode.aroma ?? 0),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFlavorBar(String label, double value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 36, child: Text(label, style: AppTypography.caption)),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value / 5,
                backgroundColor: AppColors.gray100,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 20,
            child: Text(
              value.toInt().toString(),
              style: AppTypography.labelSmall,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  bool _hasFlavorProfile() {
    return (recode.acidity ?? 0) > 0 ||
        (recode.sweetness ?? 0) > 0 ||
        (recode.bitterness ?? 0) > 0 ||
        (recode.body ?? 0) > 0 ||
        (recode.aroma ?? 0) > 0;
  }

  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }

  String _formatTime(int seconds) {
    final min = seconds ~/ 60;
    final sec = seconds % 60;
    if (min > 0) {
      return '$min분 ${sec}초';
    }
    return '$sec초';
  }
}

class _SettingItem {
  final IconData icon;
  final String label;
  final String value;

  _SettingItem({required this.icon, required this.label, required this.value});
}
