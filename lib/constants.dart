import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';

Logger log = Logger();

///```dart
///Color(0xff1F1D36);
///```
Color kColorBackground = const Color(0xff1F1D36);

///```dart
///Color(0xffEEEBDD).withOpacity(0.2);
///```
Color kColorInnerShadow = const Color(0xffEEEBDD).withOpacity(0.2);

///```dart
///Color(0xff864879);
///```
Color kColorMain = const Color(0xff864879);

///```dart
///Color(0xff66DE93);
///```
Color kColorSuccess = const Color(0xff66DE93);

/// Default test style of the app
///
/// ```dart
/// fontFamily: 'Dongle',
/// fontSize: 30.sp,
/// height: 0.8,
/// ```
TextStyle kStyle = TextStyle(
  fontFamily: 'Dongle',
  fontSize: 30.sp,
  height: 0.8,
);

/// Returns the Hex code of the color.
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
