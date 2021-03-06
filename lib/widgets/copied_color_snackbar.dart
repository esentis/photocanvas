import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photocanvas/constants.dart';

class CopiedColorSnackbar extends StatelessWidget {
  const CopiedColorSnackbar({
    Key? key,
    required this.hoveredColor,
  }) : super(key: key);

  final Color? hoveredColor;

  @override
  Widget build(BuildContext context) {
    return Material(
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
            color: hoveredColor!.withOpacity(0.8),
            child: Center(
              child: Text(
                '${kColorToHexString(hoveredColor ?? Colors.white)}\ncopied to clipboard!',
                style: kStyle.copyWith(
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
