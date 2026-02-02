import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/bean_variety.dart';

/// 품종 선택 바텀시트를 표시
Future<BeanVariety?> showVarietyPicker(
  BuildContext context, {
  String? selectedValue,
}) async {
  return showModalBottomSheet<BeanVariety>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => VarietyPickerSheet(selectedValue: selectedValue),
  );
}

/// 품종 선택 바텀시트
class VarietyPickerSheet extends StatefulWidget {
  final String? selectedValue;

  const VarietyPickerSheet({super.key, this.selectedValue});

  @override
  State<VarietyPickerSheet> createState() => _VarietyPickerSheetState();
}

class _VarietyPickerSheetState extends State<VarietyPickerSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  BeanCategory _selectedCategory = BeanCategory.arabica;

  @override
  void initState() {
    super.initState();

    // 선택된 값이 있으면 해당 카테고리 탭으로
    if (widget.selectedValue != null) {
      final variety = BeanVariety.fromValue(widget.selectedValue!);
      if (variety != null) {
        _selectedCategory = variety.category;
      }
    }

    _tabController = TabController(
      length: BeanCategory.values.length,
      vsync: this,
      initialIndex: BeanCategory.values.indexOf(_selectedCategory),
    );

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedCategory = BeanCategory.values[_tabController.index];
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final grouped = BeanVariety.grouped;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 핸들
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.gray300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 헤더
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Text('원두 품종 선택', style: AppTypography.titleMedium),
                const Spacer(),
                IconButton(
                  icon: const Icon(LucideIcons.x, size: 20),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
          ),

          // 카테고리 탭 (쉬운 전환)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorPadding: const EdgeInsets.all(4),
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: AppTypography.labelSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: AppTypography.labelSmall,
              dividerColor: Colors.transparent,
              tabs: BeanCategory.values.map((cat) {
                return Tab(height: 40, child: Text(cat.label));
              }).toList(),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // 카테고리 설명
          Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: _selectedCategory.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _selectedCategory.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    LucideIcons.leaf,
                    size: 16,
                    color: _selectedCategory.color,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_selectedCategory.label} (${_selectedCategory.englishName})',
                        style: AppTypography.labelMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _selectedCategory.description,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // 품종 목록
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: BeanCategory.values.map((category) {
                final varieties = grouped[category] ?? [];
                return ListView.separated(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.xs,
                    AppSpacing.md,
                    bottomPadding + AppSpacing.md,
                  ),
                  itemCount: varieties.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final variety = varieties[index];
                    final isSelected = variety.value == widget.selectedValue;

                    return _VarietyTile(
                      variety: variety,
                      isSelected: isSelected,
                      onTap: () => Navigator.pop(context, variety),
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _VarietyTile extends StatelessWidget {
  final BeanVariety variety;
  final bool isSelected;
  final VoidCallback onTap;

  const _VarietyTile({
    required this.variety,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.gray50,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              // 선택 인디케이터
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.gray300,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        LucideIcons.check,
                        size: 14,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(width: AppSpacing.md),

              // 품종 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          variety.label,
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                        ),
                        if (variety.englishName != null) ...[
                          const SizedBox(width: 6),
                          Text(
                            variety.englishName!,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (variety.description != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        variety.description!,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // 카테고리 색상 인디케이터
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: variety.category.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 품종 표시 위젯 (선택된 품종을 보여주는 버튼)
class VarietyDisplay extends StatelessWidget {
  final String? varietyValue;
  final VoidCallback onTap;

  const VarietyDisplay({super.key, this.varietyValue, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final variety = varietyValue != null
        ? BeanVariety.fromValue(varietyValue!)
        : null;

    return Material(
      color: AppColors.gray50,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color:
                      variety?.category.color.withOpacity(0.2) ??
                      AppColors.gray200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  LucideIcons.leaf,
                  size: 20,
                  color: variety?.category.color ?? AppColors.gray400,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      variety?.label ?? '품종 선택',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                        color: variety != null
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                    if (variety != null)
                      Text(
                        '${variety.category.label} · ${variety.englishName ?? ""}',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      )
                    else
                      Text(
                        '탭하여 품종을 선택하세요',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.gray400,
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(
                LucideIcons.chevronRight,
                size: 20,
                color: AppColors.gray400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
