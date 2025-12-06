import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:photocanvas/constants.dart';
import 'package:photocanvas/helper/assets.dart';
import 'package:photocanvas/helper/ui_helper.dart';
import 'package:photocanvas/theme/app_theme.dart';

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
  final Color? textColor;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final bool cancelTap;
  final bool showText;
  @override
  CircleColorState createState() => CircleColorState();
}

class CircleColorState extends State<CircleColor> {
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (pointer) {},
      onExit: (pointer) {},
      child: GestureDetector(
        onTap: widget.cancelTap
            ? null
            : () async {
                ScaffoldMessenger.of(context).clearSnackBars();
                await Clipboard.setData(
                  ClipboardData(text: kColorToHexString(widget.color)),
                );
                if (context.mounted) {
                  UiHelper.showCopySnackBar(context, widget.color);
                }
                widget.onTap?.call();
              },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              if (widget.showText)
                Text(
                  kColorToHexString(
                    widget.color,
                  ),
                  style: AppTheme.defaultStyle.copyWith(
                    fontSize: 25,
                    color: AppTheme.text,
                  ),
                ),
              SvgPicture.asset(
                Assets.brush,
                height: widget.height ?? 50,
                width: widget.width ?? 50,
                colorFilter: ColorFilter.mode(
                  widget.color,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
