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
            elevation: 15,
            color: kColorBackground,
            shadowColor: kColorText,
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
                      color: kColorText,
                      fontSize: 40,
                    ),
                  ),
                  Text(
                    '${Utils.version}',
                    style: kStyle.copyWith(
                      fontSize: 18,
                      color: kColorText,
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
