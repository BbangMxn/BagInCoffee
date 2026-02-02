import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../features/recode/data/brew_method.dart';

/// 추출 방식 선택 바텀시트
class BrewMethodPicker extends StatefulWidget {
  final String? selectedValue;
  final ValueChanged<BrewMethod> onSelected;

  const BrewMethodPicker({
    super.key,
    this.selectedValue,
    required this.onSelected,
  });

  /// 바텀시트로 표시
  static Future<BrewMethod?> show(
    BuildContext context, {
    String? selectedValue,
  }) async {
    return showModalBottomSheet<BrewMethod>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => _BrewMethodSheet(
          selectedValue: selectedValue,
          scrollController: scrollController,
        ),
      ),
    );
  }

  @override
  State<BrewMethodPicker> createState() => _BrewMethodPickerState();
}

class _BrewMethodPickerState extends State<BrewMethodPicker> {
  @override
  Widget build(BuildContext context) {
    final selected = widget.selectedValue != null
        ? BrewMethod.fromValue(widget.selectedValue!)
        : null;

    return InkWell(
      onTap: () async {
        final result = await BrewMethodPicker.show(
          context,
          selectedValue: widget.selectedValue,
        );
        if (result != null) {
          widget.onSelected(result);
        }
      },
      borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.inputPaddingH,
          vertical: AppSpacing.inputPaddingV,
        ),
        decoration: BoxDecoration(
          color: AppColors.gray100,
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
        ),
        child: Row(
          children: [
            Icon(
              selected?.category.icon ?? LucideIcons.coffee,
              size: 20,
              color: selected != null
                  ? AppColors.textPrimary
                  : AppColors.textTertiary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                selected?.label ?? '추출 방식 선택',
                style: AppTypography.bodyMedium.copyWith(
                  color: selected != null
                      ? AppColors.textPrimary
                      : AppColors.textTertiary,
                ),
              ),
            ),
            const Icon(
              LucideIcons.chevronDown,
              size: 20,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

class _BrewMethodSheet extends StatefulWidget {
  final String? selectedValue;
  final ScrollController scrollController;

  const _BrewMethodSheet({this.selectedValue, required this.scrollController});

  @override
  State<_BrewMethodSheet> createState() => _BrewMethodSheetState();
}

class _BrewMethodSheetState extends State<_BrewMethodSheet> {
  String _searchQuery = '';
  BrewCategory? _selectedCategory;

  List<BrewMethod> get _filteredMethods {
    var methods = BrewMethod.all;

    // 카테고리 필터
    if (_selectedCategory != null) {
      methods = methods.where((m) => m.category == _selectedCategory).toList();
    }

    // 검색 필터
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      methods = methods.where((m) {
        return m.label.toLowerCase().contains(query) ||
            (m.subLabel?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    return methods;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('추출 방식', style: AppTypography.headlineMedium),
                const SizedBox(height: AppSpacing.md),

                // 검색
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.gray100,
                    borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                  ),
                  child: TextField(
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      hintText: '검색...',
                      hintStyle: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textTertiary,
                      ),
                      prefixIcon: const Icon(
                        LucideIcons.search,
                        size: 20,
                        color: AppColors.gray500,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // 카테고리 필터
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _CategoryChip(
                        label: '전체',
                        icon: LucideIcons.layoutGrid,
                        isSelected: _selectedCategory == null,
                        onTap: () => setState(() => _selectedCategory = null),
                      ),
                      ...BrewCategory.values.map(
                        (category) => _CategoryChip(
                          label: category.label,
                          icon: category.icon,
                          isSelected: _selectedCategory == category,
                          onTap: () =>
                              setState(() => _selectedCategory = category),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // 목록
          Expanded(
            child: _filteredMethods.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          LucideIcons.searchX,
                          size: 48,
                          color: AppColors.gray300,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          '검색 결과가 없습니다',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: widget.scrollController,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                    ),
                    itemCount: _filteredMethods.length,
                    itemBuilder: (context, index) {
                      final method = _filteredMethods[index];
                      final isSelected = method.value == widget.selectedValue;

                      return ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.black
                                : AppColors.gray100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            method.category.icon,
                            size: 20,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                        ),
                        title: Text(
                          method.label,
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                        subtitle: method.subLabel != null
                            ? Text(
                                method.subLabel!,
                                style: AppTypography.caption,
                              )
                            : null,
                        trailing: isSelected
                            ? const Icon(
                                LucideIcons.check,
                                size: 20,
                                color: AppColors.black,
                              )
                            : null,
                        onTap: () => Navigator.pop(context, method),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.xs),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.black : AppColors.gray100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
