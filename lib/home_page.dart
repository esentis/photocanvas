import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:ui';

import 'package:dotted_border/dotted_border.dart';
import 'package:drop_zone/drop_zone.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image/image.dart' as img;
import 'package:image_pixels/image_pixels.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:photocanvas/constants.dart';
import 'package:photocanvas/widgets/circle_color.dart';
import 'package:photocanvas/widgets/inner_shadow.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Color containerColor = kColorMain;
  String containerText = 'Drop your image here';
  String focusedColorHex = '';
  PaletteGenerator? paletteGenerator;
  List<Color> activeColors = [];
  Uint8List? imageData;
  bool showOverlay = false;
  Color kFooterTextColor = Colors.white;

  int? dx;
  int? dy;

  Color? hoveredColor;

  Color? copiedColor;

  Future<void> loadImage(html.File file) async {
    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    await reader.onLoad.first;
    imageData = reader.result! as Uint8List;
    // ignore: cast_nullable_to_non_nullable
    final img.Image image = img.decodeImage(imageData as Uint8List)!;
    final img.Image resized = img.copyResize(
      image,
      width: 400,
    );
    imageData = img.encodeJpg(resized) as Uint8List;
    setState(() {});
  }

  Future<void> onDrop(List<html.File>? files) async {
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    final file = files?[0];
    await loadImage(file!);

    paletteGenerator = await PaletteGenerator.fromImageProvider(
      Image.memory(imageData!).image,
      maximumColorCount: 200,
    );
    activeColors = paletteGenerator!.colors.toList();

    setState(() {
      containerColor = kColorMain;
    });
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: kColorBackground,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: kColorBackground,
        title: Text(widget.title, style: kStyle),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (imageData == null)
              SizedBox(
                height: 20.h,
              ),
            // The image dropzone
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
                    containerColor = kColorMain;
                    containerText = 'Drop your image here';
                  });
                },
                onDrop: (List<html.File>? files) async {
                  await onDrop(files);
                },
                child: DottedBorder(
                  borderType: BorderType.RRect,
                  strokeWidth: 2,
                  radius: const Radius.circular(20),
                  padding: const EdgeInsets.all(12),
                  color: containerColor,
                  child: InnerShadow(
                    blur: 7,
                    color: kColorInnerShadow,
                    child: Container(
                      width: 600.r,
                      height: 500.r,
                      decoration: BoxDecoration(
                        color: containerColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          containerText,
                          style: kStyle.copyWith(
                            fontSize: 50.sp,
                            color: Colors.white,
                          ),
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
                    setState(() {
                      showOverlay = true;
                    });
                  },
                  onDragExit: () {
                    setState(() {
                      showOverlay = false;
                    });
                  },
                  onDrop: (files) async {
                    await onDrop(files);
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Stack(
                                children: [
                                  Listener(
                                    onPointerHover: (pointer) {
                                      setState(() {
                                        dx = pointer.localPosition.dx.toInt();
                                        dy = pointer.localPosition.dy.toInt();
                                      });
                                    },
                                    onPointerDown: (pointer) {
                                      ScaffoldMessenger.of(context)
                                          .clearSnackBars();
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
                                          borderRadius:
                                              BorderRadius.circular(12.r),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12.r),
                                            child: BackdropFilter(
                                              filter: ImageFilter.blur(
                                                sigmaX: 7.r,
                                                sigmaY: 7.r,
                                              ),
                                              child: Container(
                                                height: 80.h,
                                                color: hoveredColor!
                                                    .withOpacity(0.8),
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
                                      cursor: SystemMouseCursors.click,
                                      child: Container(
                                        width: Image.memory(
                                          imageData!,
                                        ).width,
                                        height: Image.memory(
                                          imageData!,
                                        ).height,
                                        color: hoveredColor ?? Colors.white,
                                        child: Image(
                                          image: Image.memory(
                                            imageData!,
                                          ).image,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 20.h,
                              ),
                              Text(
                                'Dominant color',
                                style: kStyle.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'found in ${paletteGenerator!.dominantColor!.population} pixels',
                                style: kStyle.copyWith(
                                  color: Colors.white,
                                  fontSize: 25.sp,
                                ),
                              ),
                              CircleColor(
                                color: paletteGenerator!.dominantColor!.color,
                              ),
                              Text(
                                'Hovered color',
                                style: kStyle.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              ImagePixels(
                                imageProvider: Image.memory(
                                  imageData!,
                                ).image,
                                builder: (_, img) {
                                  hoveredColor = img.pixelColorAt!(
                                    dx ?? 0,
                                    dy ?? 0,
                                  );
                                  return CircleColor(
                                    color: img.pixelColorAt!(
                                      dx ?? 0,
                                      dy ?? 0,
                                    ),
                                  );
                                },
                              ),
                              Text(
                                'Copied color',
                                style: kStyle.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              CircleColor(
                                color: copiedColor ?? Colors.white,
                              )
                            ],
                          ),
                          Flexible(
                            child: ScrollConfiguration(
                              behavior:
                                  ScrollConfiguration.of(context).copyWith(
                                dragDevices: {
                                  PointerDeviceKind.touch,
                                  PointerDeviceKind.mouse,
                                },
                              ),
                              child: Padding(
                                padding:
                                    EdgeInsets.symmetric(horizontal: 8.0.w),
                                child: ClipRRect(
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 7.r,
                                      sigmaY: 7.r,
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xff864879)
                                            .withOpacity(0.2),
                                        borderRadius:
                                            BorderRadius.circular(20.r),
                                      ),
                                      child: SizedBox(
                                        height:
                                            mq.height - kToolbarHeight - 60.h,
                                        width: mq.width * .6,
                                        child: Scrollbar(
                                          isAlwaysShown: true,
                                          hoverThickness: 18,
                                          radius: Radius.circular(20.r),
                                          interactive: true,
                                          showTrackOnHover: true,
                                          child: GridView.count(
                                            padding: EdgeInsets.zero,
                                            crossAxisCount: 4,
                                            children: [
                                              if (activeColors.isNotEmpty)
                                                ...activeColors.map(
                                                  (c) => Padding(
                                                    padding:
                                                        EdgeInsets.all(12.0.r),
                                                    child: CircleColor(
                                                      color: c,
                                                    ),
                                                  ),
                                                )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            // FOOTER
            MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (p) {
                setState(() {
                  kFooterTextColor = kColorMain;
                });
              },
              onExit: (p) {
                setState(() {
                  kFooterTextColor = Colors.white;
                });
              },
              child: GestureDetector(
                onTap: () => launchLink('https://www.github.com/esentis'),
                child: Container(
                  height: 35.h,
                  width: 1.sw,
                  color: kColorBackground,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: kStyle.copyWith(
                          fontSize: 30.sp,
                          color: kFooterTextColor,
                        ),
                        child:
                            Text('esentis © ${DateTime.now().year.toString()}'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
