import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import 'dart:math';

class MonthlyProgressChart extends ConsumerWidget {
  final double paidAmount;
  final double totalDue;

  const MonthlyProgressChart({
    Key? key,
    required this.paidAmount,
    required this.totalDue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencySymbol = ref.watch(currencyProvider);
    double progress = totalDue == 0 ? 0 : paidAmount / totalDue;
    if (progress > 1) progress = 1;

    return SizedBox(
      height: 200,
      width: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(200, 200),
            painter: _ProgressPainter(
              progress: progress,
              trackColor: Colors.pink.shade50,
              progressColor: Colors.pinkAccent.shade100,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Due this month',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                '$currencySymbol${(totalDue - paidAmount).toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                'left to pay',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade400,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;

  _ProgressPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) - 16;
    final strokeWidth = 24.0;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw background track (270 degrees, starting from 135 degrees)
    const startAngle = 135 * (pi / 180);
    const sweepAngle = 270 * (pi / 180);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      trackPaint,
    );

    // Draw progress
    final progressAngle = sweepAngle * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      progressAngle,
      false,
      progressPaint,
    );

    // Draw thumb at the end of progress if progress > 0
    if (progress > 0) {
      final thumbAngle = startAngle + progressAngle;
      final thumbCenter = Offset(
        center.dx + radius * cos(thumbAngle),
        center.dy + radius * sin(thumbAngle),
      );

      final thumbPaint = Paint()..color = Colors.white;
      canvas.drawCircle(thumbCenter, strokeWidth / 2 - 2, thumbPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor;
  }
}
