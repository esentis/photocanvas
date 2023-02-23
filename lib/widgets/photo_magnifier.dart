import 'package:flutter/material.dart';
import 'package:photocanvas/constants.dart';

class PhotoMagnifier extends StatelessWidget {
  const PhotoMagnifier({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RawMagnifier(
      focalPointOffset: const Offset(-75, -75),
      decoration: const MagnifierDecoration(
        shape: CircleBorder(
          side: BorderSide(
            color: Colors.pink,
            width: 3,
          ),
        ),
      ),
      size: const Size(150, 150),
      magnificationScale: 3,
      child: Center(
        child: Text(
          'x',
          style: kStyle.copyWith(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
