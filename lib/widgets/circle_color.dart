import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photocanvas/constants.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class CircleColor extends StatefulWidget {
  const CircleColor({
    required this.color,
    Key? key,
  }) : super(key: key);

  final Color color;

  @override
  _CircleColorState createState() => _CircleColorState();
}

class _CircleColorState extends State<CircleColor> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(15.0.r),
      child: SizedBox(
        height: 100.r,
        width: 100.r,
        child: Column(
          children: [
            Text(
              kColorToHexString(widget.color),
              textAlign: TextAlign.center,
              style: kStyle.copyWith(
                color: Colors.white,
                fontSize: 25.sp,
              ),
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (pointer) {},
              onExit: (pointer) {},
              child: GestureDetector(
                onTap: () {
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
                },
                child: Container(
                  height: 60.h,
                  width: 60.h,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
