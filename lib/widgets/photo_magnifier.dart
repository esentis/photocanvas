import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photocanvas/constants.dart';
import 'package:photocanvas/theme/app_theme.dart';

/// Full-surface overlay that draws a loupe centered on the pointer.
///
/// Deliberately does not use [RawMagnifier]: it relies on a backdrop filter,
/// which flickers/vanishes on the web renderers as soon as frames stop being
/// produced. Here the magnified region is painted directly from the decoded
/// image, so it stays rock solid while the cursor rests inside the image.
class MagnifierOverlay extends StatefulWidget {
  const MagnifierOverlay({
    required this.imageData,
    required this.pointerLocalPos,
    super.key,
  });

  final Uint8List imageData;
  final ValueListenable<Offset?> pointerLocalPos;

  @override
  State<MagnifierOverlay> createState() => _MagnifierOverlayState();
}

class _MagnifierOverlayState extends State<MagnifierOverlay> {
  static const double _lensRadius = 75;
  static const double _magnification = 3;
  static const double _borderWidth = 4;

  ui.Image? _image;

  @override
  void initState() {
    super.initState();
    unawaited(_decode());
  }

  @override
  void didUpdateWidget(MagnifierOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.imageData, widget.imageData)) unawaited(_decode());
  }

  Future<void> _decode() async {
    final data = widget.imageData;
    try {
      final codec = await ui.instantiateImageCodec(data);
      final frame = await codec.getNextFrame();
      if (!mounted || !identical(data, widget.imageData)) {
        frame.image.dispose();
        return;
      }
      setState(() => _image = frame.image);
    } on Exception catch (e) {
      kLog.e('Failed to decode image for magnifier: $e');
    }
  }

  @override
  void dispose() {
    _image?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final image = _image;
    if (image == null) return const SizedBox.shrink();

    return ValueListenableBuilder<Offset?>(
      valueListenable: widget.pointerLocalPos,
      builder: (context, position, _) {
        if (position == null) return const SizedBox.shrink();
        return Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _LensPainter(
                image: image,
                position: position,
                lensRadius: _lensRadius,
                magnification: _magnification,
                borderWidth: _borderWidth,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LensPainter extends CustomPainter {
  _LensPainter({
    required this.image,
    required this.position,
    required this.lensRadius,
    required this.magnification,
    required this.borderWidth,
  });

  final ui.Image image;
  final Offset position;
  final double lensRadius;
  final double magnification;
  final double borderWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (!size.contains(position)) return;

    final lensRect = Rect.fromCircle(center: position, radius: lensRadius);
    final lensShape = Path()..addOval(lensRect);

    // Map the sampled window from display coordinates to intrinsic pixels.
    final scaleX = image.width / size.width;
    final scaleY = image.height / size.height;
    final srcRect = Rect.fromCenter(
      center: Offset(position.dx * scaleX, position.dy * scaleY),
      width: lensRect.width / magnification * scaleX,
      height: lensRect.height / magnification * scaleY,
    );

    canvas
      ..save()
      ..clipPath(lensShape)
      ..drawImageRect(
        image,
        srcRect,
        lensRect,
        Paint()..filterQuality = FilterQuality.high,
      )
      ..restore()
      ..drawPath(
        lensShape,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth
          ..color = AppTheme.appBar,
      );

    _drawCrosshair(canvas, position);
  }

  void _drawCrosshair(Canvas canvas, Offset center) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: '+',
        style: AppTheme.defaultStyle.copyWith(color: Colors.white),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      center - Offset(textPainter.width, textPainter.height) / 2,
    );
  }

  @override
  bool shouldRepaint(_LensPainter oldDelegate) =>
      oldDelegate.image.isCloneOf(image) ||
      oldDelegate.position != position ||
      oldDelegate.lensRadius != lensRadius ||
      oldDelegate.magnification != magnification ||
      oldDelegate.borderWidth != borderWidth;
}
