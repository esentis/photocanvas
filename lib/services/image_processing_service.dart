import 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
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

  /// Processes and resizes an image file
  static Future<Uint8List?> processImageFile(
    html.File file, {
    int? targetHeight = 310,
    int? targetWidth,
  }) async {
    if (!isValidImageFormat(file.name)) {
      throw const ImageProcessingException(
        'File is not a valid image format (JPG, JPEG, PNG, GIF, WEBP, AVIF)',
      );
    }

    try {
      final reader = html.FileReader()..readAsArrayBuffer(file);
      await reader.onLoad.first;

      final imageData = reader.result as Uint8List;
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
      throw ImageProcessingException(
          'Failed to process image: ${e.toString()}');
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
        'Failed to generate color palette: ${e.toString()}',
      );
    }
  }
}
