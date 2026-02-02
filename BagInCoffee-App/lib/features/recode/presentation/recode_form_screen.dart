import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../api/api.dart';
import '../data/brew_method.dart';
import '../data/brew_log_provider.dart';
import 'widgets/origin_picker.dart';
import 'widgets/variety_picker.dart';

// 캐시된 스타일 및 데코레이션 (성능 최적화)
final _titleStyle = GoogleFonts.inter(
  fontSize: 20,
  fontWeight: FontWeight.w700,
  color: AppColors.textPrimary,
);

final _appBarTitleStyle = GoogleFonts.inter(
  fontSize: 18,
  fontWeight: FontWeight.w600,
  color: AppColors.textPrimary,
);

final _inputDecoration = InputDecoration(
  filled: true,
  fillColor: AppColors.gray50,
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide.none,
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: AppColors.gray200),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: AppColors.primary),
  ),
  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
);

final _grindInputDecoration = InputDecoration(
  filled: true,
  fillColor: AppColors.gray50,
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: AppColors.gray200),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: AppColors.gray200),
  ),
  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
);

/// 추출 기록 폼 화면 - Uber 디자인 가이드라인
class RecodeFormScreen extends ConsumerStatefulWidget {
  final String? recodeId;

  const RecodeFormScreen({super.key, this.recodeId});

  @override
  ConsumerState<RecodeFormScreen> createState() => _RecodeFormScreenState();
}

class _RecodeFormScreenState extends ConsumerState<RecodeFormScreen> {
  bool get isEditMode => widget.recodeId != null;
  bool _isLoading = false;
  bool _isSaving = false;
  int _currentStep = 0;

  // 원두 정보
  bool _isBlend = false;
  final _beanNameController = TextEditingController();
  final _roasterController = TextEditingController();
  String? _variety;
  OriginSelection? _originSelection;

  // 추출 방식
  String? _brewMethod;

  // 추출 설정
  final _doseController = TextEditingController();
  final _grindSizeController = TextEditingController();
  final _grinderController = TextEditingController();
  final _waterTempController = TextEditingController();
  final _totalWaterController = TextEditingController();
  int? _totalTime;

  // 추출 단계
  List<ExtractionStep> _extractionSteps = [];

  // 맛 평가
  double _rating = 0;
  double _acidity = 0;
  double _sweetness = 0;
  double _bitterness = 0;
  double _body = 0;
  double _aroma = 0;

