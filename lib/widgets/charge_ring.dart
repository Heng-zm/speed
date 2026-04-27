import 'dart:math';
import 'package:flutter/material.dart';
import '../models/app_theme.dart';

class ChargeRingWidget extends StatefulWidget {
  final double percentage;
  final bool isCharging;

  const ChargeRingWidget({
    super.key,
    required this.percentage,
    required this.isCharging,
  });

  @override
  State<ChargeRingWidget> createState() => _ChargeRingWidgetState();
}

class _ChargeRingWidgetState extends State<ChargeRingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _glowAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    if (widget.isCharging) {
      _glowController.repeat(reverse: true);
    }
  }

  // PERFORMANCE FIX: Stop the animation if we stop charging.
  // Otherwise, the CPU keeps running the loop 60fps in the background.
  @override
  void didUpdateWidget(ChargeRingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCharging != oldWidget.isCharging) {
      if (widget.isCharging) {
        _glowController.repeat(reverse: true);
      } else {
        _glowController.stop();
      }
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // PERFORMANCE FIX: Only wrap the CustomPaint in AnimatedBuilder.
          // Rebuilding Text and Column 60 times a second causes frame drops.
          AnimatedBuilder(
            animation: _glowAnim,
            builder: (context, _) {
              return CustomPaint(
                size: const Size(200, 200),
                painter: _RingPainter(
                  percentage: widget.percentage / 100,
                  glowOpacity: _glowAnim.value,
                  isCharging: widget.isCharging,
                ),
              );
            },
          ),

          // Static text is outside the AnimatedBuilder, so it only rebuilds
          // when the actual percentage/state changes, not 60fps.
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.isCharging)
                const Icon(
                  Icons.bolt_rounded,
                  color: AppTheme.accent,
                  size: 22,
                ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: widget.percentage.toStringAsFixed(0),
                      style: const TextStyle(
                        fontFamily: 'SpaceGrotesk', // Ensure this is in pubspec
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                        letterSpacing: -2,
                        height: 1.0,
                      ),
                    ),
                    const TextSpan(
                      text: '%',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.isCharging ? 'FAST CHARGING' : 'DISCHARGING',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color:
                      widget.isCharging ? AppTheme.accent : AppTheme.textMuted,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double percentage;
  final double glowOpacity;
  final bool isCharging;

  // PERFORMANCE FIX: Pre-allocate Paint objects.
  // Creating Paint objects and MaskFilters inside paint() 60 times a second is very expensive.
  static final Paint _bgPaint = Paint()
    ..color = const Color(0xFF1A1A1A)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 10.0
    ..strokeCap = StrokeCap.round;

  final Paint _glowPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 22.0 // 10.0 + 12.0
    ..strokeCap = StrokeCap.round
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

  final Paint _mainPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 10.0
    ..strokeCap = StrokeCap.round;

  static final Paint _dotPaint = Paint()
    ..color = AppTheme.accentLight
    ..style = PaintingStyle.fill;

  _RingPainter({
    required this.percentage,
    required this.glowOpacity,
    required this.isCharging,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 12;
    const startAngle = -pi / 2;
    final sweepAngle = 2 * pi * percentage;

    // 1. Draw Background ring
    canvas.drawCircle(center, radius, _bgPaint);

    if (percentage <= 0) return;

    // 2. Draw Glow ring (Only if charging)
    if (isCharging) {
      // Just update the color, re-use the expensive Paint and MaskFilter object
      _glowPaint.color = AppTheme.accent.withOpacity(0.15 * glowOpacity);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        _glowPaint,
      );
    }

    // 3. Draw Main ring with gradient
    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      startAngle: startAngle,
      endAngle: startAngle + sweepAngle,
      colors: const [
        Color(0xFF0F6E56),
        Color(0xFF1D9E75),
        Color(0xFF5DCAA5),
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    // Update shader on cached paint object
    _mainPaint.shader = gradient.createShader(rect);

    canvas.drawArc(
      rect,
      startAngle,
      sweepAngle,
      false,
      _mainPaint,
    );

    // 4. Draw End dot
    if (percentage > 0.02) {
      final endX = center.dx + radius * cos(startAngle + sweepAngle);
      final endY = center.dy + radius * sin(startAngle + sweepAngle);
      canvas.drawCircle(Offset(endX, endY), 5, _dotPaint);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.percentage != percentage ||
      old.glowOpacity != glowOpacity ||
      old.isCharging !=
          isCharging; // Bug fix: ensure redraw if charging state swaps
}
