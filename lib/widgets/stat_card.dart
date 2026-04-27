import 'package:flutter/material.dart';
import '../models/app_theme.dart';

class StatCard extends StatelessWidget {
  final String value;
  final String unit;
  final String label;
  final bool isAccent;
  final Color? valueColor;

  const StatCard({
    super.key,
    required this.value,
    required this.unit,
    required this.label,
    this.isAccent = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
        color: isAccent ? AppTheme.bgCardAlt : AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAccent ? AppTheme.accentBorder : AppTheme.border,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: valueColor ??
                        (isAccent ? AppTheme.accentLight : AppTheme.textPrimary),
                    height: 1.1,
                  ),
                ),
                TextSpan(
                  text: ' $unit',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textMuted,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              color: AppTheme.textMuted,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
