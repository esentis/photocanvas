import 'package:clay_containers/clay_containers.dart';
import 'package:drop_zone/drop_zone.dart';
import 'package:flutter/material.dart';
import 'package:photocanvas/theme/app_theme.dart';

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

  @override
  Widget build(BuildContext context) {
    final isReady = containerText == 'Ready to drop';

    return DropZone(
      onDragEnter: onDragEnter,
      onDragExit: onDragExit,
      onDrop: onDrop,
      child: ClayAnimatedContainer(
        color: isReady ? AppTheme.success : AppTheme.background,
        surfaceColor: AppTheme.background,
        customBorderRadius: const BorderRadius.all(
          Radius.circular(26),
        ),
        duration: const Duration(milliseconds: 250),
        curveType: CurveType.concave,
        depth: (isReady ? AppTheme.mediumDepth : AppTheme.smallDepth).toInt(),
        height: 500,
        width: 500,
        curve: Curves.easeInOut,
        emboss: isReady,
        spread: 2,
        child: Center(
          child: ClayText(
            containerText,
            style: AppTheme.titleLarge.copyWith(fontSize: 50),
            color: AppTheme.text,
            parentColor: AppTheme.background,
            spread: AppTheme.defaultSpread,
            depth: AppTheme.defaultDepth.toInt(),
            textColor: AppTheme.text,
            emboss: true,
          ),
        ),
      ),
    );
  }
}
