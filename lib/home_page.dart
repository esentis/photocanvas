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
import 'package:photocanvas/widgets/copyright_footer.dart';
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

  int? dx;
  int? dy;

  Color? hoveredColor;

  Color? copiedColor;

  final ScrollController _scrollController = ScrollController();

  Future<void> loadImage(html.File file) async {
    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    await reader.onLoad.first;
    imageData = reader.result! as Uint8List;
    // ignore: cast_nullable_to_non_nullable
    final img.Image image = img.decodeImage(imageData as Uint8List)!;
    final img.Image resized = img.copyResize(
      image,
      // width: 400,
      height: 310,
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
    return Scaffold(
      backgroundColor: kColorBackground,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: kColorBackground,
        title: Text(widget.title, style: kStyle),
      ),
      body: Center(
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
                  onDragEnter: () {},
                  onDragExit: () {},
                  onDrop: (files) async {
                    await onDrop(files);
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Column(
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
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20.r),
                                child: Image(
                                  image: Image.memory(
                                    imageData!,
                                  ).image,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 40.h,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14.0.w),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      'Dominant color',
                                      style: kStyle.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                    CircleColor(
                                      color: paletteGenerator!
                                          .dominantColor!.color,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: 20.w,
                                ),
                                Column(
                                  children: [
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
                                          cancelTap: true,
                                          height: 100.r,
                                          width: 100.r,
                                          color: img.pixelColorAt!(
                                            dx ?? 0,
                                            dy ?? 0,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: 20.w,
                                ),
                                Column(
                                  children: [
                                    Text(
                                      'Copied color',
                                      style: kStyle.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                    CircleColor(
                                      color: copiedColor ?? Colors.white,
                                      cancelTap: true,
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Flexible(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.0.w,
                                vertical: 8.0.h,
                              ),
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
                                    ),
                                    child: RawScrollbar(
                                      controller: _scrollController,
                                      thumbColor: kColorMain,
                                      isAlwaysShown: true,
                                      radius: Radius.circular(20.r),
                                      thickness: 5,
                                      child: SingleChildScrollView(
                                        controller: _scrollController,
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
            const CopyrightFooter()
          ],
        ),
      ),
    );
  }
}
