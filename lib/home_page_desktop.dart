// Too strict
// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:html' as html;
import 'dart:ui';

import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_pixels/image_pixels.dart';
import 'package:photocanvas/constants.dart';
import 'package:photocanvas/helper/assets.dart';
import 'package:photocanvas/helper/ui_helper.dart';
import 'package:photocanvas/models/home_page_state.dart';
import 'package:photocanvas/services/image_processing_service.dart';
import 'package:photocanvas/theme/app_theme.dart';
import 'package:photocanvas/widgets/color_info_section.dart';
import 'package:photocanvas/widgets/color_palette_dialog.dart';
import 'package:photocanvas/widgets/image_drop_zone.dart';
import 'package:photocanvas/widgets/interactive_image_viewer.dart';
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
  late HomePageState _state;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _state = const HomePageState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateState(HomePageState newState) {
    setState(() {
      _state = newState;
    });
  }

  Future<void> _loadImage(html.File file) async {
    try {
      final imageData = await ImageProcessingService.processImageFile(file);

      if (imageData != null) {
        _updateState(_state.copyWith(imageData: imageData));
        Navigator.pop(context);
      }
    } on ImageProcessingException catch (e) {
      Navigator.pop(context);
      UiHelper.showErrorSnackBar(
        context,
        message: e.message,
      );
    } on Exception catch (e) {
      Navigator.pop(context);
      UiHelper.showErrorSnackBar(
        context,
        message: 'An unexpected error occurred while processing the image',
      );
      kLog.e('Unexpected error processing image: $e');
    }
  }

  Future<void> _onDrop(List<html.File> files) async {
    _updateState(_state.copyWith(copiedColor: null));

    await _showAnalyzingDialog();
    await Future<void>.delayed(const Duration(milliseconds: 250));

    final file = files[0];
    await _loadImage(file);

    if (_state.imageData != null) {
      try {
        final paletteGenerator =
            await ImageProcessingService.generateColorPalette(
          _state.imageData!,
        );
        final activeColors = paletteGenerator.colors.toList();

        _updateState(
          _state.copyWith(
            paletteGenerator: paletteGenerator,
            activeColors: activeColors,
            containerColor: Colors.white,
            containerText: 'Drop your image here',
          ),
        );
      } on ImageProcessingException catch (e) {
        UiHelper.showErrorSnackBar(context, message: e.message);
        kLog.e('Palette generation failed: ${e.message}');
      }
    }
  }

  Future<void> _showAnalyzingDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 7,
                sigmaY: 7,
              ),
              child: Padding(
                padding: const EdgeInsets.all(26),
                child: ClayText(
                  'Analyzing your image',
                  style: AppTheme.titleMedium,
                  color: AppTheme.text,
                  parentColor: AppTheme.background,
                  spread: 2,
                  depth: -25,
                  textColor: AppTheme.text,
                  emboss: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.background,
      centerTitle: true,
      toolbarHeight: 100,
      shadowColor: const Color(0xff3C4048),
      elevation: 0,
      actions: [
        if (_state.hasImage) _buildPaletteButton(),
      ],
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          PhotocanvasTitle(title: widget.title),
        ],
      ),
    );
  }

  Widget _buildPaletteButton() {
    return GestureDetector(
      onTap: _showColorPalette,
      child: Padding(
        padding: const EdgeInsets.only(right: 14),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: SvgPicture.asset(
            Assets.palette,
            height: 60,
            width: 60,
          ),
        ),
      ),
    );
  }

  Future<void> _showColorPalette() async {
    await ColorPaletteDialog.show(
      context: context,
      colors: _state.activeColors,
      onColorSelected: (color) {
        _updateState(_state.copyWith(copiedColor: color));
      },
    );
  }

  Widget _buildBody() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (!_state.hasImage) const SizedBox(height: 20),
        if (!_state.hasImage) _buildDropZone(),
        if (_state.hasImage) _buildImageSection(),
      ],
    );
  }

  Widget _buildDropZone() {
    return Center(
      child: ImageDropZone(
        containerColor: _state.containerColor,
        containerText: _state.containerText,
        onDragEnter: () => _updateState(
          _state.copyWith(
            containerColor: AppTheme.success,
            containerText: 'Ready to drop',
          ),
        ),
        onDragExit: () => _updateState(
          _state.copyWith(
            containerColor: Colors.white,
            containerText: 'Drop your image here',
          ),
        ),
        onDrop: (files) async {
          if (files != null && files.isNotEmpty) {
            await _onDrop(files.cast<html.File>());
          }
        },
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      children: [
        Stack(
          children: [
            ImagePixels(
              imageProvider: Image.memory(_state.imageData!).image,
              builder: (_, img) {
                final hoveredColor = img.pixelColorAt!(
                  _state.dx ?? 0,
                  _state.dy ?? 0,
                );
                // Update hovered color without triggering rebuild
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && _state.hoveredColor != hoveredColor) {
                    _updateState(_state.copyWith(hoveredColor: hoveredColor));
                  }
                });
                return const SizedBox();
              },
            ),
            ColorInfoSection(
              paletteGenerator: _state.paletteGenerator,
              hoveredColor: _state.hoveredColor,
              copiedColor: _state.copiedColor,
              hovering: _state.hovering,
            ),
          ],
        ),
        InteractiveImageViewer(
          imageData: _state.imageData!,
          onDrop: (files) async {
            if (files != null && files.isNotEmpty) {
              await _onDrop(files);
            }
          },
          onPointerHover: (pointer) => _updateState(
            _state.copyWith(
              localDx: pointer.localPosition.dx,
              localDy: pointer.localPosition.dy,
              dx: pointer.localPosition.dx.toInt(),
              dy: pointer.localPosition.dy.toInt(),
            ),
          ),
          onPointerDown: (pointer) => _handleColorCopy(),
          onMouseEnter: () => _updateState(_state.copyWith(hovering: true)),
          onMouseExit: () => _updateState(
            _state.copyWith(
              hovering: false,
              hoveredColor: null,
            ),
          ),
          dx: _state.dx,
          dy: _state.dy,
          localDx: _state.localDx,
          localDy: _state.localDy,
          hoveredColor: _state.hoveredColor,
          hovering: _state.hovering,
          onClearImage: () => _updateState(_state.clearImage()),
        ),
      ],
    );
  }

  Future<void> _handleColorCopy() async {
    ScaffoldMessenger.of(context).clearSnackBars();
    if (_state.hoveredColor != null) {
      await Clipboard.setData(
        ClipboardData(
          text: kColorToHexString(_state.hoveredColor!),
        ),
      );
      _updateState(_state.copyWith(copiedColor: _state.hoveredColor));
      UiHelper.showCopySnackBar(context, _state.hoveredColor!);
    }
  }
}
