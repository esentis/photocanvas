import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photocanvas/constants.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class CircleColor extends StatefulWidget {
  const CircleColor({
    required this.color,
    required this.onHover,
    required this.onExit,
    Key? key,
  }) : super(key: key);

  final Color color;
  final VoidCallback onHover;
  final VoidCallback onExit;

  @override
  _CircleColorState createState() => _CircleColorState();
}

class _CircleColorState extends State<CircleColor> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: SizedBox(
        height: 80,
        width: 100,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: 0,
              left: 10,
              right: 10,
              child: Text(
                kColorToHexString(widget.color),
                textAlign: TextAlign.center,
                style: kStyle.copyWith(
                  color: Colors.white,
                  fontSize: 25,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 10,
              right: 10,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                onEnter: (pointer) {
                  log.wtf('hovering over color ${widget.color}');
                  widget.onHover();
                },
                onExit: (pointer) {
                  widget.onExit();
                },
                child: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    Clipboard.setData(
                      ClipboardData(text: kColorToHexString(widget.color)),
                    );
                    showTopSnackBar(
                      context,
                      Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: 7,
                              sigmaY: 7,
                            ),
                            child: Container(
                              height: 80,
                              decoration: BoxDecoration(
                                color: widget.color.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  '${kColorToHexString(widget.color)}\ncopied to clipboard!',
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
                  },
                  child: Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      color: widget.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
