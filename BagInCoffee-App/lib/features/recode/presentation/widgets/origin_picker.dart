import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/bean_origin.dart';

/// 원산지 선택 결과
class OriginSelection {
  final bool isBlend; // 블렌드 여부
  final List<BeanOrigin> countries; // 블렌드인 경우 여러 나라, 싱글인 경우 1개
  final String? region; // 추가 지역 정보 (싱글 오리진인 경우만)

  OriginSelection({required this.isBlend, required this.countries, this.region})
    : assert(countries.isNotEmpty, '최소 1개 국가를 선택해야 합니다'),
      assert(!isBlend || region == null, '블렌드는 지역을 지정할 수 없습니다');

  // 싱글 오리진 생성자
  factory OriginSelection.single(BeanOrigin country, {String? region}) {
    return OriginSelection(
      isBlend: false,
      countries: [country],
      region: region,
    );
  }

  // 블렌드 생성자
  factory OriginSelection.blend(List<BeanOrigin> countries) {
    return OriginSelection(isBlend: true, countries: countries, region: null);
  }

  // 호환성을 위한 getter
  BeanOrigin get country => countries.first;

  String get displayText {
    if (isBlend) {
      return countries.map((c) => c.nameKo).join(' + ');
    } else {
      if (region != null && region!.isNotEmpty) {
        return '${countries.first.nameKo} - $region';
      }
      return countries.first.nameKo;
    }
  }

  String get displayTextWithFlag {
    if (isBlend) {
      return countries
          .map((c) => '${_getCountryFlag(c.code)} ${c.nameKo}')
          .join(' + ');
    } else {
      final flag = _getCountryFlag(countries.first.code);
      if (region != null && region!.isNotEmpty) {
        return '$flag ${countries.first.nameKo} - $region';
      }
      return '$flag ${countries.first.nameKo}';
    }
  }

  static String _getCountryFlag(String code) {
    const flags = {
      'ET': '🇪🇹',
      'KE': '🇰🇪',
      'RW': '🇷🇼',
      'BI': '🇧🇮',
      'TZ': '🇹🇿',
      'UG': '🇺🇬',
      'GT': '🇬🇹',
      'CR': '🇨🇷',
      'PA': '🇵🇦',
      'HN': '🇭🇳',
      'NI': '🇳🇮',
      'SV': '🇸🇻',
      'MX': '🇲🇽',
      'JM': '🇯🇲',
      'CO': '🇨🇴',
      'BR': '🇧🇷',
      'PE': '🇵🇪',
      'EC': '🇪🇨',
      'BO': '🇧🇴',
      'ID': '🇮🇩',
      'VN': '🇻🇳',
      'TH': '🇹🇭',
      'LA': '🇱🇦',
      'MM': '🇲🇲',
      'IN': '🇮🇳',
      'YE': '🇾🇪',
      'PG': '🇵🇬',
      'AU': '🇦🇺',
      'HI': '🇺🇸',
    };
    return flags[code] ?? '🌍';
  }
}

/// 원산지 선택 다이얼로그
class OriginPicker extends StatefulWidget {
  final OriginSelection? initialSelection;
  final bool isBlend; // 싱글 오리진/블렌드 초기값

  const OriginPicker({super.key, this.initialSelection, this.isBlend = false});

  /// 원산지 선택 다이얼로그 표시
  static Future<OriginSelection?> show(
    BuildContext context, {
    OriginSelection? initialSelection,
    bool isBlend = false,
  }) {
    return showModalBottomSheet<OriginSelection>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          OriginPicker(initialSelection: initialSelection, isBlend: isBlend),
    );
  }

  @override
  State<OriginPicker> createState() => _OriginPickerState();
}

