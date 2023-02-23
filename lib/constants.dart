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

List<String> comingSoonMessages = [
  "Oops, looks like Photocanvas isn't quite in focus on mobile and tablet yet! But don't worry, we're developing a zoom-worthy mobile-friendly experience.\n\nSoon, you'll be able to analyze image colors and grab their hex codes on-the-go, all thanks to Photocanvas! Until then, visit us on desktop and we'll try not to blur your experience.",
  "Sorry, Photocanvas hasn't mastered the art of mobile and tablet just yet. But we're on it like a paintbrush on canvas!\n\nSoon, you'll be able to analyze image colors and get their hex codes on-the-go, thanks to Photocanvas! In the meantime, visit us on desktop and we'll try to keep our puns as subtle as a watercolor.",
  "Oops, Photocanvas isn't quite picture-perfect on mobile and tablet yet. But rest assured, we're cropping out all the imperfections and working on a mobile-friendly experience.\n\nSoon, you'll be able to analyze image colors and grab their hex codes on-the-go, all thanks to Photocanvas! In the meantime, visit us on desktop and we'll try to keep things as crisp as a high-resolution image.",
  "Uh-oh, it looks like Photocanvas hasn't quite found its mobile and tablet filter yet! But don't worry, we're developing a fully adjustable mobile-friendly experience.\n\nSoon, you'll be able to analyze image colors and grab their hex codes on-the-go, all thanks to Photocanvas! In the meantime, visit us on desktop and we'll try to keep things as bright and vibrant as our favorite filter.",
  "Whoops, it looks like Photocanvas needs a little more development to look picture-perfect on mobile and tablet! But don't worry, we're painting a masterpiece of mobile-friendly functionality.\n\nSoon, you'll be able to analyze image colors and grab their hex codes on-the-go, all thanks to Photocanvas! Until then, visit us on desktop and we'll try to keep our art puns to a minimum.",
  "Uh-oh, it looks like Photocanvas hasn't quite mastered the art of mobile and tablet yet! But fear not, we're busy painting a masterpiece of mobile-friendliness.\n\nSoon, you'll be able to analyze image colors and grab their hex codes on-the-go, all thanks to Photocanvas! In the meantime, visit us on desktop and we'll try not to make too many canvas puns!",
  "Whoopsie-doodle, looks like Photocanvas needs a little touch-up to look stunning on mobile and tablet! But fear not, we're working hard to create a masterpiece of mobile-friendliness.\n\nSoon, you'll be able to analyze image colors and grab their hex codes on-the-go, all thanks to Photocanvas! For now, visit us on desktop and we'll try not to smudge your experience.",
  "Oopsie-daisy, Photocanvas needs a little more sunshine to shine on mobile and tablet! But don't worry, we're adding more brightness to create a dazzling mobile-friendly experience.\n\nSoon, you'll be able to analyze image colors and grab their hex codes on-the-go, all thanks to Photocanvas! In the meantime, visit us on desktop and we'll try to keep our flower puns to a minimum.",
  "Uh-oh, it looks like Photocanvas is still working on its mobile and tablet selfie game! But we promise, we're putting in the work to create a flawless mobile-friendly experience.\n\nSoon, you'll be able to analyze image colors and grab their hex codes on-the-go, all thanks to Photocanvas! For now, visit us on desktop and we'll try to keep our puns as filter-free as possible.",
  "Sorry, it looks like Photocanvas needs a little more practice to perfect its mobile and tablet moves! But we're dancing our way to a mobile-friendly masterpiece.\n\nSoon, you'll be able to analyze image colors and grab their hex codes on-the-go, all thanks to Photocanvas! In the meantime, visit us on desktop and we'll try to keep our rhythm as smooth as a brush stroke.",
  "Whoa, it looks like Photocanvas needs to put in a little more effort to get a standing ovation on mobile and tablet! But don't worry, we're rehearsing hard to create an award-winning mobile-friendly experience.\n\nSoon, you'll be able to analyze image colors and grab their hex codes on-the-go, all thanks to Photocanvas! Until then, visit us on desktop and we'll try to keep our acting skills as professional as a still life painting.",
];
