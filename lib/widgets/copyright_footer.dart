import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photocanvas/constants.dart';

class CopyrightFooter extends StatefulWidget {
  const CopyrightFooter({Key? key}) : super(key: key);

  @override
  _CopyrightFooterState createState() => _CopyrightFooterState();
}

class _CopyrightFooterState extends State<CopyrightFooter> {
  Color kFooterTextColor = Colors.white;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (p) {
        setState(() {
          kFooterTextColor = kColorMain;
        });
      },
      onExit: (p) {
        setState(() {
          kFooterTextColor = Colors.white;
        });
      },
      child: GestureDetector(
        onTap: () => launchLink('https://www.github.com/esentis'),
        child: Container(
          height: 35.h,
          width: 200.w,
          color: kColorBackground,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: kStyle.copyWith(
                  fontSize: 30.sp,
                  color: kFooterTextColor,
                ),
                child: Text('esentis © ${DateTime.now().year.toString()}'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
