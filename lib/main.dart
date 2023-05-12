import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:photocanvas/coming_soon.dart';
import 'package:photocanvas/helper/utils.dart';
import 'package:photocanvas/home_page_desktop.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:url_strategy/url_strategy.dart';

void main() async {
  final packageInfo = await PackageInfo.fromPlatform();

  Utils.version = packageInfo.version;
  setPathUrlStrategy();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photocanvas',
      scrollBehavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
        },
      ),
      home: ScreenTypeLayout.builder(
        mobile: (BuildContext context) => const ComingSoon(),
        tablet: (BuildContext context) => const ComingSoon(),
        desktop: (BuildContext context) =>
            const HomePageDesktop(title: 'Photocanvas'),
        watch: (BuildContext context) => const ComingSoon(),
      ),
      // home: const HomePage(title: 'Photocanvas'),
    );
  }
}
