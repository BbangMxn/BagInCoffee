import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../shared/widgets/flavor_radar_chart.dart';
import '../../../api/api.dart';
import '../data/brew_method.dart';
import '../data/brew_log_provider.dart';

/// 반응형 브레이크포인트
const double _kDesktopBreakpoint = 900;

/// 추출 기록 화면
class RecodeScreen extends ConsumerWidget {
  const RecodeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(isLoggedInProvider);

    if (!isLoggedIn) {
      return _buildLoginRequired(context);
    }

    final brewLogsAsync = ref.watch(myBrewLogsProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= _kDesktopBreakpoint;

        return brewLogsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildError(ref),
          data: (logs) {
            if (logs.isEmpty) {
              return _buildEmpty(context, isDesktop);
            }
            return isDesktop
                ? _RecodeScreenDesktop(logs: logs)
                : _buildLogsList(context, ref, logs);
          },
        );
      },
    );
  }

  Widget _buildLoginRequired(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                LucideIcons.coffee,
                size: 40,
                color: AppColors.gray400,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('로그인이 필요합니다', style: AppTypography.headlineSmall),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '로그인하고 나만의 추출 기록을 관리하세요',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: () => context.push('/login'),
              child: const Text('로그인하기'),
            ),
          ],
        ),
      ),
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
          const SizedBox(height: AppSpacing.md),
          Text('기록을 불러올 수 없습니다', style: AppTypography.bodyMedium),
          const SizedBox(height: AppSpacing.md),
          TextButton(
            onPressed: () => ref.invalidate(myBrewLogsProvider),
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, bool isDesktop) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: isDesktop ? 120 : 100,
              height: isDesktop ? 120 : 100,
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                LucideIcons.coffee,
                size: isDesktop ? 56 : 48,
                color: AppColors.gray400,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              '아직 추출 기록이 없습니다',
              style: isDesktop
                  ? AppTypography.headlineMedium
                  : AppTypography.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '첫 번째 커피를 기록하고\n나만의 레시피를 만들어보세요!',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            ElevatedButton.icon(
              onPressed: () => context.push('/recode/new'),
              icon: const Icon(LucideIcons.plus),
              label: const Text('첫 기록 추가하기'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 32 : 24,
                  vertical: isDesktop ? 16 : 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogsList(
    BuildContext context,
    WidgetRef ref,
    List<Recode> logs,
  ) {
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(myBrewLogsProvider),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        itemCount: logs.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) => _BrewLogCard(log: logs[index]),
      ),
    );
  }
}

/// 데스크톱 버전 레이아웃
class _RecodeScreenDesktop extends ConsumerWidget {
  final List<Recode> logs;

