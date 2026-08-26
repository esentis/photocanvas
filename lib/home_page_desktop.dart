// Too strict
// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:html' as html;
import 'dart:ui';

import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_pixels_plus/image_pixels_plus.dart';
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

class _HomePageDesktopState extends State<HomePageDesktop> {
  late HomePageState _state;

  /// Pixel buffer of the loaded image, kept outside the rebuild cycle.
  ImgDetails? _imgDetails;

  /// Hover state lives here instead of [HomePageState] so pointer movement
  /// does not rebuild the page; only leaf widgets listen to these.
  final ValueNotifier<Color?> _hoveredColor = ValueNotifier<Color?>(null);
  final ValueNotifier<Offset?> _pointerLocalPos = ValueNotifier<Offset?>(null);

  /// Guard against concurrent drop processing.
  bool _isProcessing = false;

  /// Handle to the open analyzing dialog, dismissed via [Route.navigator]
  /// so it can never pop the page route underneath it.
  DialogRoute<void>? _analyzingRoute;

  @override
  void initState() {
    super.initState();
    _state = const HomePageState();
  }

  @override
  void dispose() {
    _hoveredColor.dispose();
    _pointerLocalPos.dispose();
    super.dispose();
  }

  void _updateState(HomePageState newState) {
    setState(() {
      _state = newState;
    });
  }

  Future<void> _onDrop(List<html.File> files) async {
    if (_isProcessing || files.isEmpty) return;
    _isProcessing = true;

    _hoveredColor.value = null;
    _pointerLocalPos.value = null;
    _updateState(_state.copyWith(copiedColor: null));

    // Show the dialog but do not await its completion: processing is gated
    // by this try/finally, never by the dialog's lifecycle.
    _showAnalyzingDialog();

    try {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      final imageData =
          await ImageProcessingService.processImageFile(files.first);

      if (!mounted) return;
      if (imageData != null) {
        _updateState(_state.copyWith(imageData: imageData));
        await _generatePalette();
      }
    } on ImageProcessingException catch (e) {
      if (mounted) UiHelper.showErrorSnackBar(context, message: e.message);
    } on Exception catch (e) {
      if (mounted) {
        UiHelper.showErrorSnackBar(
          context,
          message: 'An unexpected error occurred while processing the image',
        );
      }
      kLog.e('Unexpected error processing image: $e');
    } finally {
      _dismissAnalyzingDialog();
      _isProcessing = false;
    }
  }

  Future<void> _generatePalette() async {
    final imageData = _state.imageData;
    if (imageData == null) return;

    try {
      final paletteGenerator =
          await ImageProcessingService.generateColorPalette(imageData);

      if (!mounted) return;
      _updateState(
        _state.copyWith(
          paletteGenerator: paletteGenerator,
          activeColors: paletteGenerator.colors.toList(),
          containerColor: Colors.white,
          containerText: 'Drop your image here',
        ),
      );
    } on ImageProcessingException catch (e) {
      if (mounted) UiHelper.showErrorSnackBar(context, message: e.message);
      kLog.e('Palette generation failed: ${e.message}');
    } on Exception catch (e) {
      kLog.e('Unexpected error generating palette: $e');
    }
  }

  void _showAnalyzingDialog() {
    final route = DialogRoute<void>(
      context: context,
      barrierDismissible: false,
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
    _analyzingRoute = route;
    unawaited(Navigator.of(context, rootNavigator: true).push(route));
  }

  void _dismissAnalyzingDialog() {
    final route = _analyzingRoute;
    _analyzingRoute = null;
    // removeRoute detaches exactly this dialog; it cannot pop the page
    // even if other dialogs/routes were stacked in the meantime.
    if (route != null && route.isActive) {
      route.navigator?.removeRoute(route);
    }
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
    final imageData = _state.imageData;
    if (imageData == null) return const SizedBox.shrink();

    return Column(
      children: [
        Stack(
          children: [
            ImagePixelsPlus(
              imageProvider: MemoryImage(imageData),
              builder: (_, img) {
                // Keep the pixel buffer reachable for hover lookups without
                // participating in the rebuild cycle.
                _imgDetails = img;
                return const SizedBox.shrink();
              },
            ),
            ColorInfoSection(
              paletteGenerator: _state.paletteGenerator,
              hoveredColor: _hoveredColor,
              copiedColor: _state.copiedColor,
            ),
          ],
        ),
        InteractiveImageViewer(
          imageData: imageData,
          onDrop: (files) async {
            if (files != null && files.isNotEmpty) {
              await _onDrop(files);
            }
          },
          onPointerHover: _handlePointerHover,
          onPointerDown: (pointer) => _handleColorCopy(),
          onMouseExit: _handleMouseExit,
          pointerLocalPos: _pointerLocalPos,
          onClearImage: _clearImage,
        ),
      ],
    );
  }

  void _handlePointerHover(PointerHoverEvent event) {
    _pointerLocalPos.value = event.localPosition;

    final img = _imgDetails;
    final pixelColorAt = img?.pixelColorAt;
    if (img == null ||
        pixelColorAt == null ||
        img.byteData == null ||
        img.width == null ||
        img.height == null) {
      return;
    }

    final x = event.localPosition.dx.floor();
    final y = event.localPosition.dy.floor();
    if (x < 0 || x >= img.width! || y < 0 || y >= img.height!) {
      return;
    }

    final color = pixelColorAt(x, y);
    if (_hoveredColor.value != color) {
      _hoveredColor.value = color;
    }
  }

  void _handleMouseExit() {
    _pointerLocalPos.value = null;
    _hoveredColor.value = null;
  }

  void _clearImage() {
    _hoveredColor.value = null;
    _pointerLocalPos.value = null;
    _updateState(_state.clearImage());
  }

  Future<void> _handleColorCopy() async {
    ScaffoldMessenger.of(context).clearSnackBars();
    final color = _hoveredColor.value;
    if (color != null) {
      await Clipboard.setData(
        ClipboardData(text: kColorToHexString(color)),
      );
      if (!mounted) return;
      _updateState(_state.copyWith(copiedColor: color));
      UiHelper.showCopySnackBar(context, color);
    }
  }
}
