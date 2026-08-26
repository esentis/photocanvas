import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photocanvas/constants.dart';
import 'package:photocanvas/helper/ui_helper.dart';
import 'package:photocanvas/theme/app_theme.dart';

/// Tappable color swatch with its hex code.
///
/// Tapping copies the hex value to the clipboard and shows the copy
/// snackbar; [onTap] runs afterwards (the palette dialog uses it to
/// propagate the selection). [cancelTap] renders the swatch read-only.
class CircleColor extends StatefulWidget {
  const CircleColor({
    required this.color,
    this.onTap,
    this.height,
    this.width,
    this.cancelTap = false,
    this.showText = true,
    this.textColor,
    super.key,
  });

  final Color color;

  /// Label text color override.
  final Color? textColor;
  final double? width;
  final double? height;
  final VoidCallback? onTap;

  /// Disables the tap-to-copy interaction.
  final bool cancelTap;
  final bool showText;

  @override
  State<CircleColor> createState() => CircleColorState();
}

class CircleColorState extends State<CircleColor> {
  bool _hovered = false;

  bool get _tappable => !widget.cancelTap && widget.onTap != null;

  Future<void> _handleTap() async {
    ScaffoldMessenger.of(context).clearSnackBars();
    await Clipboard.setData(
      ClipboardData(text: kColorToHexString(widget.color)),
    );
    if (mounted) {
      UiHelper.showCopySnackBar(context, widget.color);
    }
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: _tappable ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: _tappable ? _handleTap : null,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.space1),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.showText)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    kColorToHexString(widget.color),
                    style: AppTheme.mono.copyWith(
                      color: widget.textColor ?? AppTheme.textSecondary,
                    ),
                  ),
                ),
              AnimatedScale(
                scale: _hovered ? 1.08 : 1,
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOut,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: widget.width ?? 52,
                      height: widget.height ?? 52,
                      foregroundDecoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        border: Border.all(color: AppTheme.strokeStrong),
                        // Top highlight for a glassy finish.
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.center,
                          colors: [
                            Colors.white.withValues(alpha: 0.22),
                            Colors.white.withValues(alpha: 0),
                          ],
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: widget.color,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        boxShadow: [
                          BoxShadow(
                            color: widget.color.withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                    if (_hovered && _tappable)
                      Icon(
                        Icons.content_copy_rounded,
                        size: 18,
                        color: kIconColorOn(widget.color),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Picks black or white iconography so it stays readable on any swatch.
Color kIconColorOn(Color background) =>
    background.computeLuminance() > 0.4 ? Colors.black87 : Colors.white;
