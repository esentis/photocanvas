import 'package:flutter/material.dart';
import 'package:photocanvas/theme/app_theme.dart';

/// Standard surface card used across the app: rounded, hairline border,
/// soft ambient shadow.
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppTheme.space5),
    this.borderColor,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: borderColor ?? AppTheme.stroke),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

/// Small uppercase caption with an accent tick, used to title card sections.
class SectionHeader extends StatelessWidget {
  const SectionHeader(
    this.title, {
    this.icon,
    super.key,
  });

  final String title;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: AppTheme.brandGradient,
          ),
        ),
        const SizedBox(width: AppTheme.space2),
        Flexible(
          child: Text(
            title.toUpperCase(),
            style: AppTheme.label,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (icon != null) ...[
          const SizedBox(width: AppTheme.space2),
          Icon(icon, size: 14, color: AppTheme.textMuted),
        ],
      ],
    );
  }
}

/// Label/value pair used in the image metadata grid.
class StatTile extends StatelessWidget {
  const StatTile({
    required this.label,
    required this.value,
    this.mono = false,
    this.maxWidth = 220,
    super.key,
  });

  final String label;
  final String value;

  /// Renders [value] with the monospace face (hex codes, numbers...).
  final bool mono;

  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label.toUpperCase(), style: AppTheme.label),
        const SizedBox(height: 2),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: mono ? AppTheme.mono : AppTheme.titleSmall,
          ),
        ),
      ],
    );
  }
}
