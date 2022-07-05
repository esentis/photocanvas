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
      child: Padding(
        padding: EdgeInsets.only(
          bottom: 5.h,
          top: 5.h,
        ),
        child: GestureDetector(
          onTap: () => launchLink('https://www.github.com/esentis'),
          child: Card(
            elevation: 5,
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: kStyle.copyWith(
                fontSize: 30.sp,
                color: kFooterTextColor,
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'esentis © ${DateTime.now().year.toString()}',
                  style: kStyle.copyWith(color: kColorBackground),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
