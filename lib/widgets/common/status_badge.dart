import 'package:flutter/material.dart';
import 'package:photocanvas/theme/app_theme.dart';

/// Compact pill badge used for WCAG pass/fail indicators (AA / AAA).
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    required this.label,
    required this.passed,
    super.key,
  });

  final String label;
  final bool passed;

  @override
  Widget build(BuildContext context) {
    final color = passed ? AppTheme.success : AppTheme.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: color.withValues(alpha: passed ? 0.14 : 0.10),
        border: Border.all(color: color.withValues(alpha: 0.55)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            passed ? Icons.check_rounded : Icons.close_rounded,
            size: 11,
            color: color,
          ),
          const SizedBox(width: 2),
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              fontSize: 11,
              height: 1,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Inline warning pill (e.g. low-resolution notice).
class WarningBadge extends StatelessWidget {
  const WarningBadge({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        color: AppTheme.warning.withValues(alpha: 0.10),
        border: Border.all(color: AppTheme.warning.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 15,
            color: AppTheme.warning,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              message,
              style: AppTheme.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
