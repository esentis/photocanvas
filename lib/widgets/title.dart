import 'package:clay_containers/constants.dart';
import 'package:clay_containers/widgets/clay_container.dart';
import 'package:clay_containers/widgets/clay_text.dart';
import 'package:flutter/material.dart';
import 'package:photocanvas/constants.dart';
import 'package:photocanvas/helper/utils.dart';

class PhotocanvasTitle extends StatelessWidget {
  const PhotocanvasTitle({
    required this.title,
    super.key,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: GestureDetector(
        onTap: () => launchLink(kGithubLink),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: ClayContainer(
            color: kColorBackground,
            borderRadius: 50,
            curveType: CurveType.concave,
            depth: 5,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 13,
                horizontal: 25,
              ),
              child: Column(
                children: [
                  ClayText(
                    title,
                    style: kStyle.copyWith(
                      fontSize: 40,
                    ),
                    color: kColorText,
                    parentColor: kColorBackground,
                    spread: 6,
                    depth: 25,
                    textColor: kColorText,
                    emboss: true,
                  ),
                  ClayText(
                    '${Utils.version}',
                    style: kStyle.copyWith(
                      fontSize: 18,
                    ),
                    color: kColorText,
                    parentColor: kColorBackground,
                    spread: 6,
                    depth: 25,
                    textColor: kColorText,
                    emboss: true,
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
