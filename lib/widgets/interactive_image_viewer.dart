// Too strict
// ignore_for_file: deprecated_member_use

import 'dart:html' as html;
import 'dart:math' as math;

import 'package:drop_zone/drop_zone.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:photocanvas/constants.dart';
import 'package:photocanvas/models/text_placement.dart';
import 'package:photocanvas/theme/app_theme.dart';
import 'package:photocanvas/widgets/common/app_button.dart';
import 'package:photocanvas/widgets/photo_magnifier.dart';

/// The loaded image: drop target (for swapping images), pixel-precise
/// magnifier surface and copy-on-click area.
class InteractiveImageViewer extends StatelessWidget {
  const InteractiveImageViewer({
    required this.imageData,
    required this.onDrop,
    required this.onPointerHover,
    required this.onPointerDown,
    required this.onMouseExit,
    required this.pointerLocalPos,
    required this.onClearImage,
    this.textPlacementSuggestion,
    this.showTextZone = false,
    this.onToggleTextZone,
    super.key,
  });

  final Uint8List imageData;
  final void Function(List<html.File>?) onDrop;
  final void Function(PointerHoverEvent) onPointerHover;
  final void Function(PointerDownEvent) onPointerDown;
  final VoidCallback onMouseExit;

  /// Drives magnifier position/visibility without rebuilding the image.
  final ValueListenable<Offset?> pointerLocalPos;
  final VoidCallback onClearImage;

  /// Most readable rectangle for overlay text; null disables the toggle.
  final TextPlacementSuggestion? textPlacementSuggestion;
  final bool showTextZone;
  final VoidCallback? onToggleTextZone;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: DropZone(
            onDragEnter: () => kLog.i('Entering image'),
            onDragExit: () => kLog.i('Exiting image'),
            onDrop: onDrop,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.imageBackdrop,
                borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                border: Border.all(color: AppTheme.strokeStrong),
                boxShadow: AppTheme.cardShadow,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusXl - 1),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Listener(
                      onPointerHover: onPointerHover,
                      onPointerDown: onPointerDown,
                      child: MouseRegion(
                        onExit: (_) => onMouseExit(),
                        child: Image.memory(imageData),
                      ),
                    ),
                    if (showTextZone && textPlacementSuggestion != null)
                      _TextZoneOverlay(suggestion: textPlacementSuggestion!),
                    // The loupe stays above the zone scrim so pixel
                    // inspection keeps working while the zone is shown.
                    MagnifierOverlay(
                      imageData: imageData,
                      pointerLocalPos: pointerLocalPos,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppTheme.space4),
        _ViewerActions(
          onClearImage: onClearImage,
          showTextZone: showTextZone,
          canToggleTextZone:
              textPlacementSuggestion != null && onToggleTextZone != null,
          onToggleTextZone: onToggleTextZone,
        ),
      ],
    );
  }
}

class _ViewerActions extends StatelessWidget {
  const _ViewerActions({
    required this.onClearImage,
    required this.showTextZone,
    required this.canToggleTextZone,
    required this.onToggleTextZone,
  });

  final VoidCallback onClearImage;
  final bool showTextZone;
  final bool canToggleTextZone;
  final VoidCallback? onToggleTextZone;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppTheme.space4,
      runSpacing: AppTheme.space2,
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (canToggleTextZone)
          GhostButton(
            label: showTextZone ? 'Hide text zone' : 'Best text zone',
            icon: showTextZone
                ? Icons.visibility_off_outlined
                : Icons.text_fields_rounded,
            onTap: onToggleTextZone!,
          ),
        GhostButton(
          label: 'Clear image',
          icon: Icons.delete_outline_rounded,
          onTap: onClearImage,
          hoverColor: AppTheme.error,
        ),
        Text(
          'Tip: hover to inspect pixels · click to copy a color',
          style: AppTheme.bodySmall.copyWith(color: AppTheme.textMuted),
        ),
      ],
    );
  }
}

