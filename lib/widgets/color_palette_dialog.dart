import 'package:flutter/material.dart';
import 'package:photocanvas/theme/app_theme.dart';
import 'package:photocanvas/widgets/circle_color.dart';

/// Full extracted palette. Clicking a swatch copies its hex value,
/// notifies [onColorSelected] and closes the dialog.
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
    return Dialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        side: const BorderSide(color: AppTheme.stroke),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.space6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: AppTheme.brandGradient,
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusSm + 2),
                    ),
                    child: const Icon(
                      Icons.palette_outlined,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: AppTheme.space3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Generated color palette',
                          style: AppTheme.titleMedium.copyWith(fontSize: 18),
                        ),
                        Text(
                          '${colors.length} colors extracted · click one to copy',
                          style: AppTheme.bodySmall
                              .copyWith(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  _CloseButton(onTap: Navigator.of(context).pop),
                ],
              ),
              const SizedBox(height: AppTheme.space4),
              Flexible(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth < 420 ? 4 : 5;
                    return GridView.builder(
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: 0.92,
                      ),
                      itemCount: colors.length,
                      itemBuilder: (context, index) => Center(
                        child: CircleColor(
                          color: colors[index],
                          onTap: () {
                            onColorSelected(colors[index]);
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
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

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            border: Border.all(color: AppTheme.strokeStrong),
            color: AppTheme.surfaceAlt,
          ),
          child: const Icon(
            Icons.close_rounded,
            size: 17,
            color: AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}