class _OriginPickerState extends State<OriginPicker>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _regionController = TextEditingController();

  final List<BeanOrigin> _selectedCountries = [];
  List<BeanOrigin> _filteredOrigins = [];
  bool _showOnlyPopular = true;
  bool _isBlend = false; // 싱글 오리진/블렌드 선택

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: CoffeeRegion.values.length + 1,
      vsync: this,
    );
    // 초기 선택값이 있으면 해당 값 사용, 없으면 전달받은 isBlend 사용
    if (widget.initialSelection != null) {
      _isBlend = widget.initialSelection!.isBlend;
      _selectedCountries.addAll(widget.initialSelection!.countries);
      _regionController.text = widget.initialSelection?.region ?? '';
    } else {
      _isBlend = widget.isBlend;
    }
    _updateFilteredOrigins();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _regionController.dispose();
    super.dispose();
  }

  void _updateFilteredOrigins() {
    setState(() {
      if (_searchController.text.isEmpty) {
        _filteredOrigins = _showOnlyPopular
            ? BeanOrigin.popularOrigins
            : BeanOrigin.all;
      } else {
        _filteredOrigins = BeanOrigin.search(_searchController.text);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
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
                Text(
                  '원산지 선택',
                  style: AppTypography.headlineSmall.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(LucideIcons.x, size: 20),
                  color: AppColors.gray500,
                ),
              ],
            ),
          ),

          // 싱글 오리진 / 블렌드 토글
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: _OriginTypeButton(
                    label: '싱글 오리진',
                    icon: LucideIcons.mapPin,
                    isSelected: !_isBlend,
                    onTap: () {
                      setState(() {
                        _isBlend = false;
                        // 싱글 오리진은 1개만 선택 가능
                        if (_selectedCountries.length > 1) {
                          _selectedCountries.removeRange(
                            1,
                            _selectedCountries.length,
                          );
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _OriginTypeButton(
                    label: '블렌드',
                    icon: LucideIcons.shuffle,
                    isSelected: _isBlend,
                    onTap: () {
                      setState(() {
                        _isBlend = true;
                        _regionController.clear(); // 블렌드는 지역 정보 없음
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // 검색바
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '나라 검색...',
                prefixIcon: const Icon(LucideIcons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(LucideIcons.x, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _updateFilteredOrigins();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.gray300),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (_) => _updateFilteredOrigins(),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // 인기/전체 토글
          if (_searchController.text.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('인기'),
                    selected: _showOnlyPopular,
                    onSelected: (selected) {
                      setState(() {
                        _showOnlyPopular = true;
                        _updateFilteredOrigins();
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('전체'),
                    selected: !_showOnlyPopular,
                    onSelected: (selected) {
                      setState(() {
                        _showOnlyPopular = false;
                        _updateFilteredOrigins();
                      });
                    },
                  ),
                ],
              ),
            ),

          const SizedBox(height: AppSpacing.sm),

          // 나라 목록
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              itemCount: _filteredOrigins.length,
              itemBuilder: (context, index) {
                final origin = _filteredOrigins[index];
                final isSelected = _selectedCountries.any(
                  (c) => c.code == origin.code,
                );

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.gray200,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedCountries.removeWhere(
                            (c) => c.code == origin.code,
                          );
                        } else {
                          // 싱글 오리진은 1개만 선택 가능
                          if (!_isBlend) {
                            _selectedCountries.clear();
                          }
                          _selectedCountries.add(origin);
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // 국기 이모지 또는 아이콘
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withOpacity(0.1)
                                  : AppColors.gray100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                _getCountryFlag(origin.code),
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // 나라 정보
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  origin.nameKo,
                                  style: AppTypography.titleSmall.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  origin.nameEn,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                if (origin.description != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    origin.description!,
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.textTertiary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),

                          // 선택 표시 (블렌드: 체크박스, 싱글: 라디오)
                          if (_isBlend)
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.gray300,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: isSelected
                                  ? const Icon(
                                      LucideIcons.check,
                                      color: Colors.white,
                                      size: 16,
                                    )
                                  : null,
                            )
                          else
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.gray300,
                                  width: 2,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: isSelected
                                  ? Center(
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 하단 지역 입력 & 확인 버튼
          if (_selectedCountries.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 지역 입력 (선택사항) - 단일 선택인 경우만
                    if (_selectedCountries.length == 1)
                      TextField(
                        controller: _regionController,
                        decoration: InputDecoration(
                          hintText: '지역 입력 (선택사항)',
                          hintStyle: AppTypography.bodyMedium.copyWith(
                            color: AppColors.gray400,
                          ),
                          prefixIcon: const Icon(LucideIcons.mapPin, size: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.gray300),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        textInputAction: TextInputAction.done,
                      ),

                    const SizedBox(height: AppSpacing.sm),

                    // 선택한 내용 미리보기
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.gray50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            LucideIcons.info,
                            size: 16,
                            color: AppColors.gray500,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '선택: ${_getDisplayText()}',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    // 확인 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _canConfirm()
                            ? () {
                                final selection = _isBlend
                                    ? OriginSelection.blend(_selectedCountries)
                                    : OriginSelection.single(
                                        _selectedCountries.first,
                                        region: _regionController.text.isEmpty
                                            ? null
                                            : _regionController.text,
                                      );
                                Navigator.pop(context, selection);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          '선택 완료',
                          style: AppTypography.labelLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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

  bool _canConfirm() {
    if (_selectedCountries.isEmpty) return false;
    // 블렌드는 최소 2개 선택 필요
    if (_isBlend && _selectedCountries.length < 2) return false;
    // 싱글 오리진은 정확히 1개만
    if (!_isBlend && _selectedCountries.length != 1) return false;
    return true;
  }

  String _getDisplayText() {
    if (_selectedCountries.isEmpty) return '';

    if (_selectedCountries.length == 1) {
      final region = _regionController.text;
      if (region.isEmpty) {
        return _selectedCountries.first.nameKo;
      }
      return '${_selectedCountries.first.nameKo} - $region';
    }

    // 여러 나라 선택 (블렌드)
    return _selectedCountries.map((c) => c.nameKo).join(' + ');
  }

  String _getCountryFlag(String code) {
    // 간단한 국기 이모지 매핑
    const flags = {
      'ET': '🇪🇹',
      'KE': '🇰🇪',
      'RW': '🇷🇼',
      'BI': '🇧🇮',
      'TZ': '🇹🇿',
      'UG': '🇺🇬',
      'GT': '🇬🇹',
      'CR': '🇨🇷',
      'PA': '🇵🇦',
      'HN': '🇭🇳',
      'NI': '🇳🇮',
      'SV': '🇸🇻',
      'MX': '🇲🇽',
      'JM': '🇯🇲',
      'CO': '🇨🇴',
      'BR': '🇧🇷',
      'PE': '🇵🇪',
      'EC': '🇪🇨',
      'BO': '🇧🇴',
      'ID': '🇮🇩',
      'VN': '🇻🇳',
      'TH': '🇹🇭',
      'LA': '🇱🇦',
      'MM': '🇲🇲',
      'IN': '🇮🇳',
      'YE': '🇾🇪',
      'PG': '🇵🇬',
      'AU': '🇦🇺',
      'HI': '🇺🇸',
    };
    return flags[code] ?? '🌍';
  }
}

/// 원산지 타입 선택 버튼
class _OriginTypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _OriginTypeButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.gray300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : AppColors.gray600,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTypography.labelLarge.copyWith(
                color: isSelected ? Colors.white : AppColors.gray700,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
