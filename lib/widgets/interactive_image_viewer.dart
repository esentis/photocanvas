import 'dart:html' as html;

import 'package:clay_containers/clay_containers.dart';
import 'package:drop_zone/drop_zone.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:photocanvas/constants.dart';
import 'package:photocanvas/theme/app_theme.dart';
import 'package:photocanvas/widgets/photo_magnifier.dart';

class InteractiveImageViewer extends StatelessWidget {
  const InteractiveImageViewer({
    required this.imageData,
    required this.onDrop,
    required this.onPointerHover,
    required this.onPointerDown,
    required this.onMouseExit,
    required this.pointerLocalPos,
    required this.onClearImage,
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: DropZone(
            onDragEnter: () => kLog.i('Entering image'),
            onDragExit: () => kLog.i('Exiting image'),
            onDrop: onDrop,
            child: Card(
              shadowColor: AppTheme.text,
              elevation: 45,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Listener(
                    onPointerHover: onPointerHover,
                    onPointerDown: onPointerDown,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.precise,
                      onExit: (_) => onMouseExit(),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.memory(imageData),
                      ),
                    ),
                  ),
                  ValueListenableBuilder<Offset?>(
                    valueListenable: pointerLocalPos,
                    builder: (context, position, _) {
                      if (position == null) return const SizedBox.shrink();
                      return Positioned(
                        left: position.dx,
                        top: position.dy,
                        child: const PhotoMagnifier(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        _ClearImageButton(onTap: onClearImage),
      ],
    );
  }
}

class _ClearImageButton extends StatelessWidget {
  const _ClearImageButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClayText(
        'Clear image',
        style: AppTheme.bodyMedium.copyWith(
          decoration: TextDecoration.underline,
          decorationColor: AppTheme.error,
        ),
        color: AppTheme.text,
        parentColor: AppTheme.background,
        spread: 2,
        depth: 2,
        textColor: AppTheme.error,
        emboss: true,
      ),
    );
  }
}
