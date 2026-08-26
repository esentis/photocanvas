// Too strict
// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:html' as html;

import 'package:drop_zone/drop_zone.dart';
import 'package:flutter/material.dart';
import 'package:photocanvas/constants.dart';
import 'package:photocanvas/theme/app_theme.dart';
import 'package:photocanvas/widgets/common/app_button.dart';

/// Empty-state panel: users drop an image here or pick a file below it.
///
/// The parent drives the two states through [containerText]
/// ('Drop your image here' / 'Ready to drop') exactly like before.
class ImageDropZone extends StatelessWidget {
  const ImageDropZone({
    required this.containerColor,
    required this.containerText,
    required this.onDragEnter,
    required this.onDragExit,
    required this.onDrop,
    super.key,
  });

  final Color containerColor;
  final String containerText;
  final VoidCallback onDragEnter;
  final VoidCallback onDragExit;
  final void Function(List<dynamic>?) onDrop;

  bool get _isReady => containerText == 'Ready to drop';

  /// Opens a native file picker and forwards picked files through the
  /// same [onDrop] channel used by drag & drop.
  Future<void> _openFilePicker() async {
    final input = html.FileUploadInputElement()
      ..accept = validImageFormats.map((e) => '.$e').join(',')
      ..multiple = false;
    unawaited(
      input.onChange.first.then((_) {
        final files = input.files;
        if (files != null && files.isNotEmpty) {
          onDrop(files);
        }
      }),
    );
    input.click();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DropZone(
          onDragEnter: onDragEnter,
          onDragExit: onDragExit,
          onDrop: onDrop,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            height: 440,
            width: 560,
            decoration: BoxDecoration(
              color: _isReady
                  ? AppTheme.primary.withValues(alpha: 0.10)
                  : AppTheme.surface.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              boxShadow: _isReady ? AppTheme.glowShadow : AppTheme.cardShadow,
            ),
            child: CustomPaint(
              foregroundPainter: _DashedBorderPainter(
                color: _isReady
                    ? AppTheme.primaryStrong
                    : Colors.white.withValues(alpha: 0.22),
                radius: AppTheme.radiusXl,
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.space6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          gradient: AppTheme.brandGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withValues(alpha: 0.45),
                              blurRadius: 28,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            _isReady
                                ? Icons.image_rounded
                                : Icons.upload_rounded,
                            size: 38,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppTheme.space6),
                      Text(
                        containerText,
                        textAlign: TextAlign.center,
                        style: AppTheme.titleLarge.copyWith(fontSize: 30),
                      ),
                      const SizedBox(height: AppTheme.space2),
                      Text(
                        'Drag & drop an image anywhere on this panel,\n'
                        'or use the button below',
                        textAlign: TextAlign.center,
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppTheme.space6),
                      _FormatChips(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppTheme.space4),
        // Lives outside the DropZone so the browser click reaches Flutter.
        GhostButton(
          label: 'Browse files',
          icon: Icons.folder_open_rounded,
          onTap: _openFilePicker,
        ),
      ],
    );
  }
}

class _FormatChips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppTheme.space2,
      runSpacing: AppTheme.space1,
      alignment: WrapAlignment.center,
      children: validImageFormats
          .map(
            (format) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
                color: AppTheme.surfaceAlt,
                border: Border.all(color: AppTheme.strokeStrong),
              ),
              child: Text(
                format.toUpperCase(),
                style: AppTheme.bodySmall.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  static const double _dashWidth = 7;
  static const double _dashGap = 6;
  static const double _strokeWidth = 1.6;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..color = color;

    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + _dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0.0, metric.length)),
          paint,
        );
        distance = next + _dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