  const _RecodeScreenDesktop({required this.logs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: AppColors.gray50,
      child: Row(
        children: [
          // 메인 콘텐츠 - 그리드
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => ref.invalidate(myBrewLogsProvider),
              child: CustomScrollView(
                slivers: [
                  // 헤더
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                      child: Row(
                        children: [
                          Text(
                            '내 추출 기록',
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${logs.length}개',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const Spacer(),
                          ElevatedButton.icon(
                            onPressed: () => context.push('/recode/new'),
                            icon: const Icon(LucideIcons.plus, size: 18),
                            label: const Text('새 기록'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 그리드
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 400,
                            childAspectRatio: 1.1,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                          ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            _BrewLogCardDesktop(log: logs[index]),
                        childCount: logs.length,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 사이드바 - 통계
          Container(
            width: 320,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                left: BorderSide(color: AppColors.gray200, width: 1),
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatisticsSection(logs: logs),
                  const SizedBox(height: 24),
                  _BrewMethodsSection(logs: logs),
                  const SizedBox(height: 24),
                  _RecentBeansSection(logs: logs),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 데스크톱용 기록 카드
class _BrewLogCardDesktop extends StatelessWidget {
  final Recode log;

  const _BrewLogCardDesktop({required this.log});

  @override
  Widget build(BuildContext context) {
    final method = BrewMethod.fromValue(log.brewMethod);
    final hasFlavorProfile = _hasFlavorProfile();

    return InkWell(
      onTap: () => context.push('/recode/${log.id}'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gray200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    method?.category.icon ?? LucideIcons.coffee,
                    size: 22,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        method?.label ?? log.brewMethodLabel,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        _formatDate(log.createdAt),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (log.rating != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          LucideIcons.star,
                          size: 14,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          log.rating!.toStringAsFixed(1),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.amber.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // 원두 정보
            if (log.beanName != null) ...[
              Text(
                log.beanName!,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (log.roaster != null || log.origin != null)
                Text(
                  [log.roaster, log.origin].whereType<String>().join(' · '),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              const SizedBox(height: 12),
            ],

            // 추출 정보
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (log.dose != null)
                    _InfoChipDesktop(
                      icon: LucideIcons.scale,
                      label: '${log.dose}g',
                    ),
                  if (log.waterTemp != null)
                    _InfoChipDesktop(
                      icon: LucideIcons.thermometer,
                      label: '${log.waterTemp}°C',
                    ),
                  if (log.totalWater != null)
                    _InfoChipDesktop(
                      icon: LucideIcons.droplet,
                      label: '${log.totalWater!.toInt()}ml',
                    ),
                  if (log.totalTime != null)
                    _InfoChipDesktop(
                      icon: LucideIcons.clock,
                      label: _formatTime(log.totalTime!),
                    ),
                ],
              ),
            ),

            // 맛 프로필 미니 차트
            if (hasFlavorProfile) ...[
              const Divider(height: 24),
              Row(
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: FlavorRadarChart(
                      profile: FlavorProfile(
                        acidity: log.acidity ?? 0,
                        sweetness: log.sweetness ?? 0,
                        bitterness: log.bitterness ?? 0,
                        body: log.body ?? 0,
                        aroma: 0,
                      ),
                      size: 60,
                      showLabels: false,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      log.memo ?? '맛 프로필 기록됨',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool _hasFlavorProfile() {
    return (log.acidity ?? 0) > 0 ||
        (log.sweetness ?? 0) > 0 ||
        (log.bitterness ?? 0) > 0 ||
        (log.body ?? 0) > 0;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return '오늘';
    if (diff.inDays == 1) return '어제';
    if (diff.inDays < 7) return '${diff.inDays}일 전';
    return '${date.month}월 ${date.day}일';
  }

  String _formatTime(int seconds) {
    final min = seconds ~/ 60;
    final sec = seconds % 60;
    if (min > 0) return '$min분 ${sec}초';
    return '$sec초';
  }
}

class _InfoChipDesktop extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChipDesktop({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.gray600),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// 통계 섹션
class _StatisticsSection extends StatelessWidget {
  final List<Recode> logs;

  const _StatisticsSection({required this.logs});

  @override
  Widget build(BuildContext context) {
    final totalLogs = logs.length;
    final avgRating = _calculateAvgRating();
    final favoriteCount = logs.where((l) => l.isFavorite).length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '통계',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  icon: LucideIcons.coffee,
                  label: '총 기록',
                  value: '$totalLogs',
                ),
              ),
              Expanded(
                child: _StatItem(
                  icon: LucideIcons.star,
                  label: '평균 평점',
                  value: avgRating > 0 ? avgRating.toStringAsFixed(1) : '-',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  icon: LucideIcons.heart,
                  label: '즐겨찾기',
                  value: '$favoriteCount',
                ),
              ),
              Expanded(
                child: _StatItem(
                  icon: LucideIcons.calendar,
                  label: '이번 달',
                  value: '${_thisMonthCount()}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  double _calculateAvgRating() {
    final rated = logs.where((l) => l.rating != null && l.rating! > 0);
    if (rated.isEmpty) return 0;
    return rated.map((l) => l.rating!).reduce((a, b) => a + b) / rated.length;
  }

  int _thisMonthCount() {
    final now = DateTime.now();
    return logs
        .where(
          (l) => l.createdAt.year == now.year && l.createdAt.month == now.month,
        )
        .length;
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// 추출 방식 섹션
class _BrewMethodsSection extends StatelessWidget {
  final List<Recode> logs;

  const _BrewMethodsSection({required this.logs});

  @override
  Widget build(BuildContext context) {
    final methodCounts = <String, int>{};
    for (final log in logs) {
      final method = log.brewMethod;
      methodCounts[method] = (methodCounts[method] ?? 0) + 1;
    }

    final sortedMethods = methodCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '추출 방식',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...sortedMethods.take(5).map((entry) {
            final method = BrewMethod.fromValue(entry.key);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.gray100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      method?.category.icon ?? LucideIcons.coffee,
                      size: 16,
                      color: AppColors.gray600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      method?.label ?? entry.key,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    '${entry.value}회',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// 최근 원두 섹션
class _RecentBeansSection extends StatelessWidget {
  final List<Recode> logs;

  const _RecentBeansSection({required this.logs});

  @override
  Widget build(BuildContext context) {
    final recentBeans = logs
        .where((l) => l.beanName != null && l.beanName!.isNotEmpty)
        .take(5)
        .toList();

    if (recentBeans.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '최근 사용 원두',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...recentBeans.map((log) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          log.beanName!,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (log.roaster != null)
                          Text(
                            log.roaster!,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// 모바일용 기록 카드 (기존)
class _BrewLogCard extends StatelessWidget {
  final Recode log;

  const _BrewLogCard({required this.log});

  @override
  Widget build(BuildContext context) {
    final method = BrewMethod.fromValue(log.brewMethod);
    final hasFlavorProfile = _hasFlavorProfile();

    return InkWell(
      onTap: () => context.push('/recode/${log.id}'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gray200, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    method?.category.icon ?? LucideIcons.coffee,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        method?.label ?? log.brewMethodLabel,
                        style: AppTypography.titleSmall,
                      ),
                      Text(
                        _formatDate(log.createdAt),
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                ),
                if (log.isFavorite)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      LucideIcons.star,
                      size: 16,
                      color: Colors.amber,
                    ),
                  ),
                if (log.rating != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gray100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          LucideIcons.star,
                          size: 14,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          log.rating!.toStringAsFixed(1),
                          style: AppTypography.labelSmall.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // 본문
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (log.beanName != null) ...[
                        Text(
                          log.beanName!,
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        if (log.roaster != null || log.origin != null)
                          Text(
                            [
                              log.roaster,
                              log.origin,
                            ].whereType<String>().join(' · '),
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: [
                          if (log.dose != null)
                            _InfoChip(
                              icon: LucideIcons.scale,
                              label: '${log.dose}g',
                            ),
                          if (log.waterTemp != null)
                            _InfoChip(
                              icon: LucideIcons.thermometer,
                              label: '${log.waterTemp}°C',
                            ),
                          if (log.totalWater != null)
                            _InfoChip(
                              icon: LucideIcons.droplet,
                              label: '${log.totalWater!.toInt()}ml',
                            ),
                          if (log.totalTime != null)
                            _InfoChip(
                              icon: LucideIcons.clock,
                              label: _formatTime(log.totalTime!),
                            ),
                          if (log.grindSize != null)
                            _InfoChip(
                              icon: LucideIcons.settings2,
                              label: log.grindSize!,
                            ),
                        ],
                      ),
                      if (log.memo != null && log.memo!.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          log.memo!,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (hasFlavorProfile) ...[
                  const SizedBox(width: AppSpacing.md),
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: FlavorRadarChart(
                      profile: FlavorProfile(
                        acidity: log.acidity ?? 0,
                        sweetness: log.sweetness ?? 0,
                        bitterness: log.bitterness ?? 0,
                        body: log.body ?? 0,
                        aroma: 0,
                      ),
                      size: 100,
                      showLabels: false,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _hasFlavorProfile() {
    return (log.acidity ?? 0) > 0 ||
        (log.sweetness ?? 0) > 0 ||
        (log.bitterness ?? 0) > 0 ||
        (log.body ?? 0) > 0;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return '오늘';
    if (diff.inDays == 1) return '어제';
    if (diff.inDays < 7) return '${diff.inDays}일 전';
    return '${date.month}월 ${date.day}일';
  }

  String _formatTime(int seconds) {
    final min = seconds ~/ 60;
    final sec = seconds % 60;
    if (min > 0) return '$min분 ${sec}초';
    return '$sec초';
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.gray600),
          const SizedBox(width: 4),
          Text(label, style: AppTypography.caption),
        ],
      ),
    );
  }
}
