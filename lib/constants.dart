import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';

Logger log = Logger();

Color kColorBackground = const Color(0xff1F1D36);
Color kColorInnerShadow = const Color(0xffEEEBDD).withOpacity(0.2);
Color kColorMain = const Color(0xff864879);
Color kColorSuccess = const Color(0xff66DE93);

TextStyle kStyle = TextStyle(
  fontFamily: 'Dongle',
  fontSize: 40.sp,
  height: 0.8,
);

String kColorToHexString(Color color) {
  return color.value.toRadixString(16).substring(2, 8);
}

Future<void> launchLink(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
