// ignore_for_file: unawaited_futures, use_build_context_synchronously, cascade_invocations, cast_nullable_to_non_nullable

import 'dart:html' as html;
import 'dart:ui';

import 'package:drop_zone/drop_zone.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image/image.dart' as img;
import 'package:image_pixels/image_pixels.dart';
import 'package:lottie/lottie.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:photocanvas/constants.dart';
import 'package:photocanvas/widgets/circle_color.dart';
import 'package:photocanvas/widgets/copied_color_snackbar.dart';
import 'package:photocanvas/widgets/title.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
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

  final ScrollController _scrollController = ScrollController();

  late final AnimationController _controller;

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
        imageData = img.encodeJpg(resized) as Uint8List;
      }
      setState(() {});
      Navigator.pop(context);
    } else {
      Navigator.pop(context);
      showTopSnackBar(
        context,
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 7.r,
                sigmaY: 7.r,
              ),
              child: Container(
                height: 80.h,
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
          borderRadius: BorderRadius.circular(12.r),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 3,
                sigmaY: 3,
              ),
              child: Container(
                width: 150.r,
                height: 150.r,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Lottie.asset('assets/cogs.json'),
                    ),
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
      backgroundColor: const Color(0xffF3F1F5),
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 100.h,
        shadowColor: kColorBackground,
        elevation: 5,
        actions: [
          if (imageData != null)
            GestureDetector(
              onTap: () {
                setState(() {
                  imageData = null;
                });
              },
              child: Padding(
                padding: EdgeInsets.only(right: 20.0.w),
                child: Lottie.asset(
                  'assets/reset.json',
                  width: 35.w,
                ),
              ),
            ),
        ],
        backgroundColor: Colors.white,
        title: Stack(
          children: [
            if (imageData != null)
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
            PhotocanvasTitle(title: widget.title),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              height: 20.h,
            ),
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
                  color: containerColor,
                  shadowColor: containerText == 'Ready to drop'
                      ? kColorSuccess
                      : kColorBackground,
                  elevation: 5,
                  child: SizedBox(
                    width: 600.r,
                    height: 500.r,
                    child: Center(
                      child: Text(
                        containerText,
                        style: kStyle.copyWith(
                          fontSize: 50.sp,
                          color: containerText == 'Ready to drop'
                              ? Colors.white
                              : kColorBackground,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Image preview container
            if (imageData != null)
              Expanded(
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Listener(
                        onPointerHover: (pointer) {
                          setState(() {
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
                          showTopSnackBar(
                            context,
                            CopiedColorSnackbar(hoveredColor: hoveredColor),
                          );
                          setState(() {});
                        },
                        child: MouseRegion(
                          cursor: SystemMouseCursors.precise,
                          onExit: (e) {
                            hovering = false;
                            hoveredColor = null;
                            kLog.wtf('Exitting image');
                            setState(() {});
                          },
                          onEnter: (e) {
                            hovering = true;
                            kLog.wtf('Hovering image');
                            setState(() {});
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20.r),
                            child: Image.memory(imageData!),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20.h,
                      ),
                      Flexible(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 2,
                                color: kColorBackground.withOpacity(0.2),
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 13.0.w),
                            child: ScrollConfiguration(
                              behavior: ScrollConfiguration.of(context)
                                  .copyWith(scrollbars: false),
                              child: CustomScrollView(
                                controller: _scrollController,
                                slivers: [
                                  SliverAppBar(
                                    toolbarHeight: 130.h,
                                    primary: false,
                                    pinned: pinnedDetailedColors,
                                    actions: [
                                      GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () {
                                          setState(() {
                                            pinnedDetailedColors =
                                                !pinnedDetailedColors;
                                            _controller.reverse();
                                            kLog.wtf(
                                              'Pinned $pinnedDetailedColors',
                                            );
                                          });
                                        },
                                        child: Padding(
                                          padding:
                                              EdgeInsets.only(right: 20.0.w),
                                          child: Lottie.asset(
                                            'assets/lock.json',
                                            controller: _controller,
                                            width: 50.w,
                                            onLoaded: (composition) {
                                              // Configure the AnimationController with the duration of the
                                              // Lottie file and start the animation.
                                              if (!pinnedDetailedColors) {
                                                _controller
                                                  ..duration =
                                                      composition.duration
                                                  ..forward();
                                              } else {
                                                _controller
                                                  ..duration =
                                                      composition.duration
                                                  ..animateBack(0);
                                              }
                                            },
                                          ),
                                        ),
                                      )
                                    ],
                                    backgroundColor: Colors.transparent,
                                    elevation: 0,
                                    flexibleSpace: Card(
                                      color: Colors.white,
                                      elevation: 5,
                                      shadowColor: kColorBackground,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 12.h,
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Column(
                                              children: [
                                                Text(
                                                  'Dominant color',
                                                  style: kStyle.copyWith(
                                                    color: kColorBackground,
                                                  ),
                                                ),
                                                if (paletteGenerator != null)
                                                  if (paletteGenerator!
                                                          .dominantColor !=
                                                      null)
                                                    CircleColor(
                                                      color: paletteGenerator!
                                                          .dominantColor!.color,
                                                    ),
                                              ],
                                            ),
                                            SizedBox(
                                              width: 20.w,
                                            ),
                                            if (copiedColor != null)
                                              Column(
                                                children: [
                                                  Text(
                                                    'Copied color',
                                                    style: kStyle.copyWith(
                                                      color: kColorBackground,
                                                    ),
                                                  ),
                                                  CircleColor(
                                                    color: copiedColor!,
                                                    cancelTap: true,
                                                  )
                                                ],
                                              ),
                                            SizedBox(
                                              width: 20.w,
                                            ),
                                            if (hoveredColor != null &&
                                                hovering)
                                              Column(
                                                children: [
                                                  Text(
                                                    'Hovered color',
                                                    style: kStyle.copyWith(
                                                      color: kColorBackground,
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
                                      ),
                                    ),
                                  ),
                                  SliverToBoxAdapter(
                                    child: Card(
                                      shadowColor: kColorBackground,
                                      elevation: 5,
                                      child: Padding(
                                        padding: EdgeInsets.all(14.0.r),
                                        child: Wrap(
                                          children: [
                                            if (activeColors.isNotEmpty)
                                              ...activeColors.map(
                                                (c) => CircleColor(
                                                  color: c,
                                                  onTap: () {
                                                    setState(() {
                                                      copiedColor = c;
                                                    });
                                                  },
                                                ),
                                              )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // To properly align dop your image container
            if (imageData == null) const SizedBox(),
            // FOOTER
            // const CopyrightFooter()
          ],
        ),
      ),
    );
  }
}
