import 'dart:html' as html;

import 'package:clay_containers/clay_containers.dart';
import 'package:drop_zone/drop_zone.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_pixels/image_pixels.dart';
import 'package:photocanvas/constants.dart';
import 'package:photocanvas/theme/app_theme.dart';
import 'package:photocanvas/widgets/photo_magnifier.dart';

class InteractiveImageViewer extends StatelessWidget {
  const InteractiveImageViewer({
    required this.imageData,
    required this.onDrop,
    required this.onPointerHover,
    required this.onPointerDown,
    required this.onMouseEnter,
    required this.onMouseExit,
    required this.dx,
    required this.dy,
    required this.localDx,
    required this.localDy,
    required this.hoveredColor,
    required this.hovering,
    required this.onClearImage,
    super.key,
  });

  final Uint8List imageData;
  final void Function(List<html.File>?) onDrop;
  final void Function(PointerHoverEvent) onPointerHover;
  final void Function(PointerDownEvent) onPointerDown;
  final VoidCallback onMouseEnter;
  final VoidCallback onMouseExit;
  final int? dx;
  final int? dy;
  final double? localDx;
  final double? localDy;
  final Color? hoveredColor;
  final bool hovering;
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
                  _ImagePixelDetector(
                    imageData: imageData,
                    dx: dx,
                    dy: dy,
                  ),
                  Listener(
                    onPointerHover: onPointerHover,
                    onPointerDown: onPointerDown,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.precise,
                      onExit: (_) => onMouseExit(),
                      onEnter: (_) => onMouseEnter(),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.memory(imageData),
                      ),
                    ),
                  ),
                  if (hoveredColor != null && hovering)
                    Positioned(
                      left: localDx,
                      top: localDy,
                      child: const PhotoMagnifier(),
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

class _ImagePixelDetector extends StatelessWidget {
  const _ImagePixelDetector({
    required this.imageData,
    required this.dx,
    required this.dy,
  });

  final Uint8List imageData;
  final int? dx;
  final int? dy;

  @override
  Widget build(BuildContext context) {
    return ImagePixels(
      imageProvider: Image.memory(imageData).image,
      builder: (_, img) {
        // This triggers color detection for the hovered pixel
        img.pixelColorAt!(dx ?? 0, dy ?? 0);
        return const SizedBox();
      },
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
