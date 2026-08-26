import 'package:flutter/foundation.dart';

/// Immutable metadata about the originally dropped file, captured before
/// the image gets resized/re-encoded for display.
@immutable
class ImageAnalysis {
  const ImageAnalysis({
    required this.fileName,
    required this.fileSizeBytes,
    required this.format,
    required this.width,
    required this.height,
  });

  final String fileName;
  final int fileSizeBytes;

  /// Uppercase format label, e.g. `PNG`, `JPEG`, `WEBP`.
  final String format;
  final int width;
  final int height;

  static const double _lowResolutionMegapixels = 0.1;
  static const int _ratioCap = 21;

  String get resolution => '$width × $height px';

  double get megapixels => (width * height) / 1000000;

  /// Human-readable size, e.g. `482.1 KB`.
  String get formattedFileSize {
    if (fileSizeBytes < 1024) return '$fileSizeBytes B';
    if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  /// `landscape`, `portrait` or `square`.
  String get orientation {
    if (width > height) return 'Landscape';
    if (width < height) return 'Portrait';
    return 'Square';
  }

  /// Aspect ratio reduced to smallest whole numbers, e.g. `16:9`.
  /// Falls back to a decimal ratio when reduction yields absurd numbers.
  String get aspectRatio {
    if (width == 0 || height == 0) return '—';
    final divisor = _gcd(width, height);
    final rw = width ~/ divisor;
    final rh = height ~/ divisor;
    if (rw > _ratioCap || rh > _ratioCap) {
      return '${(width / height).toStringAsFixed(2)}:1';
    }
    return '$rw:$rh';
  }

  bool get isLowResolution => megapixels < _lowResolutionMegapixels;

  static int _gcd(int a, int b) => b == 0 ? a : _gcd(b, a % b);
}
