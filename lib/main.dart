import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:ui';

import 'package:dotted_border/dotted_border.dart';
import 'package:drop_zone/drop_zone.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:photocanvas/widgets/circle_color.dart';
import 'package:photocanvas/widgets/inner_shadow.dart';

import 'constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Photocanvas',
      home: MyHomePage(title: 'Photocanvas'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Color containerColor = kColorMain;
  String containerText = 'Drop your image here';
  String focusedColorHex = '';
  List<Color> activeColors = [];
  Uint8List? imageData;

  Future<void> loadImage(html.File file) async {
    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    await reader.onLoad.first;
    setState(() {
      imageData = reader.result! as Uint8List;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: kColorBackground,
      appBar: AppBar(
        backgroundColor: kColorBackground,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.title, style: kStyle),
            IconButton(
              onPressed: () {
                setState(() {
                  imageData = null;
                  activeColors = [];
                });
              },
              icon: Icon(Icons.restore),
            )
          ],
        ),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: imageData == null
              ? MainAxisAlignment.center
              : MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(
              height: 20,
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
                    containerColor = kColorMain;
                    containerText = 'Drop your image here';
                  });
                },
                onDrop: (List<html.File>? files) async {
                  final file = files?[0];
                  await loadImage(file!);

                  final paletteGenerator =
                      await PaletteGenerator.fromImageProvider(
                    Image.memory(imageData!).image,
                    maximumColorCount: 20,
                  );
                  activeColors = paletteGenerator.colors.toList();
                  log.wtf(paletteGenerator.colors.length);
                  for (final c in paletteGenerator.colors) {
                    log.wtf(kColorToHexString(c));
                  }

                  // image = File(files?[0].relativePath ?? '');
                  setState(() {
                    containerColor = kColorMain;
                  });
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
                      height: 300,
                      decoration: BoxDecoration(
                        color: containerColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          containerText,
                          style: kStyle.copyWith(
                            fontSize: 50,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (imageData != null)
              Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: Image.memory(imageData!).image,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 7,
                    sigmaY: 7,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xff864879).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Wrap(
                      children: [
                        if (activeColors.isNotEmpty)
                          ...activeColors.map(
                            (c) => Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: CircleColor(
                                color: c,
                                onHover: () {
                                  setState(() {
                                    focusedColorHex = kColorToHexString(c);
                                  });
                                },
                                onExit: () {
                                  setState(() {
                                    focusedColorHex = '';
                                  });
                                },
                              ),
                            ),
                          )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
