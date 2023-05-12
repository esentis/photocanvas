// ignore_for_file: unawaited_futures, use_build_context_synchronously, cascade_invocations, cast_nullable_to_non_nullable

import 'dart:html' as html;
import 'dart:ui';

import 'package:drop_zone/drop_zone.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image/image.dart' as img;
import 'package:image_pixels/image_pixels.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:photocanvas/constants.dart';
import 'package:photocanvas/helper/assets.dart';
import 'package:photocanvas/widgets/check_color.dart';
import 'package:photocanvas/widgets/circle_color.dart';
import 'package:photocanvas/widgets/photo_magnifier.dart';
import 'package:photocanvas/widgets/title.dart';

class HomePageDesktop extends StatefulWidget {
  const HomePageDesktop({
    required this.title,
    super.key,
  });
  final String title;
  @override
  State<HomePageDesktop> createState() => _HomePageDesktopState();
}

class _HomePageDesktopState extends State<HomePageDesktop>
    with TickerProviderStateMixin {
  Color containerColor = Colors.white;
  String containerText = 'Drop your image here';
  String focusedColorHex = '';
  PaletteGenerator? paletteGenerator;
  List<Color> activeColors = [];
  Uint8List? imageData;

  bool showOverlay = false;
  bool hovering = false;
  bool pinnedDetailedColors = false;

  int? dx;
  int? dy;

  Color? hoveredColor;

  Color? copiedColor;

  late final AnimationController _controller;

  double? localDx;
  double? localDy;

  bool isValidImage(String fileName) {
    return fileName.toLowerCase().endsWith('jpg') ||
        fileName.toLowerCase().endsWith('jpeg') ||
        fileName.toLowerCase().endsWith('png') ||
        fileName.toLowerCase().endsWith('gif') ||
        fileName.toLowerCase().endsWith('webp') ||
        fileName.toLowerCase().endsWith('avif');
  }

  Future<void> loadImage(html.File file) async {
    if (isValidImage(file.name)) {
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);

      await reader.onLoad.first;
      imageData = reader.result as Uint8List;

      final image = img.decodeImage(imageData as Uint8List);

      if (image != null) {
        // ignore: omit_local_variable_types
        final img.Image resized = img.copyResize(
          image,
          //  width: 400,
          height: 310,
        );
        imageData = img.encodeJpg(resized);
      }
      setState(() {});
      Navigator.pop(context);
    } else {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 7,
                sigmaY: 7,
              ),
              child: Container(
                height: 80,
                color: Colors.red,
                child: Center(
                  child: Text(
                    'File is not a valid image format\n(JPG, JPEG, PNG, GIF, WEBP)',
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
    }
  }

  Future<void> onDrop(List<html.File> files) async {
    copiedColor = null;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 3,
                sigmaY: 3,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Analyzing your image',
                    textAlign: TextAlign.center,
                    style: kStyle.copyWith(
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    await Future.delayed(const Duration(milliseconds: 250), () {});

    final file = files[0];
    try {
      await compute(loadImage, file);
    } catch (e) {
      kLog.e(e);
    }

    if (imageData != null) {
      paletteGenerator = await PaletteGenerator.fromImageProvider(
        Image.memory(imageData!).image,
        maximumColorCount: 200,
      );
      activeColors = paletteGenerator!.colors.toList();
    }

    setState(() {
      containerColor = Colors.white;
      containerText = 'Drop your image here';
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColorBackground,
      appBar: AppBar(
        backgroundColor: kColorBackground,
        centerTitle: true,
        toolbarHeight: 100,
        shadowColor: const Color(0xff3C4048),
        elevation: 0,
        actions: [
          if (imageData != null)
            GestureDetector(
              onTap: () {
                showDialog<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Image's color palette"),
                      content: SizedBox(
                        height: 450,
                        width: 450,
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                          ),
                          itemCount: activeColors.length,
                          itemBuilder: (context, index) {
                            return CircleColor(
                              color: activeColors[index],
                              onTap: () {
                                setState(() {
                                  copiedColor = activeColors[index];
                                });
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: SvgPicture.asset(
                  Assets.palette,
                  height: 40,
                  width: 40,
                ),
              ),
            ),
          if (imageData != null)
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 5),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    imageData = null;
                  });
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: SvgPicture.asset(
                    Assets.reset,
                    height: 40,
                    width: 40,
                    colorFilter: const ColorFilter.mode(
                      Colors.red,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
        ],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            PhotocanvasTitle(title: widget.title),
          ],
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (imageData == null)
            const SizedBox(
              height: 20,
            ),
          if (imageData == null) const CheckColor(),
          if (imageData == null)
            DropZone(
              onDragEnter: () {
                setState(() {
                  containerColor = kColorSuccess;
                  containerText = 'Ready to drop';
                });
              },
              onDragExit: () {
                setState(() {
                  containerColor = Colors.white;
                  containerText = 'Drop your image here';
                });
              },
              onDrop: (List<html.File>? files) async {
                if (files != null) {
                  await onDrop(files);
                }
              },
              child: Card(
                color: containerText == 'Ready to drop'
                    ? kColorSuccess
                    : kColorBackground,
                shadowColor: kColorText,
                elevation: 45,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SizedBox(
                  width: 600,
                  height: 500,
                  child: Center(
                    child: Text(
                      containerText,
                      style: kStyle.copyWith(
                        fontSize: 50,
                        color: kColorText,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (imageData != null)
            // Hovered color, dominant color, copied color
            Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Stack(
                children: [
                  ImagePixels(
                    imageProvider: Image.memory(
                      imageData!,
                    ).image,
                    builder: (_, img) {
                      hoveredColor = img.pixelColorAt!(
                        dx ?? 0,
                        dy ?? 0,
                      );
                      return const SizedBox();
                    },
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Text(
                            'Dominant color',
                            style: kStyle.copyWith(
                              color: kColorText,
                            ),
                          ),
                          if (paletteGenerator != null)
                            if (paletteGenerator!.dominantColor != null)
                              CircleColor(
                                color: paletteGenerator!.dominantColor!.color,
                              ),
                        ],
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      if (copiedColor != null)
                        Column(
                          children: [
                            Text(
                              'Copied color',
                              style: kStyle.copyWith(
                                color: kColorText,
                              ),
                            ),
                            CircleColor(
                              color: copiedColor!,
                              cancelTap: true,
                            )
                          ],
                        ),
                      const SizedBox(
                        width: 20,
                      ),
                      if (hoveredColor != null && hovering)
                        Column(
                          children: [
                            Text(
                              'Hovered color',
                              style: kStyle.copyWith(
                                color: kColorText,
                              ),
                            ),
                            CircleColor(
                              color: hoveredColor!,
                              cancelTap: true,
                            )
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          // Image preview container
          if (imageData != null)
            Center(
              child: DropZone(
                onDragEnter: () {
                  kLog.i('Entering image');
                },
                onDragExit: () {
                  kLog.i('Exiting image');
                },
                onDrop: (files) async {
                  if (files != null) {
                    await onDrop(files);
                  }
                },
                child: Card(
                  shadowColor: kColorText,
                  elevation: 45,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Listener(
                        onPointerHover: (pointer) {
                          setState(() {
                            localDx = pointer.localPosition.dx;
                            localDy = pointer.localPosition.dy;
                            dx = pointer.localPosition.dx.toInt();
                            dy = pointer.localPosition.dy.toInt();
                          });
                        },
                        onPointerDown: (pointer) {
                          ScaffoldMessenger.of(context).clearSnackBars();
                          Clipboard.setData(
                            ClipboardData(
                              text: kColorToHexString(
                                hoveredColor ?? Colors.white,
                              ),
                            ),
                          );
                          copiedColor = hoveredColor;
                          if (copiedColor != null) {
                            kShowCopySnackBar(context, copiedColor!);
                          }
                          setState(() {});
                        },
                        child: MouseRegion(
                          cursor: SystemMouseCursors.precise,
                          onExit: (e) {
                            hovering = false;
                            hoveredColor = null;

                            setState(() {});
                          },
                          onEnter: (e) {
                            hovering = true;

                            setState(() {});
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.memory(imageData!),
                          ),
                        ),
                      ),
                      if (hoveredColor != null && hovering)
                        Positioned(
                          left: localDx,
                          top: localDy,
                          child: const PhotoMagnifier(),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}
