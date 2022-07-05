// ignore_for_file: unawaited_futures, use_build_context_synchronously, cascade_invocations, cast_nullable_to_non_nullable

import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:ui';

import 'package:drop_zone/drop_zone.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image/image.dart' as img;
import 'package:image_pixels/image_pixels.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:photocanvas/constants.dart';
import 'package:photocanvas/widgets/circle_color.dart';
import 'package:photocanvas/widgets/copyright_footer.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Color containerColor = Colors.white;
  String containerText = 'Drop your image here';
  String focusedColorHex = '';
  PaletteGenerator? paletteGenerator;
  List<Color> activeColors = [];
  Uint8List? imageData;

  bool showOverlay = false;
  bool hovering = false;

  int? dx;
  int? dy;

  Color? hoveredColor;

  Color? copiedColor;

  final ScrollController _scrollController = ScrollController();

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
      builder: (context) => Dialog(
        backgroundColor: Colors.white.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 3,
                sigmaY: 3,
              ),
              child: Container(
                width: 250.w,
                height: 150.h,
                decoration: BoxDecoration(
                  color: kColorBackground.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: Text(
                    'Analyzing your image',
                    style: kStyle.copyWith(
                      color: Colors.white,
                    ),
                  ),
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
      containerColor = kColorMain;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 100.h,
        actions: [],
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
            Align(
              alignment: Alignment.bottomCenter,
              child: Card(
                elevation: 5,
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 13.0.h, horizontal: 25.w),
                  child: Column(
                    children: [
                      Text(
                        widget.title,
                        style: kStyle.copyWith(
                          color: kColorBackground,
                        ),
                      ),
                      Text(
                        '1.0.1',
                        style: kStyle.copyWith(
                          fontSize: 16.sp,
                          color: kColorBackground,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
                  // shape: RoundedRectangleBorder(
                  //   borderRadius: BorderRadius.circular(
                  //     23.r,
                  //   ),
                  // ),
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
                                    color: hoveredColor!.withOpacity(0.8),
                                    child: Center(
                                      child: Text(
                                        '${kColorToHexString(hoveredColor ?? Colors.white)}\ncopied to clipboard!',
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
                            color: const Color(0xff864879).withOpacity(0.2),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 13.0.w),
                            child: CustomScrollView(
                              controller: _scrollController,
                              slivers: [
                                SliverAppBar(
                                  toolbarHeight: 120.h,
                                  primary: false,
                                  floating: true,
                                  backgroundColor: Colors.transparent,
                                  flexibleSpace: Card(
                                    color: Colors.white,
                                    elevation: 5,
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
                                            kColorToHexString(
                                                  hoveredColor!,
                                                ) !=
                                                '9e9e9e')
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
                                SliverToBoxAdapter(
                                  child: Card(
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
                    ],
                  ),
                ),
              ),

            // FOOTER
            const CopyrightFooter()
          ],
        ),
      ),
    );
  }
}