  final _memoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      _loadRecode();
    }
  }

  @override
  void dispose() {
    _beanNameController.dispose();
    _roasterController.dispose();
    _doseController.dispose();
    _grindSizeController.dispose();
    _grinderController.dispose();
    _waterTempController.dispose();
    _totalWaterController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _loadRecode() async {
    setState(() => _isLoading = true);
    try {
      final recode = await recodesApi.getById(widget.recodeId!);
      setState(() {
        _brewMethod = recode.brewMethod;
        _beanNameController.text = recode.beanName ?? '';
        _roasterController.text = recode.roaster ?? '';
        _doseController.text = recode.dose?.toString() ?? '';
        _grindSizeController.text = recode.grindSize ?? '';
        _grinderController.text = recode.grinder ?? '';
        _waterTempController.text = recode.waterTemp?.toString() ?? '';
        _totalWaterController.text = recode.totalWater?.toString() ?? '';
        _totalTime = recode.totalTime;
        _extractionSteps = List.from(recode.extractionSteps);
        _rating = recode.rating ?? 0;
        _acidity = recode.acidity ?? 0;
        _sweetness = recode.sweetness ?? 0;
        _bitterness = recode.bitterness ?? 0;
        _body = recode.body ?? 0;
        _aroma = recode.aroma ?? 0;

        _memoController.text = recode.memo ?? '';
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('기록을 불러올 수 없습니다: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    if (_brewMethod == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('추출 방식을 선택해주세요')));
      return;
    }

    setState(() => _isSaving = true);
    try {
      final origin = _originSelection?.displayText;

      // 총 물량/시간: 입력값이 없으면 추출 단계에서 자동 계산
      final inputWater = double.tryParse(_totalWaterController.text);
      final inputTime = _totalTime;

      double? totalWater = inputWater;
      int? totalTime = inputTime;

      if (_extractionSteps.isNotEmpty) {
        if (totalWater == null || totalWater == 0) {
          totalWater = _extractionSteps.fold<double>(
            0,
            (sum, step) => sum + (step.water ?? 0),
          );
        }
        // 시간은 마지막 단계의 누적 시간 (타임라인 방식)
        if (totalTime == null || totalTime == 0) {
          totalTime = _extractionSteps.last.time ?? 0;
        }
      }

      if (isEditMode) {
        await recodesApi.update(
          widget.recodeId!,
          UpdateRecodeDto(
            brewMethod: _brewMethod,
            beanName: _beanNameController.text.isEmpty
                ? null
                : _beanNameController.text,
            roaster: _roasterController.text.isEmpty
                ? null
                : _roasterController.text,
            origin: origin,
            grindSize: _grindSizeController.text.isEmpty
                ? null
                : _grindSizeController.text,
            grinder: _grinderController.text.isEmpty
                ? null
                : _grinderController.text,
            dose: double.tryParse(_doseController.text),
            extractionSteps: _extractionSteps.isNotEmpty
                ? _extractionSteps
                : null,
            totalWater: totalWater,
            totalTime: totalTime,
            waterTemp: int.tryParse(_waterTempController.text),
            memo: _memoController.text.isEmpty ? null : _memoController.text,
            rating: _rating > 0 ? _rating : null,
            acidity: _acidity > 0 ? _acidity : null,
            sweetness: _sweetness > 0 ? _sweetness : null,
            bitterness: _bitterness > 0 ? _bitterness : null,
            body: _body > 0 ? _body : null,
            aroma: _aroma > 0 ? _aroma : null,
          ),
        );
      } else {
        await recodesApi.create(
          CreateRecodeDto(
            brewMethod: _brewMethod!,
            beanName: _beanNameController.text.isEmpty
                ? null
                : _beanNameController.text,
            roaster: _roasterController.text.isEmpty
                ? null
                : _roasterController.text,
            origin: origin,
            grindSize: _grindSizeController.text.isEmpty
                ? null
                : _grindSizeController.text,
            grinder: _grinderController.text.isEmpty
                ? null
                : _grinderController.text,
            dose: double.tryParse(_doseController.text),
            extractionSteps: _extractionSteps.isNotEmpty
                ? _extractionSteps
                : null,
            totalWater: totalWater,
            totalTime: totalTime,
            waterTemp: int.tryParse(_waterTempController.text),
            memo: _memoController.text.isEmpty ? null : _memoController.text,
            rating: _rating > 0 ? _rating : null,
            acidity: _acidity > 0 ? _acidity : null,
            sweetness: _sweetness > 0 ? _sweetness : null,
            bitterness: _bitterness > 0 ? _bitterness : null,
            body: _body > 0 ? _body : null,
            aroma: _aroma > 0 ? _aroma : null,
          ),
        );
      }

      ref.invalidate(myBrewLogsProvider);
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEditMode ? '기록이 수정되었습니다' : '기록이 저장되었습니다')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('저장 실패: $e')));
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return true; // 원두 정보는 선택사항
      case 1:
        return _brewMethod != null;
      case 2:
        return true; // 추출 설정도 선택사항
      case 3:
        return true;
      default:
        return false;
    }
  }

  void _nextStep() {
    if (_canProceed() && _currentStep < 3) {
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(isEditMode ? '기록 수정' : '새 기록', style: _appBarTitleStyle),
        leading: IconButton(
          icon: const Icon(LucideIcons.x, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (isEditMode)
            IconButton(
              icon: const Icon(LucideIcons.trash2, color: AppColors.error),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 스텝 인디케이터
                _buildStepIndicator(),

                // 폼 내용
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.screenPadding),
                    child: RepaintBoundary(child: _buildCurrentStep()),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildStepIndicator() {
    final steps = ['원두', '추출 방식', '설정', '평가'];

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.gray100)),
      ),
      child: Row(
        children: List.generate(steps.length, (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (index <= _currentStep || _canProceed()) {
                  setState(() => _currentStep = index);
                }
              },
              child: Column(
                children: [
                  Row(
                    children: [
                      if (index > 0)
                        Expanded(
                          child: Container(
                            height: 2,
                            color: isCompleted
                                ? AppColors.primary
                                : AppColors.gray200,
                          ),
                        ),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive || isCompleted
                              ? AppColors.primary
                              : AppColors.gray200,
                        ),
                        child: Center(
                          child: isCompleted
                              ? const Icon(
                                  LucideIcons.check,
                                  size: 12,
                                  color: Colors.white,
                                )
                              : Text(
                                  '${index + 1}',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isActive
                                        ? Colors.white
                                        : AppColors.gray500,
                                  ),
                                ),
                        ),
                      ),
                      if (index < steps.length - 1)
                        Expanded(
                          child: Container(
                            height: 2,
                            color: isCompleted
                                ? AppColors.primary
                                : AppColors.gray200,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    steps[index],
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      color: isActive
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildBeanInfoStep();
      case 1:
        return _buildBrewMethodStep();
      case 2:
        return _buildExtractionStep();
      case 3:
        return _buildFlavorStep();
      default:
        return const SizedBox();
    }
  }

  // Step 0: 원두 정보
  Widget _buildBeanInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('어떤 원두를 사용하셨나요?', style: _titleStyle),
        const SizedBox(height: AppSpacing.lg),

        // 싱글 오리진 / 블렌드 선택
        Text('원두 타입', style: AppTypography.labelMedium),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _buildTypeButton(
                label: '싱글 오리진',
                icon: LucideIcons.mapPin,
                isSelected: !_isBlend,
                onTap: () {
                  setState(() {
                    _isBlend = false;
                    if (_originSelection?.isBlend == true) {
                      _originSelection = null;
                    }
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTypeButton(
                label: '블렌드',
                icon: LucideIcons.shuffle,
                isSelected: _isBlend,
                onTap: () {
                  setState(() {
                    _isBlend = true;
                    _variety = null;
                    if (_originSelection?.isBlend == false) {
                      _originSelection = null;
                    }
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // 원산지 선택
        Text('원산지', style: AppTypography.labelMedium),
        const SizedBox(height: AppSpacing.sm),
        _buildPickerButton(
          icon: LucideIcons.mapPin,
          label: _originSelection?.isBlend == true ? '블렌드' : '싱글 오리진',
          value: _originSelection?.displayTextWithFlag,
          hint: '원산지를 선택하세요',
          onTap: () async {
            final selected = await OriginPicker.show(
              context,
              initialSelection: _originSelection,
              isBlend: _isBlend,
            );
            if (selected != null) {
              setState(() {
                _originSelection = selected;
                _isBlend = selected.isBlend;
              });
            }
          },
        ),
        const SizedBox(height: AppSpacing.lg),

        // 품종 선택 (싱글 오리진만)
        if (!_isBlend) ...[
          Text('품종', style: AppTypography.labelMedium),
          const SizedBox(height: AppSpacing.sm),
          VarietyDisplay(
            varietyValue: _variety,
            onTap: () async {
              final selected = await showVarietyPicker(
                context,
                selectedValue: _variety,
              );
              if (selected != null) {
                setState(() => _variety = selected.value);
              }
            },
          ),
          const SizedBox(height: AppSpacing.lg),
        ],

        // 로스터리
        _buildInputField(
          controller: _roasterController,
          label: '로스터리',
          hint: '예: 프릳츠 커피 컴퍼니',
          icon: LucideIcons.flame,
        ),
        const SizedBox(height: AppSpacing.lg),

        // 원두 이름
        _buildInputField(
          controller: _beanNameController,
          label: _isBlend ? '블렌드 이름' : '원두 이름',
          hint: _isBlend ? '예: 하우스 블렌드' : '예: 에티오피아 예가체프',
          icon: LucideIcons.coffee,
        ),
      ],
    );
  }

  // Step 1: 추출 방식 선택
  Widget _buildBrewMethodStep() {
    final grouped = BrewMethod.grouped;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('어떤 방식으로 추출하셨나요?', style: _titleStyle),
        const SizedBox(height: AppSpacing.lg),

        for (final category in BrewCategory.values)
          if (grouped[category] != null && grouped[category]!.isNotEmpty) ...[
            Text(
              category.label,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: grouped[category]!.map((method) {
                final isSelected = _brewMethod == method.value;
                return GestureDetector(
                  onTap: () => setState(() => _brewMethod = method.value),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.gray300,
                      ),
                    ),
                    child: Text(
                      method.label,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
      ],
    );
  }

  // Step 2: 추출 설정
  Widget _buildExtractionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('추출 설정을 입력해주세요', style: _titleStyle),
        const SizedBox(height: AppSpacing.lg),

        // 2열 그리드
        Row(
          children: [
            Expanded(
              child: _buildInputField(
                controller: _doseController,
                label: '원두량 (g)',
                hint: '18',
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInputField(
                controller: _waterTempController,
                label: '물 온도 (°C)',
                hint: '93',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        Row(
          children: [
            Expanded(
              child: _buildInputField(
                controller: _totalWaterController,
                label: '총 물량 (ml)',
                hint: '300',
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: _buildTimeSelector()),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // 분쇄도
        Text('분쇄도', style: AppTypography.labelMedium),
        const SizedBox(height: AppSpacing.sm),
        _buildGrindSizeInput(),
        const SizedBox(height: AppSpacing.md),

        // 그라인더
        _buildInputField(
          controller: _grinderController,
          label: '그라인더',
          hint: '예: Comandante C40',
          icon: LucideIcons.settings,
        ),
        const SizedBox(height: AppSpacing.lg),

        // 추출 단계
        Text('추출 단계', style: AppTypography.labelMedium),
        const SizedBox(height: 4),
        Text(
          '시간은 이전 단계에서 자동으로 누적됩니다',
          style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildExtractionSteps(),
      ],
    );
  }

  // Step 3: 맛 평가
  Widget _buildFlavorStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('맛을 평가해주세요', style: _titleStyle),
        const SizedBox(height: AppSpacing.lg),

        // 별점
        Text('평점', style: AppTypography.labelMedium),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: List.generate(5, (index) {
            final value = index + 1;
            return GestureDetector(
              onTap: () => setState(() => _rating = value.toDouble()),
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  _rating >= value ? LucideIcons.star : LucideIcons.star,
                  color: _rating >= value ? Colors.amber : AppColors.gray300,
                  size: 32,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: AppSpacing.lg),

        // 맛 프로필
        _buildFlavorSlider('산미', _acidity, (v) => setState(() => _acidity = v)),
        _buildFlavorSlider(
          '단맛',
          _sweetness,
          (v) => setState(() => _sweetness = v),
        ),
        _buildFlavorSlider(
          '쓴맛',
          _bitterness,
          (v) => setState(() => _bitterness = v),
        ),
        _buildFlavorSlider('바디', _body, (v) => setState(() => _body = v)),
        _buildFlavorSlider('향미', _aroma, (v) => setState(() => _aroma = v)),

        const SizedBox(height: AppSpacing.md),

        // 메모
        _buildInputField(
          controller: _memoController,
          label: '메모',
          hint: '맛에 대한 간단한 메모',
          maxLines: 3,
        ),
      ],
    );
  }

  // 공통 위젯들
  Widget _buildTypeButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.gray300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? Colors.white : AppColors.gray500,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerButton({
    required IconData icon,
    required String label,
    String? value,
    required String hint,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.gray300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.gray500),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (value != null)
                    Text(
                      label,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  Text(
                    value ?? hint,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: value != null
                          ? AppColors.textPrimary
                          : AppColors.gray400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight, size: 20, color: AppColors.gray400),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelMedium),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: GoogleFonts.inter(fontSize: 15),
          decoration: _inputDecoration.copyWith(
            hintText: hint,
            hintStyle: GoogleFonts.inter(color: AppColors.gray400),
            prefixIcon: icon != null
                ? Icon(icon, size: 20, color: AppColors.gray500)
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('총 추출 시간', style: AppTypography.labelMedium),
        const SizedBox(height: AppSpacing.xs),
        GestureDetector(
          onTap: () => _showTimePicker(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.gray50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gray200),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.clock, size: 20, color: AppColors.gray500),
                const SizedBox(width: 12),
                Text(
                  _totalTime != null ? _formatTime(_totalTime!) : '0분 0초',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: _totalTime != null
                        ? AppColors.textPrimary
                        : AppColors.gray400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGrindSizeInput() {
    final currentValue = double.tryParse(_grindSizeController.text) ?? 1.0;

    return Row(
      children: [
        // - 버튼
        IconButton(
          onPressed: () {
            final val = (currentValue - 1).clamp(1.0, 1500.0);
            setState(
              () => _grindSizeController.text = val % 1 == 0
                  ? val.toInt().toString()
                  : val.toStringAsFixed(1),
            );
          },
          icon: const Icon(LucideIcons.minus, size: 18),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.gray100,
            minimumSize: const Size(40, 40),
          ),
        ),
        const SizedBox(width: 8),
        // 숫자 입력
        Expanded(
          child: TextField(
            controller: _grindSizeController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            decoration: _grindInputDecoration,
            onChanged: (v) {
              final val = double.tryParse(v);
              if (val != null && val > 1500) {
                _grindSizeController.text = '1500';
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        // + 버튼
        IconButton(
          onPressed: () {
            final val = (currentValue + 1).clamp(1.0, 1500.0);
            setState(
              () => _grindSizeController.text = val % 1 == 0
                  ? val.toInt().toString()
                  : val.toStringAsFixed(1),
            );
          },
          icon: const Icon(LucideIcons.plus, size: 18),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.gray100,
            minimumSize: const Size(40, 40),
          ),
        ),
      ],
    );
  }

  Widget _buildExtractionSteps() {
    return Column(
      children: [
        ...List.generate(_extractionSteps.length, (index) {
          final step = _extractionSteps[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.gray50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${step.water?.toInt() ?? 0}ml · ${_formatTime(step.time ?? 0)}',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                      ),
                      if (step.note != null && step.note!.isNotEmpty)
                        Text(
                          step.note!,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.pencil, size: 16),
                  onPressed: () => _editExtractionStep(index),
                  color: AppColors.gray500,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x, size: 16),
                  onPressed: () =>
                      setState(() => _extractionSteps.removeAt(index)),
                  color: AppColors.gray500,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
          );
        }),
        OutlinedButton.icon(
          onPressed: _addExtractionStep,
          icon: const Icon(LucideIcons.plus, size: 18),
          label: const Text('단계 추가'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            side: BorderSide(color: AppColors.gray300),
          ),
        ),
      ],
    );
  }

  Widget _buildFlavorSlider(
    String label,
    double value,
    ValueChanged<double> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(label, style: AppTypography.bodySmall),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: AppColors.gray200,
                thumbColor: AppColors.primary,
              ),
              child: Slider(
                value: value,
                min: 0,
                max: 5,
                divisions: 5,
                onChanged: onChanged,
              ),
            ),
          ),
          SizedBox(
            width: 24,
            child: Text(
              value.toInt().toString(),
              style: AppTypography.labelSmall,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.md,
        AppSpacing.screenPadding,
        AppSpacing.screenPadding + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.gray100)),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _prevStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: AppColors.gray300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  '이전',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: _currentStep == 0 ? 1 : 1,
            child: ElevatedButton(
              onPressed: _isSaving
                  ? null
                  : (_currentStep < 3
                        ? (_canProceed() ? _nextStep : null)
                        : _save),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor: AppColors.gray300,
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _currentStep < 3 ? '다음' : '저장',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // 유틸리티 메서드들
  String _formatTime(int seconds) {
    if (seconds < 60) return '$seconds초';
    final min = seconds ~/ 60;
    final sec = seconds % 60;
    if (sec == 0) return '$min분';
    return '$min분 $sec초';
  }

  void _showTimePicker() {
    int minutes = (_totalTime ?? 0) ~/ 60;
    int seconds = (_totalTime ?? 0) % 60;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _TimePickerSheet(
        initialMinutes: minutes,
        initialSeconds: seconds,
        onSave: (totalSeconds) {
          setState(() => _totalTime = totalSeconds);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _addExtractionStep() {
    // 타임라인 방식: 이전 단계의 시간을 시작점으로 사용
    final previousTime = _extractionSteps.isNotEmpty
        ? _extractionSteps.last.time ?? 0
        : 0;

    _showExtractionStepDialog(
      stepNumber: _extractionSteps.length + 1,
      initialTime: previousTime,
      onSave: (step) => setState(() => _extractionSteps.add(step)),
    );
  }

  void _editExtractionStep(int index) {
    _showExtractionStepDialog(
      stepNumber: index + 1,
      initialStep: _extractionSteps[index],
      onSave: (step) => setState(() => _extractionSteps[index] = step),
    );
  }

  void _showExtractionStepDialog({
    required int stepNumber,
    ExtractionStep? initialStep,
    int? initialTime,
    required Function(ExtractionStep) onSave,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _ExtractionStepSheet(
        stepNumber: stepNumber,
        initialStep: initialStep,
        initialTime: initialTime,
        onSave: (step) {
          onSave(step);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('기록 삭제'),
        content: const Text('이 기록을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final router = GoRouter.of(context);
              final messenger = ScaffoldMessenger.of(context);
              navigator.pop();
              try {
                await recodesApi.delete(widget.recodeId!);
                ref.invalidate(myBrewLogsProvider);
                if (mounted) {
                  router.pop();
                  messenger.showSnackBar(
                    const SnackBar(content: Text('기록이 삭제되었습니다')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  messenger.showSnackBar(SnackBar(content: Text('삭제 실패: $e')));
                }
              }
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

/// 시간 선택 바텀시트
class _TimePickerSheet extends StatefulWidget {
  final int initialMinutes;
  final int initialSeconds;
  final Function(int) onSave;

  const _TimePickerSheet({
    required this.initialMinutes,
    required this.initialSeconds,
    required this.onSave,
  });

  @override
  State<_TimePickerSheet> createState() => _TimePickerSheetState();
}

class _TimePickerSheetState extends State<_TimePickerSheet> {
  late int _minutes;
  late int _seconds;
  late final TextEditingController _minController;
  late final TextEditingController _secController;

  @override
  void initState() {
    super.initState();
    _minutes = widget.initialMinutes;
    _seconds = widget.initialSeconds;
    _minController = TextEditingController(text: _minutes.toString());
    _secController = TextEditingController(
      text: _seconds.toString().padLeft(2, '0'),
    );
  }

  @override
  void dispose() {
    _minController.dispose();
    _secController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.lg,
        AppSpacing.screenPadding,
        MediaQuery.of(context).viewInsets.bottom + AppSpacing.screenPadding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('시간 선택', style: AppTypography.titleMedium),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTimeInput(_minController, '분', (v) {
                setState(() => _minutes = (int.tryParse(v) ?? 0).clamp(0, 59));
              }),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(':', style: AppTypography.headlineMedium),
              ),
              _buildTimeInput(_secController, '초', (v) {
                setState(() => _seconds = (int.tryParse(v) ?? 0).clamp(0, 59));
              }),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => widget.onSave(_minutes * 60 + _seconds),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('확인'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInput(
    TextEditingController controller,
    String label,
    ValueChanged<String> onChanged,
  ) {
    return Column(
      children: [
        SizedBox(
          width: 80,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: AppTypography.headlineMedium,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onChanged: onChanged,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTypography.caption),
      ],
    );
  }
}

/// 추출 단계 바텀시트
class _ExtractionStepSheet extends StatefulWidget {
  final int stepNumber;
  final ExtractionStep? initialStep;
  final int? initialTime; // 이전 단계들의 누적 시간
  final Function(ExtractionStep) onSave;

  const _ExtractionStepSheet({
    required this.stepNumber,
    this.initialStep,
    this.initialTime,
    required this.onSave,
  });

  @override
  State<_ExtractionStepSheet> createState() => _ExtractionStepSheetState();
}

class _ExtractionStepSheetState extends State<_ExtractionStepSheet> {
  late final TextEditingController _waterController;
  late final TextEditingController _noteController;
  late final TextEditingController _minController;
  late final TextEditingController _secController;
  int _minutes = 0;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    _waterController = TextEditingController(
      text: widget.initialStep?.water?.toInt().toString() ?? '',
    );
    _noteController = TextEditingController(
      text: widget.initialStep?.note ?? '',
    );

    // 편집 모드: 기존 값 사용, 새 단계: 이전 누적 시간 사용
    if (widget.initialStep?.time != null) {
      _minutes = widget.initialStep!.time! ~/ 60;
      _seconds = widget.initialStep!.time! % 60;
    } else if (widget.initialTime != null) {
      _minutes = widget.initialTime! ~/ 60;
      _seconds = widget.initialTime! % 60;
    }

    _minController = TextEditingController(text: _minutes.toString());
    _secController = TextEditingController(
      text: _seconds.toString().padLeft(2, '0'),
    );
  }

  @override
  void dispose() {
    _waterController.dispose();
    _noteController.dispose();
    _minController.dispose();
    _secController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.lg,
        AppSpacing.screenPadding,
        MediaQuery.of(context).viewInsets.bottom + AppSpacing.screenPadding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.initialStep != null
                ? '${widget.stepNumber}단계 수정'
                : '${widget.stepNumber}단계 추가',
            style: AppTypography.titleMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _waterController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: '물량 (ml)',
              hintText: '50',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(LucideIcons.droplet),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('시간', style: AppTypography.labelMedium),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _minutes = (_minutes - 1).clamp(0, 59);
                          _minController.text = _minutes.toString();
                        });
                      },
                      icon: const Icon(LucideIcons.minus),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.gray100,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          TextField(
                            controller: _minController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            style: AppTypography.headlineSmall,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: (v) => setState(
                              () => _minutes = (int.tryParse(v) ?? 0).clamp(
                                0,
                                59,
                              ),
                            ),
                          ),
                          Text('분', style: AppTypography.caption),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _minutes = (_minutes + 1).clamp(0, 59);
                          _minController.text = _minutes.toString();
                        });
                      },
                      icon: const Icon(LucideIcons.plus),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.gray100,
                      ),
                    ),
                  ],
                ),
              ),
              Text(':', style: AppTypography.headlineSmall),
              Expanded(
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _seconds = (_seconds - 5).clamp(0, 55);
                          _secController.text = _seconds.toString().padLeft(
                            2,
                            '0',
                          );
                        });
                      },
                      icon: const Icon(LucideIcons.minus),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.gray100,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          TextField(
                            controller: _secController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            style: AppTypography.headlineSmall,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: (v) => setState(
                              () => _seconds = (int.tryParse(v) ?? 0).clamp(
                                0,
                                59,
                              ),
                            ),
                          ),
                          Text('초', style: AppTypography.caption),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _seconds = (_seconds + 5).clamp(0, 55);
                          _secController.text = _seconds.toString().padLeft(
                            2,
                            '0',
                          );
                        });
                      },
                      icon: const Icon(LucideIcons.plus),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.gray100,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _noteController,
            decoration: InputDecoration(
              labelText: '메모 (선택)',
              hintText: '예: 뜸들이기',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(LucideIcons.fileText),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // null이면 0으로 처리
                final water = double.tryParse(_waterController.text) ?? 0.0;

                widget.onSave(
                  ExtractionStep(
                    step: widget.stepNumber,
                    water: water,
                    time: _minutes * 60 + _seconds,
                    note: _noteController.text.isEmpty
                        ? null
                        : _noteController.text,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(widget.initialStep != null ? '수정' : '추가'),
            ),
          ),
        ],
      ),
    );
  }
}
