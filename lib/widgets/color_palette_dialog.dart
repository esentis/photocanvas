import 'package:clay_containers/widgets/clay_text.dart';
import 'package:flutter/material.dart';
import 'package:photocanvas/theme/app_theme.dart';
import 'package:photocanvas/widgets/circle_color.dart';

class ColorPaletteDialog extends StatelessWidget {
  const ColorPaletteDialog({
    required this.colors,
    required this.onColorSelected,
    super.key,
  });

  final List<Color> colors;
  final void Function(Color) onColorSelected;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: ClayText(
        'Generated color palette',
        style: AppTheme.titleMedium,
        color: AppTheme.text,
        parentColor: AppTheme.background,
        spread: AppTheme.defaultSpread,
        depth: AppTheme.defaultDepth.toInt(),
        textColor: AppTheme.text,
        emboss: true,
      ),
      backgroundColor: AppTheme.background,
      content: SizedBox(
        height: 450,
        width: 450,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
          ),
          itemCount: colors.length,
          itemBuilder: (context, index) {
            return CircleColor(
              color: colors[index],
              onTap: () {
                onColorSelected(colors[index]);
                Navigator.pop(context);
              },
            );
          },
        ),
      ),
    );
  }

  static Future<void> show({
    required BuildContext context,
    required List<Color> colors,
    required void Function(Color) onColorSelected,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return ColorPaletteDialog(
          colors: colors,
          onColorSelected: onColorSelected,
        );
      },
    );
  }
}
