import 'dart:math';

import 'package:clay_containers/widgets/clay_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:photocanvas/constants.dart';
import 'package:photocanvas/helper/assets.dart';
import 'package:photocanvas/theme/app_theme.dart';
import 'package:photocanvas/widgets/title.dart';

class ComingSoon extends StatelessWidget {
  const ComingSoon({super.key});

  @override
  Widget build(BuildContext context) {
    final random = Random().nextInt(comingSoonMessages.length);
    kLog.f(random);
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        centerTitle: true,
        toolbarHeight: 100,
        shadowColor: AppTheme.background,
        elevation: 0,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            PhotocanvasTitle(title: 'Photocanvas'),
          ],
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: SvgPicture.asset(
                Assets.unavailable,
                height: 50,
                colorFilter: const ColorFilter.mode(
                  Colors.red,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: ClayText(
                comingSoonMessages[random],
                style: AppTheme.defaultStyle.copyWith(
                  fontSize: 35,
                ),
                color: AppTheme.text,
                parentColor: AppTheme.background,
                spread: 6,
                depth: 25,
                textColor: AppTheme.text,
                emboss: true,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: SvgPicture.asset(
                Assets.unavailable,
                height: 50,
                colorFilter: const ColorFilter.mode(
                  Colors.red,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
