import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:photocanvas/theme/app_theme.dart';
import 'package:photocanvas/widgets/circle_color.dart';

/// Row of live color read-outs shown above the image: dominant palette
/// color, last copied color and the currently hovered pixel color.
///
/// [hoveredColor] is listened to locally so pointer movement only rebuilds
/// the hovered chip, never the page.
class ColorInfoSection extends StatelessWidget {
  const ColorInfoSection({
    required this.paletteGenerator,
    required this.hoveredColor,
    required this.copiedColor,
    super.key,
  });

  final PaletteGenerator? paletteGenerator;

  /// Listened to locally so hover updates only rebuild the hovered chip.
  final ValueListenable<Color?> hoveredColor;
  final Color? copiedColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: ValueListenableBuilder<Color?>(
        valueListenable: hoveredColor,
        builder: (context, hovered, _) {
          final dominantColor = paletteGenerator?.dominantColor?.color;
          if (dominantColor == null && hovered == null && copiedColor == null) {
            return const SizedBox.shrink();
          }
          return Wrap(
            spacing: AppTheme.space3,
            runSpacing: AppTheme.space2,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              if (dominantColor != null)
                _ColorReadOut(label: 'Dominant', color: dominantColor),
              if (hovered != null) _HoveredChip(color: hovered),
              if (copiedColor != null)
                _ColorReadOut(label: 'Copied', color: copiedColor!),
            ],
          );
        },
      ),
    );
  }
}

/// Static labeled swatch.
class _ColorReadOut extends StatelessWidget {
  const _ColorReadOut({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return _ReadOutShell(
      label: label,
      child: CircleColor(
        color: color,
        cancelTap: true,
      ),
    );
  }
}

/// Labeled swatch for the hovered pixel with a live indicator dot.
class _HoveredChip extends StatelessWidget {
  const _HoveredChip({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return _ReadOutShell(
      label: 'Hovered',
      trailing: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.secondary,
          boxShadow: [
            BoxShadow(
              color: AppTheme.secondary.withValues(alpha: 0.7),
              blurRadius: 6,
            ),
          ],
        ),
      ),
      child: CircleColor(
        color: color,
        cancelTap: true,
      ),
    );
  }
}

class _ReadOutShell extends StatelessWidget {
  const _ReadOutShell({
    required this.label,
    required this.child,
    this.trailing,
  });

  final String label;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space4,
        vertical: AppTheme.space2,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.stroke),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label.toUpperCase(), style: AppTheme.label),
              if (trailing != null) ...[
                const SizedBox(width: 5),
                trailing!,
              ],
            ],
          ),
          const SizedBox(height: 2),
          child,
        ],
      ),
    );
  }
}
