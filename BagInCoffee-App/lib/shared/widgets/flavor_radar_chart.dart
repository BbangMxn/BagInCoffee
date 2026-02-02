import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// 맛 프로필 데이터
class FlavorProfile {
  final double acidity; // 산미
  final double sweetness; // 단맛
  final double bitterness; // 쓴맛
  final double body; // 바디감
  final double aroma; // 향 (또는 rating을 여기에 활용)

  const FlavorProfile({
    this.acidity = 0,
    this.sweetness = 0,
    this.bitterness = 0,
    this.body = 0,
    this.aroma = 0,
  });

  List<double> get values => [acidity, sweetness, bitterness, body, aroma];

  bool get isEmpty =>
      acidity == 0 &&
      sweetness == 0 &&
      bitterness == 0 &&
      body == 0 &&
      aroma == 0;

  FlavorProfile copyWith({
    double? acidity,
    double? sweetness,
    double? bitterness,
    double? body,
    double? aroma,
  }) {
    return FlavorProfile(
      acidity: acidity ?? this.acidity,
      sweetness: sweetness ?? this.sweetness,
      bitterness: bitterness ?? this.bitterness,
      body: body ?? this.body,
      aroma: aroma ?? this.aroma,
    );
  }
}

/// 5각형 레이더 차트 위젯
class FlavorRadarChart extends StatelessWidget {
  final FlavorProfile profile;
  final double size;
  final Color? fillColor;
  final Color? strokeColor;
  final Color? gridColor;
  final bool showLabels;
  final bool animated;

  const FlavorRadarChart({
    super.key,
    required this.profile,
    this.size = 200,
    this.fillColor,
    this.strokeColor,
    this.gridColor,
    this.showLabels = true,
    this.animated = true,
  });

  static const labels = ['산미', '단맛', '쓴맛', '바디', '향'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RadarChartPainter(
          values: profile.values,
          maxValue: 5,
          fillColor: fillColor ?? AppColors.black.withValues(alpha: 0.15),
          strokeColor: strokeColor ?? AppColors.black,
          gridColor: gridColor ?? AppColors.gray200,
          labels: showLabels ? labels : null,
        ),
      ),
    );
  }
}

class _RadarChartPainter extends CustomPainter {
  final List<double> values;
  final double maxValue;
  final Color fillColor;
  final Color strokeColor;
  final Color gridColor;
  final List<String>? labels;

  _RadarChartPainter({
    required this.values,
    required this.maxValue,
    required this.fillColor,
    required this.strokeColor,
    required this.gridColor,
    this.labels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius =
        math.min(size.width, size.height) / 2 - (labels != null ? 24 : 8);
    final angleStep = (2 * math.pi) / values.length;
    final startAngle = -math.pi / 2; // 12시 방향에서 시작

    // 그리드 그리기 (5단계)
    final gridPaint = Paint()
      ..color = gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int level = 1; level <= 5; level++) {
      final levelRadius = radius * (level / 5);
      final path = Path();

      for (int i = 0; i <= values.length; i++) {
        final angle = startAngle + (i % values.length) * angleStep;
        final x = center.dx + levelRadius * math.cos(angle);
        final y = center.dy + levelRadius * math.sin(angle);

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      canvas.drawPath(path, gridPaint);
    }

    // 축 그리기
    for (int i = 0; i < values.length; i++) {
      final angle = startAngle + i * angleStep;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);

      canvas.drawLine(center, Offset(x, y), gridPaint);
    }

    // 데이터 영역 그리기
    final dataPath = Path();
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i <= values.length; i++) {
      final index = i % values.length;
      final value = values[index].clamp(0, maxValue);
      final valueRadius = radius * (value / maxValue);
      final angle = startAngle + index * angleStep;
      final x = center.dx + valueRadius * math.cos(angle);
      final y = center.dy + valueRadius * math.sin(angle);

      if (i == 0) {
        dataPath.moveTo(x, y);
      } else {
        dataPath.lineTo(x, y);
      }
    }

    canvas.drawPath(dataPath, fillPaint);
    canvas.drawPath(dataPath, strokePaint);

    // 데이터 포인트 그리기
    final pointPaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.fill;

    for (int i = 0; i < values.length; i++) {
      final value = values[i].clamp(0, maxValue);
      final valueRadius = radius * (value / maxValue);
      final angle = startAngle + i * angleStep;
      final x = center.dx + valueRadius * math.cos(angle);
      final y = center.dy + valueRadius * math.sin(angle);

      canvas.drawCircle(Offset(x, y), 4, pointPaint);
      canvas.drawCircle(Offset(x, y), 3, Paint()..color = Colors.white);
    }

    // 레이블 그리기
    if (labels != null && labels!.length == values.length) {
      final textPainter = TextPainter(
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );

      for (int i = 0; i < labels!.length; i++) {
        final angle = startAngle + i * angleStep;
        final labelRadius = radius + 16;
        var x = center.dx + labelRadius * math.cos(angle);
        var y = center.dy + labelRadius * math.sin(angle);

        textPainter.text = TextSpan(
          text: labels![i],
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        );
        textPainter.layout();

        // 텍스트 위치 조정
        x -= textPainter.width / 2;
        y -= textPainter.height / 2;

        textPainter.paint(canvas, Offset(x, y));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RadarChartPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.strokeColor != strokeColor;
  }
}

/// 편집 가능한 레이더 차트
class EditableFlavorRadarChart extends StatefulWidget {
  final FlavorProfile profile;
  final ValueChanged<FlavorProfile> onChanged;
  final double size;

  const EditableFlavorRadarChart({
    super.key,
    required this.profile,
    required this.onChanged,
    this.size = 200,
  });

  @override
  State<EditableFlavorRadarChart> createState() =>
      _EditableFlavorRadarChartState();
}

class _EditableFlavorRadarChartState extends State<EditableFlavorRadarChart> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FlavorRadarChart(profile: widget.profile, size: widget.size),
        const SizedBox(height: 24),
        _buildSliders(),
      ],
    );
  }

  Widget _buildSliders() {
    final items = [
      (
        '산미',
        widget.profile.acidity,
        (double v) {
          widget.onChanged(widget.profile.copyWith(acidity: v));
        },
      ),
      (
        '단맛',
        widget.profile.sweetness,
        (double v) {
          widget.onChanged(widget.profile.copyWith(sweetness: v));
        },
      ),
      (
        '쓴맛',
        widget.profile.bitterness,
        (double v) {
          widget.onChanged(widget.profile.copyWith(bitterness: v));
        },
      ),
      (
        '바디',
        widget.profile.body,
        (double v) {
          widget.onChanged(widget.profile.copyWith(body: v));
        },
      ),
      (
        '향',
        widget.profile.aroma,
        (double v) {
          widget.onChanged(widget.profile.copyWith(aroma: v));
        },
      ),
    ];

    return Column(
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: Text(item.$1, style: AppTypography.labelSmall),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: AppColors.black,
                    inactiveTrackColor: AppColors.gray200,
                    thumbColor: AppColors.black,
                    overlayColor: AppColors.black.withValues(alpha: 0.1),
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 8,
                    ),
                  ),
                  child: Slider(
                    value: item.$2,
                    min: 0,
                    max: 5,
                    divisions: 10,
                    onChanged: item.$3,
                  ),
                ),
              ),
              SizedBox(
                width: 32,
                child: Text(
                  item.$2.toStringAsFixed(1),
                  style: AppTypography.labelSmall,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