/// Draws the recommended text area and previews sample text in the suggested
/// color without obscuring the image around it.
///
/// Everything is painted in a single [CustomPaint] instead of a widget
/// stack on purpose: this overlay lives inside a scroll view, so build-
/// time layout queries would see unbounded height. A painter receives the
/// concrete canvas size at paint time and cannot fall into that trap.
class _TextZoneOverlay extends StatelessWidget {
  const _TextZoneOverlay({required this.suggestion});

  final TextPlacementSuggestion suggestion;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _TextZonePainter(suggestion: suggestion),
        ),
      ),
    );
  }
}

class _TextZonePainter extends CustomPainter {
  _TextZonePainter({required this.suggestion});

  static const double _cornerRadius = 14;

  final TextPlacementSuggestion suggestion;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      suggestion.region.left * size.width,
      suggestion.region.top * size.height,
      suggestion.region.width * size.width,
      suggestion.region.height * size.height,
    );

    final zone = RRect.fromRectAndRadius(
      rect.deflate(1),
      const Radius.circular(_cornerRadius),
    );
    // The region can be narrower than the combined preview and badge. Clip as
    // a final safeguard, while the label layout below keeps both comfortably
    // inside the zone at normal image sizes.
    canvas
      ..drawRRect(
        zone,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = AppTheme.primaryStrong,
      )
      ..save()
      ..clipRRect(zone);
    _drawLabel(canvas, zone.outerRect);
    canvas.restore();
  }

  /// Draws the ratio badge at the top-right and the sample text at the
  /// bottom-left so they never compete for the same horizontal space.
  void _drawLabel(Canvas canvas, Rect rect) {
    const margin = 12.0;
    const pillPaddingH = 7.0;
    const pillPaddingV = 4.0;
    final contentWidth = math.max<double>(0, rect.width - margin * 2);
    final contentHeight = math.max<double>(0, rect.height - margin * 2);
    if (contentWidth < 1 || contentHeight < 1) return;

    final aaFontSize = math.min<double>(
      (rect.height * 0.28).clamp(20.0, 44.0),
      contentHeight,
    );

    final aaPainter = TextPainter(
      text: TextSpan(
        text: 'Placeholder',
        style: TextStyle(
          fontSize: aaFontSize,
          fontWeight: FontWeight.w800,
          height: 1,
          color: suggestion.textColor,
          shadows: const [Shadow(color: Colors.black45, blurRadius: 6)],
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: contentWidth);

    final pillText =
        'Suggested · ${suggestion.contrastRatio.toStringAsFixed(1)}:1'
        '${suggestion.passesAa ? ' · AA ✓' : ''}';
    final pillPainter = TextPainter(
      text: TextSpan(
        text: pillText,
        style: AppTheme.mono.copyWith(fontSize: 11, color: Colors.white),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(
        maxWidth: math.max<double>(0, contentWidth - pillPaddingH * 2),
      );

    final pillWidth = math.min(
      contentWidth,
      pillPainter.width + pillPaddingH * 2,
    );
    final pillHeight = pillPainter.height + pillPaddingV * 2;
    final pillRect = Rect.fromLTWH(
      rect.right - margin - pillWidth,
      rect.top + margin,
      pillWidth,
      pillHeight,
    );
    final aaOffset = Offset(
      rect.left + margin,
      math.max(rect.top + margin, rect.bottom - margin - aaPainter.height),
    );

    final pillRRect = RRect.fromRectAndRadius(
      pillRect,
      const Radius.circular(999),
    );
    canvas
      ..drawRRect(
        pillRRect,
        Paint()..color = Colors.black.withValues(alpha: 0.55),
      )
      ..drawRRect(
        pillRRect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = Colors.white.withValues(alpha: 0.25),
      );

    aaPainter.paint(canvas, aaOffset);
    pillPainter.paint(
      canvas,
      Offset(
        pillRect.left + pillPaddingH,
        pillRect.top + pillPaddingV,
      ),
    );
  }

  @override
  bool shouldRepaint(_TextZonePainter oldDelegate) =>
      oldDelegate.suggestion != suggestion;
}
