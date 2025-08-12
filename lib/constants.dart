// Too strict
// ignore_for_file: only_throw_errors

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:photocanvas/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

Logger kLog = Logger();

// Legacy color constants - use AppTheme instead
@Deprecated('Use AppTheme.appBar instead')
Color kColorAppBar = AppTheme.appBar;

@Deprecated('Use AppTheme.background instead')
Color kColorBackground = AppTheme.background;

@Deprecated('Use AppTheme.text instead')
Color kColorText = AppTheme.text;

@Deprecated('Use AppTheme.textFieldBorder instead')
Color kColorTextFieldBorder = AppTheme.textFieldBorder;

@Deprecated('Use AppTheme.success instead')
Color kColorSuccess = AppTheme.success;

@Deprecated('Use AppTheme.defaultStyle instead')
TextStyle kStyle = AppTheme.defaultStyle;

// /// Returns the Hex code of the color.
// String kColorToHexString(Color color) {
//   return color.value.toRadixString(16).substring(2, 8);
// }

String kColorToHexString(Color color, {bool leadingHashSign = false}) {
  final alpha = (color.a * 255).round();
  final red = (color.r * 255).round();
  final green = (color.g * 255).round();
  final blue = (color.b * 255).round();

  return '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

String kGithubLink = 'https://www.github.com/esentis';

Future<void> launchLink(String url) async {
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url));
  } else {
    throw 'Could not launch $url';
  }
}

@Deprecated('Use UiHelper.showCopySnackBar instead')
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
            color: color.withValues(alpha: 0.8),
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
  "Whoops, it looks like Photocanvas needs a little more development to look picture-perfect on mobile and tablet! But don't worry, we're painting a masterpiece of mobile-friendly functionality.\n\nSoon, you'll be able to analyze image colors and grab their hex codes on-the-go, all thanks to Photocanvas! In the meantime, visit us on desktop and we'll try to keep things as bright and vibrant as our favorite filter.",
  "Uh-oh, it looks like Photocanvas hasn't quite found its mobile and tablet filter yet! But don't worry, we're developing a fully adjustable mobile-friendly experience.\n\nSoon, you'll be able to analyze image colors and grab their hex codes on-the-go, all thanks to Photocanvas! In the meantime, visit us on desktop and we'll try to keep things as crisp as a high-resolution image.",
];
const List<String> validImageFormats = [
  'jpg',
  'jpeg',
  'png',
  'gif',
  'webp',
  'avif',
];
