import 'package:flutter/material.dart';
import 'package:photocanvas/constants.dart';
import 'package:photocanvas/helper/utils.dart';

class PhotocanvasTitle extends StatelessWidget {
  const PhotocanvasTitle({
    required this.title,
    Key? key,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: GestureDetector(
        onTap: () => launchLink('https://www.github.com/esentis'),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Card(
            elevation: 5,
            color: const Color(0xff6C4AB6),
            shadowColor: const Color(0xff3C4048),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 13,
                horizontal: 25,
              ),
              child: Column(
                children: [
                  Text(
                    title,
                    style: kStyle.copyWith(
                      color: const Color(0xffF9F9F9),
                      fontSize: 40,
                    ),
                  ),
                  Text(
                    '${Utils.version}',
                    style: kStyle.copyWith(
                      fontSize: 16,
                      color: const Color(0xffF9F9F9),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
