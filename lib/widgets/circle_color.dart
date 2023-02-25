import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photocanvas/constants.dart';

class CircleColor extends StatefulWidget {
  const CircleColor({
    required this.color,
    this.onTap,
    this.height,
    this.width,
    this.cancelTap = false,
    this.showText = true,
    this.textColor,
    Key? key,
  }) : super(key: key);

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
            : () {
                ScaffoldMessenger.of(context).clearSnackBars();
                Clipboard.setData(
                  ClipboardData(text: kColorToHexString(widget.color)),
                );

                kShowCopySnackBar(context, widget.color);
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
                  style: kStyle.copyWith(
                    fontSize: 25,
                    color: kColorText,
                  ),
                ),
              Container(
                height: widget.height ?? 50,
                width: widget.width ?? 50,
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                  border: Border.all(color: kColorAppBar.withOpacity(0.6)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
