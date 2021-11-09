import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:ui';

import 'package:dotted_border/dotted_border.dart';
import 'package:drop_zone/drop_zone.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:photocanvas/constants.dart';
import 'package:photocanvas/widgets/circle_color.dart';
import 'package:photocanvas/widgets/inner_shadow.dart';

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

  Future<void> loadImage(html.File file) async {
    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    await reader.onLoad.first;
    setState(() {
      imageData = reader.result! as Uint8List;
    });
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
                      width: mq.width * .6,
                      height: 300.h,
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
              DropZone(
                onDragEnter: () {
                  log.wtf('Entering on dropzone');
                  setState(() {
                    showOverlay = true;
                  });
                },
                onDragExit: () {
                  log.wtf('Exiting  dropzone');
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
                    Container(
                      color: Colors.transparent,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    width: 350.r,
                                    height: 350.r,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20.r),
                                      image: DecorationImage(
                                        image: Image.memory(imageData!).image,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 50.w,
                                    right: 50.w,
                                    top: 50.h,
                                    bottom: 50.h,
                                    child: IconButton(
                                      iconSize: 90.r,
                                      onPressed: () {
                                        setState(() {
                                          imageData = null;
                                          activeColors = [];
                                          containerText =
                                              'Drop your image here';
                                        });
                                      },
                                      icon: const Icon(
                                        Icons.restore,
                                        color: Colors.white,
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
                              CircleColor(
                                color: paletteGenerator!.dominantColor!.color,
                              ),
                              Text(
                                'found in ${paletteGenerator!.dominantColor!.population} pixels',
                                style: kStyle.copyWith(
                                  color: Colors.white,
                                  fontSize: 30.sp,
                                ),
                              ),
                              SizedBox(
                                height: 10.h,
                              ),
                            ],
                          ),
                          ScrollConfiguration(
                            behavior: ScrollConfiguration.of(context).copyWith(
                              dragDevices: {
                                PointerDeviceKind.touch,
                                PointerDeviceKind.mouse,
                              },
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0.w),
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
                                      borderRadius: BorderRadius.circular(20.r),
                                    ),
                                    child: SizedBox(
                                      height: mq.height - kToolbarHeight - 60.h,
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
                        ],
                      ),
                    ),
                    // if (showOverlay)
                    //   Container(
                    //     width: 1.sw,
                    //     height: 1.sh - kTextTabBarHeight - 60.h,
                    //     color: Colors.black.withOpacity(0.6),
                    //     child: Center(
                    //       child: Icon(
                    //         Icons.add,
                    //         size: 90.r,
                    //         color: Colors.white,
                    //       ),
                    //     ),
                    //   ),
                  ],
                ),
              ),
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
