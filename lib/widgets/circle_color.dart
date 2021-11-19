import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photocanvas/constants.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class CircleColor extends StatefulWidget {
  const CircleColor({
    required this.color,
    this.onTap,
    this.height,
    this.width,
    this.cancelTap = false,
    Key? key,
  }) : super(key: key);

  final Color color;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final bool cancelTap;
  @override
  _CircleColorState createState() => _CircleColorState();
}

class _CircleColorState extends State<CircleColor> {
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
                showTopSnackBar(
                  context,
                  Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12.r),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 7.r,
                          sigmaY: 7.r,
                        ),
                        child: Container(
                          height: 80.h,
                          color: widget.color.withOpacity(0.8),
                          child: Center(
                            child: Text(
                              '${kColorToHexString(widget.color)}\ncopied to clipboard!',
                              style: kStyle.copyWith(
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
                widget.onTap?.call();
              },
        child: Padding(
          padding: EdgeInsets.all(8.0.r),
          child: Column(
            children: [
              Text(
                kColorToHexString(
                  widget.color,
                ),
                style: kStyle.copyWith(
                  fontSize: 25.sp,
                  color: Colors.white,
                ),
              ),
              Container(
                height: widget.height ?? 50.r,
                width: widget.width ?? 50.r,
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
