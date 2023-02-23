import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:photocanvas/constants.dart';
import 'package:photocanvas/widgets/title.dart';

class ComingSoon extends StatelessWidget {
  const ComingSoon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final random = Random().nextInt(comingSoonMessages.length);
    kLog.wtf(random);
    return Scaffold(
      backgroundColor: const Color(0xff6C4AB6),
      appBar: AppBar(
        backgroundColor: const Color(0xff8D9EFF),
        centerTitle: true,
        toolbarHeight: 100,
        shadowColor: const Color(0xff3C4048),
        elevation: 5,
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
                'assets/unavailable.svg',
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
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: SvgPicture.asset(
                'assets/unavailable.svg',
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
