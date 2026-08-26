import 'dart:html' as html;
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_pixels_plus/image_pixels_plus.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:photocanvas/constants.dart';
import 'package:photocanvas/models/accessibility_report.dart';
import 'package:photocanvas/models/image_analysis.dart';

class ImageProcessingException implements Exception {
  const ImageProcessingException(this.message);
  final String message;

  @override
  String toString() => 'ImageProcessingException: $message';
}

/// Result of [ImageProcessingService.processImageFile]: the display-ready
/// pixel buffer plus metadata of the original dropped file.
class ProcessedImage {
  const ProcessedImage({required this.data, required this.analysis});

  final Uint8List data;
  final ImageAnalysis analysis;
}

class ImageProcessingService {
  /// Validates if the file has a supported image format
  static bool isValidImageFormat(String fileName) {
    return validImageFormats
        .any((format) => fileName.toLowerCase().endsWith(format));
  }

  static bool _isSvg(String fileName) =>
      fileName.toLowerCase().endsWith('.svg');

  /// Detects the true format from magic bytes, falling back to the file
  /// extension. Extensions lie; headers rarely do.
  static String _sniffFormat(Uint8List bytes, String fileName) {
    if (_isSvg(fileName)) return 'SVG';
    if (bytes.length >= 3 && bytes[0] == 0xFF && bytes[1] == 0xD8) {
      return 'JPEG';
    }
    if (bytes.length >= 4 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return 'PNG';
    }
    if (bytes.length >= 6 &&
        bytes[0] == 0x47 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x38) {
      return 'GIF';
    }
    if (bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50) {
      return 'WEBP';
    }
    if (bytes.length >= 12 && String.fromCharCodes(bytes.sublist(4, 8)) == 'ftyp') {
      return 'AVIF';
    }
    final extension = fileName.split('.').last.toUpperCase();
    return extension.isEmpty ? 'UNKNOWN' : extension;
  }

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

  /// Processes an image file for display and reports the original file's
  /// metadata. The returned bytes are resized/re-encoded, so anything about
  /// the source file must be captured here.
  static Future<ProcessedImage?> processImageFile(
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

      final format = _sniffFormat(imageData, file.name);
      final analysis = ImageAnalysis(
        fileName: file.name,
        fileSizeBytes: imageData.lengthInBytes,
        format: format,
        width: 0,
        height: 0,
      );

      // SVGs are vector graphics: rasterize them once into PNG pixels so
      // display, palette extraction and hover sampling all share one source.
      if (_isSvg(file.name)) {
        final svgPixels = await _rasterizeSvgBytes(
          imageData,
          targetHeight: targetHeight,
          targetWidth: targetWidth,
        );
        if (svgPixels == null) return null;
        return ProcessedImage(data: svgPixels, analysis: analysis);
      }

      final image = img.decodeImage(imageData);

      if (image == null) {
        throw const ImageProcessingException(
          'Failed to decode the image. The file may be corrupted.',
        );
      }

      // Original dimensions must be read before resizing.
      final originalAnalysis = ImageAnalysis(
        fileName: analysis.fileName,
        fileSizeBytes: analysis.fileSizeBytes,
        format: format,
        width: image.width,
        height: image.height,
      );

      // Resize image to optimize performance
      final resized = img.copyResize(
        image,
        width: targetWidth,
        height: targetHeight,
      );

      return ProcessedImage(
        data: img.encodeJpg(resized),
        analysis: originalAnalysis,
      );
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

  /// Computes WCAG 2.1 contrast ratios for [colors] against white and black
  /// text plus the average perceived brightness of the image.
  static AccessibilityReport analyzeAccessibility(
    Uint8List imageData,
    List<Color> colors,
  ) {
    final luminance = _averageLuminance(imageData);
    final contrasts = colors.map((color) {
      final colorLuminance = color.computeLuminance();
      return ColorContrast(
        color: color,
        contrastWithWhite: _contrastRatio(colorLuminance, 1),
        contrastWithBlack: _contrastRatio(colorLuminance, 0),
      );
    }).toList();

    return AccessibilityReport(
      averageLuminance: luminance,
      colorContrasts: contrasts,
    );
  }

  /// WCAG contrast ratio between two relative luminances; either may be the
  /// lighter one so callers pass them in any order.
  static double _contrastRatio(double a, double b) {
    final lighter = a > b ? a : b;
    final darker = a > b ? b : a;
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Mean relative luminance across all pixels of the display-sized image.
  /// Runs on the already-resized bytes, keeping the loop cheap.
  static double _averageLuminance(Uint8List imageData) {
    final image = img.decodeImage(imageData);
    if (image == null || image.width == 0 || image.height == 0) return 0;

    var total = 0.0;
    for (final pixel in image.data!) {
      total += _linearChannel(pixel.r) * 0.2126 +
          _linearChannel(pixel.g) * 0.7152 +
          _linearChannel(pixel.b) * 0.0722;
    }
    return total / (image.width * image.height);
  }

  /// sRGB channel to linear-light conversion per WCAG 2.1.
  static double _linearChannel(num channel) {
    final c = channel / 255;
    return c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
  }
}
