import 'package:flutter/material.dart';
import 'package:photocanvas/theme/app_theme.dart';

class PhotoMagnifier extends StatelessWidget {
  const PhotoMagnifier({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return RawMagnifier(
      focalPointOffset: const Offset(-75, -75),
      decoration: const MagnifierDecoration(
        shape: CircleBorder(
          side: BorderSide(
            color: AppTheme.appBar,
            width: 4,
          ),
        ),
      ),
      size: const Size(150, 150),
      magnificationScale: 3,
      child: Center(
        child: Text(
          '+',
          style: AppTheme.defaultStyle.copyWith(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
