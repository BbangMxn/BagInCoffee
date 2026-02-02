import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../shared/widgets/brew_method_picker.dart';
import '../../../shared/widgets/flavor_radar_chart.dart';
import '../data/brew_method.dart';
import '../data/brew_log_model.dart';
import '../data/brew_log_provider.dart';

import '../data/bean_origin.dart';
import 'widgets/variety_picker.dart';
import 'widgets/origin_picker.dart';

/// 커피 추출 기록 작성/수정 화면
class BrewLogFormScreen extends ConsumerStatefulWidget {
  final String? logId; // null이면 새로 작성, 있으면 수정

  const BrewLogFormScreen({super.key, this.logId});

  @override
  ConsumerState<BrewLogFormScreen> createState() => _BrewLogFormScreenState();
}

class _BrewLogFormScreenState extends ConsumerState<BrewLogFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  int _currentStep = 0;

  // 추출 방식
  String? _brewMethod;

  // 원두 정보
  bool _isBlend = false; // 싱글 오리진 / 블렌드 선택
  final _beanNameController = TextEditingController();
  final _roasterController = TextEditingController();
  String? _variety; // 원두 품종
  OriginSelection? _originSelection; // 원산지 선택

  // 추출 정보
  final _doseController = TextEditingController();
  final _grindSizeController = TextEditingController();
  final _grinderController = TextEditingController();
  final _waterTempController = TextEditingController();
  final _totalWaterController = TextEditingController();
  final _totalTimeController = TextEditingController();

  // 추출 단계
  List<ExtractionStep> _extractionSteps = [];

  // 맛 프로필
  FlavorProfile _flavorProfile = const FlavorProfile();
  double _rating = 0;

  // 메모
  final _memoController = TextEditingController();
  bool _isFavorite = false;

  bool get isEditing => widget.logId != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _loadExistingLog();
    }
  }

  Future<void> _loadExistingLog() async {
    if (widget.logId == null) return;

    setState(() => _isLoading = true);

    try {
      final supabase = ref.read(supabaseProvider);
      final data = await supabase
          .from('brew_logs')
          .select()
          .eq('id', widget.logId!)
          .single();

      setState(() {
        _brewMethod = data['brew_method'];
        _beanNameController.text = data['bean_name'] ?? '';
        _roasterController.text = data['roaster'] ?? '';
        _variety = data['variety'];

        // 원산지 정보 복원
        final originCountry = data['origin_country'];
        final originRegion = data['origin_region'];
        if (originCountry != null) {
          final country = BeanOrigin.all.firstWhere(
            (o) => o.nameKo == originCountry,
            orElse: () => BeanOrigin.all.first,
          );
          _originSelection = OriginSelection.single(
            country,
            region: originRegion,
          );
          _isBlend = false;
        }

        _doseController.text = data['dose']?.toString() ?? '';
        _grindSizeController.text = data['grind_size'] ?? '';
        _grinderController.text = data['grinder'] ?? '';
        _waterTempController.text = data['water_temp']?.toString() ?? '';

        // 추출 단계 복원
        final steps = data['extraction_steps'] as List?;
        if (steps != null) {
          _extractionSteps = steps
              .map((s) => ExtractionStep.fromJson(s))
              .toList();
        }

        // 맛 프로필 복원
        _flavorProfile = FlavorProfile(
          acidity: (data['acidity'] as num?)?.toDouble() ?? 0,
          sweetness: (data['sweetness'] as num?)?.toDouble() ?? 0,
          bitterness: (data['bitterness'] as num?)?.toDouble() ?? 0,
          body: (data['body'] as num?)?.toDouble() ?? 0,
          aroma: (data['aroma'] as num?)?.toDouble() ?? 0,
        );

        _rating = (data['rating'] as num?)?.toDouble() ?? 0;
        _memoController.text = data['memo'] ?? '';
        _isFavorite = data['is_favorite'] ?? false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('기록 불러오기 실패: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
    _totalTimeController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(isEditing ? '기록 수정' : '새 기록'),
        leading: IconButton(
          icon: const Icon(LucideIcons.x),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_currentStep > 0)
            TextButton(
              onPressed: _currentStep < 3 ? _nextStep : _saveLog,
              child: Text(
                _currentStep < 3 ? '다음' : '저장',
                style: AppTypography.buttonMedium.copyWith(
                  color: AppColors.black,
                ),
              ),
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
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.screenPadding),
                      child: _buildCurrentStep(),
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildStepIndicator() {
    final steps = ['원두 정보', '추출 방식', '추출 설정', '맛 평가'];

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: List.generate(steps.length, (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;

          return Expanded(
            child: Row(
              children: [
                if (index > 0)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isCompleted ? AppColors.black : AppColors.gray200,
                    ),
                  ),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive || isCompleted
                        ? AppColors.black
                        : AppColors.gray200,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(
                            LucideIcons.check,
                            size: 14,
                            color: Colors.white,
                          )
                        : Text(
                            '${index + 1}',
                            style: AppTypography.labelSmall.copyWith(
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
                      color: isCompleted ? AppColors.black : AppColors.gray200,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildBeanInfoStep(); // 1단계: 원두 정보
      case 1:
        return _buildBrewMethodStep(); // 2단계: 추출 방식
      case 2:
        return _buildExtractionStep(); // 3단계: 추출 설정
      case 3:
        return _buildFlavorStep(); // 4단계: 맛 평가
      default:
        return const SizedBox();
    }
  }

  // Step 0: 추출 방식 선택
  Widget _buildBrewMethodStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('어떤 방식으로 추출하셨나요?', style: AppTypography.headlineSmall),
        const SizedBox(height: AppSpacing.xxl),

        // 추출 방식 선택
        BrewMethodPicker(
          selectedValue: _brewMethod,
          onSelected: (method) {
            setState(() => _brewMethod = method.value);
          },
        ),

        if (_brewMethod != null) ...[
          const SizedBox(height: AppSpacing.xxl),
          _buildSelectedMethodCard(),
        ],
      ],
    );
  }

  Widget _buildSelectedMethodCard() {
    final method = BrewMethod.fromValue(_brewMethod!);
    if (method == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.black, width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.black,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(method.category.icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(method.label, style: AppTypography.titleMedium),
                if (method.subLabel != null)
                  Text(method.subLabel!, style: AppTypography.caption),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(LucideIcons.x, size: 20),
            onPressed: () => setState(() => _brewMethod = null),
          ),
        ],
      ),
    );
  }

  // Step 0: 원두 정보
  Widget _buildBeanInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('어떤 원두를 사용하셨나요?', style: AppTypography.headlineSmall),
        const SizedBox(height: AppSpacing.xxl),

        // 1. 싱글 오리진 / 블렌드 선택
        Text('원두 타입', style: AppTypography.labelMedium),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Expanded(
              child: _buildOriginTypeButton(
                label: '싱글 오리진',
                icon: LucideIcons.mapPin,
                isSelected: !_isBlend,
                onTap: () {
                  setState(() {
                    _isBlend = false;
                    // 블렌드에서 싱글로 변경 시 원산지 초기화
                    if (_originSelection?.isBlend == true) {
                      _originSelection = null;
                    }
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildOriginTypeButton(
                label: '블렌드',
                icon: LucideIcons.shuffle,
                isSelected: _isBlend,
                onTap: () {
                  setState(() {
                    _isBlend = true;
                    _variety = null; // 블렌드는 품종 없음
                    // 싱글에서 블렌드로 변경 시 원산지 초기화
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

        // 2. 원산지 선택
        Text('원산지', style: AppTypography.labelMedium),
        const SizedBox(height: AppSpacing.xs),
        InkWell(
          onTap: () async {
            final selected = await OriginPicker.show(
              context,
              initialSelection: _originSelection,
              isBlend: _isBlend,
            );
            if (selected != null) {
              setState(() {
                _originSelection = selected;
                // 원산지 선택에서 블렌드 상태가 변경되면 반영
                _isBlend = selected.isBlend;
              });
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.gray300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.mapPin, size: 20, color: AppColors.gray500),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_originSelection != null)
                        Text(
                          _originSelection!.isBlend ? '블렌드' : '싱글 오리진',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      Text(
                        _originSelection?.displayTextWithFlag ?? '원산지를 선택하세요',
                        style: AppTypography.bodyMedium.copyWith(
                          color: _originSelection != null
                              ? AppColors.textPrimary
                              : AppColors.gray400,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  LucideIcons.chevronRight,
                  size: 20,
                  color: AppColors.gray400,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // 3. 품종 선택 (싱글 오리진인 경우만)
        if (!_isBlend) ...[
          Text('품종', style: AppTypography.labelMedium),
          const SizedBox(height: AppSpacing.xs),
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

        // 3. 로스터리
        _buildTextField(
          controller: _roasterController,
          label: '로스터리',
          hint: '예: 프릳츠 커피 컴퍼니',
          icon: LucideIcons.flame,
        ),
        const SizedBox(height: AppSpacing.lg),

        // 4. 원두 이름 (제품명)
        _buildTextField(
          controller: _beanNameController,
          label: _isBlend ? '블렌드 이름' : '원두 이름',
          hint: _isBlend ? '예: 하우스 블렌드' : '예: 에티오피아 예가체프',
          icon: LucideIcons.coffee,
        ),
      ],
    );
  }

  // Step 2: 추출 설정
  Widget _buildExtractionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('추출 설정을 입력해주세요', style: AppTypography.headlineSmall),
        const SizedBox(height: AppSpacing.xxl),

        // 2열 그리드
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _doseController,
                label: '원두량 (g)',
                hint: '18',
                keyboardType: TextInputType.number,
                icon: LucideIcons.scale,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildTextField(
                controller: _waterTempController,
                label: '물 온도 (°C)',
                hint: '93',
                keyboardType: TextInputType.number,
                icon: LucideIcons.thermometer,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        _buildTextField(
          controller: _grindSizeController,
          label: '분쇄도',
          hint: '예: 중간 (20 클릭)',
          icon: LucideIcons.settings2,
        ),
        const SizedBox(height: AppSpacing.lg),

        _buildTextField(
          controller: _grinderController,
          label: '그라인더',
          hint: '예: Comandante C40',
          icon: LucideIcons.cog,
        ),
        const SizedBox(height: AppSpacing.xxl),

        // 추출 단계
        _buildExtractionStepsSection(),
      ],
    );
  }

  Widget _buildExtractionStepsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('추출 단계', style: AppTypography.titleMedium),
            TextButton.icon(
              onPressed: _addExtractionStep,
              icon: const Icon(LucideIcons.plus, size: 18),
              label: const Text('단계 추가'),
              style: TextButton.styleFrom(foregroundColor: AppColors.black),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        if (_extractionSteps.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.gray50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.gray200),
            ),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.info,
                  size: 20,
                  color: AppColors.gray500,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    '추출 단계를 추가하면 총 물량과 시간이 자동 계산됩니다',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          ...List.generate(_extractionSteps.length, (index) {
            return _buildExtractionStepCard(index);
          }),
      ],
    );
  }

  Widget _buildExtractionStepCard(int index) {
    final step = _extractionSteps[index];

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.black,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: AppTypography.labelSmall.copyWith(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${step.water?.toInt() ?? 0}ml · ${step.time ?? 0}초',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (step.note != null && step.note!.isNotEmpty)
                  Text(step.note!, style: AppTypography.caption),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(LucideIcons.trash2, size: 18),
            onPressed: () => _removeExtractionStep(index),
            color: AppColors.gray500,
          ),
        ],
      ),
    );
  }

  void _addExtractionStep() {
    // 타임라인 방식: 이전 단계의 시간을 시작점으로 사용
    final previousTime = _extractionSteps.isNotEmpty
        ? _extractionSteps.last.time ?? 0
        : 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _ExtractionStepForm(
        stepNumber: _extractionSteps.length + 1,
        initialTime: previousTime,
        onSave: (step) {
          setState(() => _extractionSteps.add(step));
          Navigator.pop(context);
        },
      ),
    );
  }

  void _removeExtractionStep(int index) {
    setState(() => _extractionSteps.removeAt(index));
  }

  // Step 3: 맛 평가
  Widget _buildFlavorStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('맛은 어땠나요?', style: AppTypography.headlineSmall),
        const SizedBox(height: AppSpacing.xxl),

        // 별점
        Center(
          child: Column(
            children: [
              Text('전체 평점', style: AppTypography.labelMedium),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final filled = index < _rating;
                  return GestureDetector(
                    onTap: () => setState(() => _rating = index + 1.0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        filled ? LucideIcons.star : LucideIcons.star,
                        size: 36,
                        color: filled ? Colors.amber : AppColors.gray300,
                      ),
                    ),
                  );
                }),
              ),
              if (_rating > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _rating.toStringAsFixed(1),
                    style: AppTypography.headlineMedium,
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.xxxl),

        // 레이더 차트
        Center(
          child: EditableFlavorRadarChart(
            profile: _flavorProfile,
            onChanged: (profile) => setState(() => _flavorProfile = profile),
            size: 220,
          ),
        ),

        const SizedBox(height: AppSpacing.xxxl),

        // 메모
        _buildTextField(
          controller: _memoController,
          label: '메모',
          hint: '추출에 대한 메모를 남겨보세요',
          icon: LucideIcons.fileText,
          maxLines: 4,
        ),

        const SizedBox(height: AppSpacing.lg),

        // 즐겨찾기
        InkWell(
          onTap: () => setState(() => _isFavorite = !_isFavorite),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: _isFavorite ? Colors.amber.shade50 : AppColors.gray50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _isFavorite ? Colors.amber : AppColors.gray200,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _isFavorite ? LucideIcons.star : LucideIcons.star,
                  size: 24,
                  color: _isFavorite ? Colors.amber : AppColors.gray400,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('즐겨찾기에 추가', style: AppTypography.bodyMedium),
                      Text('나중에 쉽게 찾을 수 있어요', style: AppTypography.caption),
                    ],
                  ),
                ),
                Icon(
                  _isFavorite ? LucideIcons.check : LucideIcons.plus,
                  size: 20,
                  color: _isFavorite
                      ? Colors.amber.shade700
                      : AppColors.gray400,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelMedium),
        const SizedBox(height: AppSpacing.xs),
        Container(
          decoration: BoxDecoration(
            color: AppColors.gray100,
            borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTypography.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
              prefixIcon: Icon(icon, size: 20, color: AppColors.gray500),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.inputPaddingH,
                vertical: AppSpacing.inputPaddingV,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
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
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                child: const Text('이전'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: _currentStep == 0 ? 1 : 1,
            child: ElevatedButton(
              onPressed: _canProceed()
                  ? (_currentStep < 3 ? _nextStep : _saveLog)
                  : null,
              child: Text(_currentStep < 3 ? '다음' : '저장'),
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return true; // 원두 정보는 선택사항
      case 1:
        return _brewMethod != null; // 추출 방식은 필수
      case 2:
        return true; // 추출 설정도 선택사항
      case 3:
        return true;
      default:
        return false;
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    }
  }

  Future<void> _saveLog() async {
    if (!_canProceed()) return;

    setState(() => _isLoading = true);

    try {
      final supabase = ref.read(supabaseProvider);
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        throw Exception('로그인이 필요합니다');
      }

      final data = {
        'user_id': userId,
        'brew_method': _brewMethod,
        'bean_name': _beanNameController.text.isNotEmpty
            ? _beanNameController.text
            : null,
        'roaster': _roasterController.text.isNotEmpty
            ? _roasterController.text
            : null,
        'origin': _originSelection?.displayText,
        'origin_country': _originSelection?.country.nameKo,
        'origin_region': _originSelection?.region,
        'variety': _variety,
        'dose': _doseController.text.isNotEmpty
            ? double.tryParse(_doseController.text)
            : null,
        'grind_size': _grindSizeController.text.isNotEmpty
            ? _grindSizeController.text
            : null,
        'grinder': _grinderController.text.isNotEmpty
            ? _grinderController.text
            : null,
        'water_temp': _waterTempController.text.isNotEmpty
            ? int.tryParse(_waterTempController.text)
            : null,
        'extraction_steps': _extractionSteps.map((s) => s.toJson()).toList(),
        'rating': _rating > 0 ? _rating : null,
        'acidity': _flavorProfile.acidity > 0 ? _flavorProfile.acidity : null,
        'sweetness': _flavorProfile.sweetness > 0
            ? _flavorProfile.sweetness
            : null,
        'bitterness': _flavorProfile.bitterness > 0
            ? _flavorProfile.bitterness
            : null,
        'body': _flavorProfile.body > 0 ? _flavorProfile.body : null,
        'aroma': _flavorProfile.aroma > 0 ? _flavorProfile.aroma : null,
        'memo': _memoController.text.isNotEmpty ? _memoController.text : null,
        'is_favorite': _isFavorite,
      };

      if (isEditing) {
        await supabase.from('brew_logs').update(data).eq('id', widget.logId!);
      } else {
        await supabase.from('brew_logs').insert(data);
      }

      // 목록 새로고침
      ref.invalidate(myBrewLogsProvider);

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEditing ? '기록이 수정되었습니다' : '기록이 저장되었습니다')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('저장 실패: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// 원두 타입 선택 버튼
  Widget _buildOriginTypeButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
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
              size: 20,
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

/// 추출 단계 입력 폼
class _ExtractionStepForm extends StatefulWidget {
  final int stepNumber;
  final int initialTime;
  final ValueChanged<ExtractionStep> onSave;

  const _ExtractionStepForm({
    required this.stepNumber,
    this.initialTime = 0,
    required this.onSave,
  });

  @override
  State<_ExtractionStepForm> createState() => _ExtractionStepFormState();
}

class _ExtractionStepFormState extends State<_ExtractionStepForm> {
  final _waterController = TextEditingController();
  final _timeController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 타임라인 방식: 이전 단계의 시간을 기본값으로 설정
    _timeController.text = widget.initialTime.toString();
  }

  @override
  void dispose() {
    _waterController.dispose();
    _timeController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.screenPadding,
        right: AppSpacing.screenPadding,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${widget.stepNumber}단계 추가', style: AppTypography.headlineSmall),
          const SizedBox(height: AppSpacing.lg),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _waterController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: '물량 (ml)',
                    hintText: '50',
                    prefixIcon: const Icon(LucideIcons.droplet, size: 20),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: TextField(
                  controller: _timeController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: '시간 (초)',
                    hintText: '30',
                    prefixIcon: const Icon(LucideIcons.clock, size: 20),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          TextField(
            controller: _noteController,
            decoration: InputDecoration(
              labelText: '메모 (선택)',
              hintText: '뜸들이기, 1차 푸어 등',
              prefixIcon: const Icon(LucideIcons.fileText, size: 20),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(onPressed: _save, child: const Text('추가')),
          ),
        ],
      ),
    );
  }

  void _save() {
    final water = double.tryParse(_waterController.text);
    final time = int.tryParse(_timeController.text);

    if (water == null || time == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('물량과 시간을 입력해주세요')));
      return;
    }

    widget.onSave(
      ExtractionStep(
        step: widget.stepNumber,
        water: water,
        time: time,
        note: _noteController.text.isNotEmpty ? _noteController.text : null,
      ),
    );
  }
}
