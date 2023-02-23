// ignore_for_file: only_throw_errors

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';

Logger kLog = Logger();

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
TextStyle kStyle = const TextStyle(
  fontFamily: 'Dongle',
  fontSize: 30,
  height: 0.8,
);

/// Returns the Hex code of the color.
String kColorToHexString(Color color) {
  return color.value.toRadixString(16).substring(2, 8);
}

Future<void> launchLink(String url) async {
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url));
  } else {
    throw 'Could not launch $url';
  }
}

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> kShowCopySnackBar(
  BuildContext context,
  Color color,
) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: color,
      content: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 7,
            sigmaY: 7,
          ),
          child: ColoredBox(
            color: color.withOpacity(0.8),
            child: Center(
              child: Text(
                '${kColorToHexString(color)}\ncopied to clipboard!',
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
}
