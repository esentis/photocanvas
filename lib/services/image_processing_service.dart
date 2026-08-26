import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_pixels_plus/image_pixels_plus.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:photocanvas/constants.dart';

class ImageProcessingException implements Exception {
  const ImageProcessingException(this.message);
  final String message;

  @override
  String toString() => 'ImageProcessingException: $message';
}

class ImageProcessingService {
  /// Validates if the file has a supported image format
  static bool isValidImageFormat(String fileName) {
    return validImageFormats
        .any((format) => fileName.toLowerCase().endsWith(format));
  }

  static bool _isSvg(String fileName) =>
      fileName.toLowerCase().endsWith('.svg');

  /// Rasterizes raw SVG bytes into PNG bytes so the result can be displayed
  /// and pixel-sampled like any raster image.
  static Future<Uint8List?> _rasterizeSvgBytes(
    Uint8List svgBytes, {
    int? targetHeight = 310,
    int? targetWidth,
  }) async {
    final rasterized = await rasterizeSvg(
      svgBytes: svgBytes,
      width: targetWidth?.toDouble(),
      height: targetHeight?.toDouble(),
    );
    try {
      final png = await rasterized.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (png == null) {
        throw const ImageProcessingException(
          'Failed to rasterize the SVG. The file may be corrupted.',
        );
      }
      return png.buffer.asUint8List();
    } finally {
      rasterized.dispose();
    }
  }

  /// Processes and resizes an image file
  static Future<Uint8List?> processImageFile(
    html.File file, {
    int? targetHeight = 310,
    int? targetWidth,
  }) async {
    if (!isValidImageFormat(file.name)) {
      throw const ImageProcessingException(
        'File is not a valid image format (JPG, JPEG, PNG, GIF, WEBP, AVIF, SVG)',
      );
    }

    try {
      final reader = html.FileReader()..readAsArrayBuffer(file);
      await reader.onLoad.first;

      final imageData = reader.result as Uint8List?;
      if (imageData == null) {
        throw const ImageProcessingException(
          'Failed to read the image data. The file may be corrupted.',
        );
      }

      // SVGs are vector graphics: rasterize them once into PNG pixels so
      // display, palette extraction and hover sampling all share one source.
      if (_isSvg(file.name)) {
        return _rasterizeSvgBytes(
          imageData,
          targetHeight: targetHeight,
          targetWidth: targetWidth,
        );
      }

      final image = img.decodeImage(imageData);

      if (image == null) {
        throw const ImageProcessingException(
          'Failed to decode the image. The file may be corrupted.',
        );
      }

      // Resize image to optimize performance
      final resized = img.copyResize(
        image,
        width: targetWidth,
        height: targetHeight,
      );

      return img.encodeJpg(resized);
    } catch (e) {
      if (e is ImageProcessingException) {
        rethrow;
      }
      throw ImageProcessingException('Failed to process image: $e');
    }
  }

  /// Generates a color palette from image data
  static Future<PaletteGenerator> generateColorPalette(
    Uint8List imageData, {
    int maximumColorCount = 200,
  }) async {
    try {
      return await PaletteGenerator.fromImageProvider(
        Image.memory(imageData).image,
        maximumColorCount: maximumColorCount,
      );
    } catch (e) {
      throw ImageProcessingException(
        'Failed to generate color palette: $e',
      );
    }
  }
}
