import 'package:clay_containers/widgets/clay_text.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:photocanvas/theme/app_theme.dart';
import 'package:photocanvas/widgets/circle_color.dart';

class ColorInfoSection extends StatelessWidget {
  const ColorInfoSection({
    required this.paletteGenerator,
    required this.hoveredColor,
    required this.copiedColor,
    required this.hovering,
    super.key,
  });

  final PaletteGenerator? paletteGenerator;
  final Color? hoveredColor;
  final Color? copiedColor;
  final bool hovering;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 50),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _DominantColorSection(paletteGenerator: paletteGenerator),
          const SizedBox(width: 20),
          if (copiedColor != null) _CopiedColorSection(color: copiedColor!),
          const SizedBox(width: 20),
          if (hoveredColor != null && hovering)
            _HoveredColorSection(color: hoveredColor!),
        ],
      ),
    );
  }
}

class _DominantColorSection extends StatelessWidget {
  const _DominantColorSection({required this.paletteGenerator});

  final PaletteGenerator? paletteGenerator;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClayText(
          'Dominant color',
          style: AppTheme.bodyMedium,
          color: AppTheme.text,
          parentColor: AppTheme.background,
          spread: AppTheme.defaultSpread,
          depth: AppTheme.defaultDepth.toInt(),
          textColor: AppTheme.text,
          emboss: true,
        ),
        if (paletteGenerator?.dominantColor?.color != null)
          CircleColor(
            color: paletteGenerator!.dominantColor!.color,
          ),
      ],
    );
  }
}

class _CopiedColorSection extends StatelessWidget {
  const _CopiedColorSection({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClayText(
          'Copied color',
          style: AppTheme.bodyMedium,
          color: AppTheme.text,
          parentColor: AppTheme.background,
          spread: AppTheme.defaultSpread,
          depth: AppTheme.defaultDepth.toInt(),
          textColor: AppTheme.text,
          emboss: true,
        ),
        CircleColor(
          color: color,
          cancelTap: true,
        ),
      ],
    );
  }
}

class _HoveredColorSection extends StatelessWidget {
  const _HoveredColorSection({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClayText(
          'Hovered color',
          style: AppTheme.bodyMedium,
          color: AppTheme.text,
          parentColor: AppTheme.background,
          spread: AppTheme.defaultSpread,
          depth: AppTheme.defaultDepth.toInt(),
          textColor: AppTheme.text,
          emboss: true,
        ),
        CircleColor(
          color: color,
          cancelTap: true,
        ),
      ],
    );
  }
}
