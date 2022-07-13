import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photocanvas/constants.dart';

class PhotocanvasTitle extends StatelessWidget {
  const PhotocanvasTitle({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: GestureDetector(
        onTap: () => launchLink('https://www.github.com/esentis'),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Card(
            elevation: 5,
            shadowColor: kColorBackground,
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: 13.0.h,
                horizontal: 25.w,
              ),
              child: Column(
                children: [
                  Text(
                    title,
                    style: kStyle.copyWith(
                      color: kColorBackground,
                    ),
                  ),
                  Text(
                    '1.1.0',
                    style: kStyle.copyWith(
                      fontSize: 16.sp,
                      color: kColorBackground,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
