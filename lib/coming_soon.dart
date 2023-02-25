import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:photocanvas/constants.dart';
import 'package:photocanvas/helper/assets.dart';
import 'package:photocanvas/widgets/title.dart';

class ComingSoon extends StatelessWidget {
  const ComingSoon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final random = Random().nextInt(comingSoonMessages.length);
    kLog.wtf(random);
    return Scaffold(
      backgroundColor: kColorBackground,
      appBar: AppBar(
        backgroundColor: kColorBackground,
        centerTitle: true,
        toolbarHeight: 100,
        shadowColor: kColorBackground,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: const [
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
              child: Text(
                comingSoonMessages[random],
                textAlign: TextAlign.center,
                style: kStyle.copyWith(
                  fontSize: 33,
                  fontWeight: FontWeight.bold,
                  color: kColorText,
                ),
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
