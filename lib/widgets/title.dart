import 'package:flutter/material.dart';
import 'package:photocanvas/constants.dart';
import 'package:photocanvas/helper/utils.dart';

class PhotocanvasTitle extends StatelessWidget {
  const PhotocanvasTitle({
    Key? key,
    required this.title,
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
            shadowColor: kColorBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
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
                      color: kColorBackground,
                      fontSize: 40,
                    ),
                  ),
                  Text(
                    '${Utils.version}',
                    style: kStyle.copyWith(
                      fontSize: 16,
                      color: kColorBackground,
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
