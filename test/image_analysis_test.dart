import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:photocanvas/models/accessibility_report.dart';
import 'package:photocanvas/models/image_analysis.dart';
import 'package:photocanvas/services/text_placement_service.dart';

Uint8List _solidPng(img.Color color) {
  final image = img.Image(width: 120, height: 80);
  img.fill(image, color: color);
  return Uint8List.fromList(img.encodePng(image));
}

Uint8List _pngWithDarkBottomRightTextRegion() {
  final image = img.Image(width: 120, height: 80);
  img.fill(image, color: img.ColorRgb8(255, 255, 255));
  img.fillRect(
    image,
    x1: 48,
    y1: 56,
    x2: 119,
    y2: 79,
    color: img.ColorRgb8(0, 0, 0),
  );
  return Uint8List.fromList(img.encodePng(image));
}

Uint8List _checkerboardPng() {
  final image = img.Image(width: 120, height: 80);
  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      image.setPixel(
        x,
        y,
        (x + y).isEven ? img.ColorRgb8(0, 0, 0) : img.ColorRgb8(255, 255, 255),
      );
    }
  }
  return Uint8List.fromList(img.encodePng(image));
}

void main() {
  group('TextPlacementSuggestion', () {
    test('uses actual WCAG contrast to choose black on mid-dark gray', () {
      final suggestion = TextPlacementService.analyze(
        _solidPng(img.ColorRgb8(149, 149, 149)),
      );

      expect(suggestion, isNotNull);
      final s = suggestion!;
      expect(s.useWhiteText, isFalse);
      expect(s.textColor, Colors.black);
      expect(s.contrastRatio, closeTo(7, 0.1));
      expect(s.passesAa, isTrue);
    });

    test('evaluates exact rightmost and bottommost candidate positions', () {
      final suggestion = TextPlacementService.analyze(
        _pngWithDarkBottomRightTextRegion(),
      );

      expect(suggestion, isNotNull);
      final s = suggestion!;
      expect(s.region.left, closeTo(0.4, 0.0001));
      expect(s.region.top, closeTo(0.7, 0.0001));
      // Region is fully inside the image bounds.
      expect(s.region.top, greaterThanOrEqualTo(0));
      expect(s.region.bottom, lessThanOrEqualTo(1.0001));
      expect(s.region.right, lessThanOrEqualTo(1.0001));
      expect(s.useWhiteText, isTrue);
      expect(s.passesAa, isTrue);
      expect(s.textColor, Colors.white);
    });

    test('does not claim AA for a mixed black-and-white background', () {
      final suggestion = TextPlacementService.analyze(_checkerboardPng());

      expect(suggestion, isNotNull);
      final s = suggestion!;
      // The mean alone would make one color appear readable. The adverse
      // luminance percentile for each color correctly exposes 1:1 pixels.
      expect(s.meanLuminance, closeTo(0.5, 0.001));
      expect(s.contrastRatio, closeTo(1, 0.001));
      expect(s.passesAa, isFalse);
    });

    test('breaks equal-readability ties toward a lower-centre banner', () {
      final image = _solidPng(img.ColorRgb8(149, 149, 149));
      final first = TextPlacementService.analyze(image);
      final second = TextPlacementService.analyze(image);

      expect(first, isNotNull);
      expect(second, isNotNull);
      expect(first!.region, second!.region);
      expect(first.region.left, closeTo(0.2, 0.0001));
      expect(first.region.top, closeTo(0.65, 0.0001));
    });

    test('returns null for undecodable data', () {
      expect(TextPlacementService.analyze(Uint8List(4)), isNull);
    });
  });

  group('ImageAnalysis', () {
    test('formats file sizes across unit boundaries', () {
      ImageAnalysis analysisOf(int bytes) => ImageAnalysis(
            fileName: 'a.png',
            fileSizeBytes: bytes,
            format: 'PNG',
            width: 1920,
            height: 1080,
          );

      expect(analysisOf(512).formattedFileSize, '512 B');
      expect(analysisOf(1024).formattedFileSize, '1.0 KB');
      expect(
        analysisOf(5 * 1024 * 1024).formattedFileSize,
        '5.00 MB',
      );
    });

    test('computes megapixels and reduced aspect ratio', () {
      const fullHd = ImageAnalysis(
        fileName: 'a.jpg',
        fileSizeBytes: 1024,
        format: 'JPEG',
        width: 1920,
        height: 1080,
      );
      expect(fullHd.megapixels.toStringAsFixed(2), '2.07');
      expect(fullHd.aspectRatio, '16:9');
      expect(fullHd.orientation, 'Landscape');

      const square = ImageAnalysis(
        fileName: 'b.png',
        fileSizeBytes: 1024,
        format: 'PNG',
        width: 800,
        height: 800,
      );
      expect(square.aspectRatio, '1:1');
      expect(square.orientation, 'Square');
    });

    test('flags low resolution images', () {
      const tiny = ImageAnalysis(
        fileName: 'c.gif',
        fileSizeBytes: 1024,
        format: 'GIF',
        width: 100,
        height: 100,
      );
      expect(tiny.isLowResolution, isTrue);

      const large = ImageAnalysis(
        fileName: 'd.png',
        fileSizeBytes: 1024,
        format: 'PNG',
        width: 1920,
        height: 1080,
      );
      expect(large.isLowResolution, isFalse);
    });
  });

  group('ColorContrast WCAG thresholds', () {
    const white = ColorContrast(
      color: Colors.white,
      contrastWithWhite: 1,
      contrastWithBlack: 21,
    );
    const gray = ColorContrast(
      color: Colors.grey,
      contrastWithWhite: 1.6,
      contrastWithBlack: 3.4,
    );

    test('white passes AA/AAA against black only', () {
      expect(white.passesAaWithBlack(), isTrue);
      expect(white.passesAaaWithBlack(), isTrue);
      expect(white.passesAaWithWhite(), isFalse);
    });

    test('mid gray fails both AA checks (below 4.5)', () {
      expect(gray.passesAaWithWhite(), isFalse);
      expect(gray.passesAaWithBlack(), isFalse);
      expect(gray.contrastWithBlack, lessThan(ColorContrast.aaThreshold));
    });

    test('coverage counts colors readable with white text', () {
      const navy = ColorContrast(
        color: Color(0xFF1A237E),
        contrastWithWhite: 12,
        contrastWithBlack: 1.2,
      );
      const report = AccessibilityReport(
        averageLuminance: 0.5,
        colorContrasts: [white, navy],
      );
      expect(report.aaWhiteTextCoverage, closeTo(0.5, 0.001));
    });

    test('contrast ratio is symmetric and matches WCAG math', () {
      expect(
        ColorContrast.contrastRatio(0.8, 0.2),
        closeTo(3.4, 0.001),
      ); // (0.8 + 0.05) / (0.2 + 0.05)
      expect(
        ColorContrast.contrastRatio(0.8, 0.2),
        closeTo(ColorContrast.contrastRatio(0.2, 0.8), 0.0001),
      );
    });
  });

  group('Overlay text recommendations', () {
    AccessibilityReport reportAt(double luminance) => AccessibilityReport(
          averageLuminance: luminance,
          colorContrasts: const [],
        );

    test('dark images recommend white text with margin to spare', () {
      final report = reportAt(0.05);
      expect(report.recommendsWhiteText, isTrue);
      // (1 + 0.05) / (0.05 + 0.05) = 10.5
      expect(report.whiteTextRatio, closeTo(10.5, 0.01));
      expect(report.recommendedPassesAa, isTrue);
      expect(report.recommendedPassesAaa, isTrue);
    });

    test('bright images recommend black text', () {
      final report = reportAt(0.9);
      expect(report.recommendsWhiteText, isFalse);
      // (0.9 + 0.05) / (0 + 0.05) = 19
      expect(report.blackTextRatio, closeTo(19, 0.01));
      expect(report.recommendedTextRatio, report.blackTextRatio);
      expect(report.recommendedPassesAaa, isTrue);
    });

    test('mid-tone images still resolve to the stronger option', () {
      final report = reportAt(0.45);
      // Black wins: (0.45 + 0.05) / 0.05 = 10 vs white's ~2.1
      expect(report.recommendsWhiteText, isFalse);
      expect(report.recommendedPassesAa, isTrue);
    });

    test('prefersWhiteText flags the winning column per color', () {
      const darkBg = ColorContrast(
        color: Colors.indigo,
        contrastWithWhite: 8.6,
        contrastWithBlack: 2.4,
      );
      const midBg = ColorContrast(
        color: Colors.grey,
        contrastWithWhite: 1.6,
        contrastWithBlack: 3.4,
      );
      expect(darkBg.prefersWhiteText, isTrue);
      expect(midBg.prefersWhiteText, isFalse);
    });

    test('one of white or black always passes AA on any background', () {
      for (final luminance in [0.0, 0.1, 0.18, 0.5, 0.85, 1.0]) {
        final report = reportAt(luminance);
        final anyPass = report.whiteTextRatio >= ColorContrast.aaThreshold ||
            report.blackTextRatio >= ColorContrast.aaThreshold;
        expect(anyPass, isTrue, reason: 'luminance $luminance');
      }
    });
  });
}
