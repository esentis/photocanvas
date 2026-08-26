import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:photocanvas/models/accessibility_report.dart';
import 'package:photocanvas/models/image_analysis.dart';
import 'package:photocanvas/models/text_placement.dart';
import 'package:photocanvas/services/text_placement_service.dart';

TextPlacementSuggestion? _analyze(
  Uint8List imageData, {
  Color backdropColor = Colors.black,
}) =>
    TextPlacementService.analyze(
      imageData,
      backdropColor: backdropColor,
    );

Uint8List _solidPng(img.Color color) {
  final image = img.Image(width: 120, height: 80);
  img.fill(image, color: color);
  return Uint8List.fromList(img.encodePng(image));
}

Uint8List _solidRgbaPng(img.ColorRgba8 color) {
  final image = img.Image(width: 120, height: 80, numChannels: 4);
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

Uint8List _sparseAdversePixelsPng() {
  final image = img.Image(width: 120, height: 80);
  img.fill(image, color: img.ColorRgb8(0, 0, 0));
  // Fewer than 1% of the pixels are white, but every candidate contains one.
  // A 90th-percentile check misses them; a true worst-case check cannot.
  for (var y = 6; y < image.height; y += 12) {
    for (var x = 6; x < image.width; x += 12) {
      image.setPixel(x, y, img.ColorRgb8(255, 255, 255));
    }
  }
  return Uint8List.fromList(img.encodePng(image));
}

Uint8List _aaBusyVersusNonAaCalmPng() {
  final image = img.Image(width: 120, height: 80);
  img.fill(image, color: img.ColorRgb8(117, 117, 117));

  // The top candidate is visually busy but every pixel passes AA with white.
  for (var y = 0; y < 24; y++) {
    for (var x = 0; x < image.width; x++) {
      image.setPixel(
        x,
        y,
        (x + y).isEven ? img.ColorRgb8(0, 0, 0) : img.ColorRgb8(118, 118, 118),
      );
    }
  }

  // Every other candidate contains 116 and 119 gray. That narrow range is
  // very calm, but its worst white and black contrast both fall below AA.
  for (final y in [24, 48, 72]) {
    for (var x = 0; x < image.width - 1; x += 12) {
      image
        ..setPixel(x, y, img.ColorRgb8(116, 116, 116))
        ..setPixel(x + 1, y, img.ColorRgb8(119, 119, 119));
    }
  }
  return Uint8List.fromList(img.encodePng(image));
}

Uint8List _calmVersusBusyEqualContrastPng() {
  final image = img.Image(width: 120, height: 80);
  img.fill(image, color: img.ColorRgb8(0, 0, 0));

  // Sparse gray pixels give every calm candidate the same worst contrast as
  // the checkerboard below, isolating uniformity and edge density as factors.
  for (final y in [6, 18, 30, 42, 54]) {
    for (var x = 0; x < image.width; x += 12) {
      image.setPixel(x, y, img.ColorRgb8(110, 110, 110));
    }
  }
  for (var y = 56; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      if ((x + y).isEven) {
        image.setPixel(x, y, img.ColorRgb8(110, 110, 110));
      }
    }
  }
  return Uint8List.fromList(img.encodePng(image));
}

Uint8List _offGridOnlyAaPng() {
  final image = img.Image(width: 120, height: 80);
  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      final channel = (x + y).isEven ? 116 : 119;
      image.setPixel(x, y, img.ColorRgb8(channel, channel, channel));
    }
  }

  // The analysis window is exactly 72x24. Only this off-grid start contains
  // pure black; moving it by one pixel admits gray values that make both the
  // white and black worst-case ratios fail AA.
  img.fillRect(
    image,
    x1: 17,
    y1: 31,
    x2: 88,
    y2: 54,
    color: img.ColorRgb8(0, 0, 0),
  );
  return Uint8List.fromList(img.encodePng(image));
}

Uint8List _edgeDensityOnlyPng() {
  final image = img.Image(width: 120, height: 80);
  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      // Every 72-pixel row segment contains exactly 36 black and 36 gray
      // pixels. The top uses two broad runs (period 72); lower rows alternate
      // every pixel. Thus all 72x24 candidates have the same histogram,
      // variance and conservative contrast, while their edge frequency varies.
      final isGray = y < 24 ? x % 72 >= 36 : x.isEven;
      image.setPixel(
        x,
        y,
        isGray ? img.ColorRgb8(110, 110, 110) : img.ColorRgb8(0, 0, 0),
      );
    }
  }
  return Uint8List.fromList(img.encodePng(image));
}

Uint8List _solid16BitPng(int channel) {
  final image = img.Image(
    width: 120,
    height: 80,
    format: img.Format.uint16,
  );
  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      image.setPixelRgb(x, y, channel, channel, channel);
    }
  }
  return Uint8List.fromList(img.encodePng(image));
}

Uint8List _solidChannelPng({
  required img.Format format,
  required int numChannels,
  required int gray,
  int? alpha,
}) {
  final image = img.Image(
    width: 120,
    height: 80,
    format: format,
    numChannels: numChannels,
  );
  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y)..[0] = gray;
      if (numChannels >= 2) pixel[1] = numChannels == 2 ? alpha! : gray;
      if (numChannels >= 3) pixel[2] = gray;
      if (numChannels == 4) pixel[3] = alpha!;
    }
  }
  return Uint8List.fromList(img.encodePng(image));
}

void _expectEquivalentPlacement(
  TextPlacementSuggestion? actual,
  TextPlacementSuggestion? expected,
) {
  expect(actual, isNotNull);
  expect(expected, isNotNull);
  expect(actual!.region, expected!.region);
  expect(actual.meanLuminance, closeTo(expected.meanLuminance, 0.0000001));
  expect(actual.stdDev, closeTo(expected.stdDev, 0.0000001));
  expect(actual.contrastRatio, closeTo(expected.contrastRatio, 0.0000001));
  expect(actual.useWhiteText, expected.useWhiteText);
}

void main() {
  group('TextPlacementSuggestion', () {
    test('uses actual WCAG contrast to choose black on mid-dark gray', () {
      final suggestion = _analyze(
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
      final suggestion = _analyze(
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
      final suggestion = _analyze(_checkerboardPng());

      expect(suggestion, isNotNull);
      final s = suggestion!;
      // The mean alone would make one color appear readable. The adverse
      // pixel for each color correctly exposes 1:1 contrast.
      expect(s.meanLuminance, closeTo(0.5, 0.001));
      expect(s.contrastRatio, closeTo(1, 0.001));
      expect(s.passesAa, isFalse);
    });

    test('a small adverse patch prevents an unsupported AA claim', () {
      final suggestion = _analyze(
        _sparseAdversePixelsPng(),
      );

      expect(suggestion, isNotNull);
      expect(suggestion!.contrastRatio, closeTo(1, 0.001));
      expect(suggestion.passesAa, isFalse);
    });

    test('AA compliance outranks a calmer non-AA candidate', () {
      final suggestion = _analyze(
        _aaBusyVersusNonAaCalmPng(),
      );

      expect(suggestion, isNotNull);
      expect(suggestion!.passesAa, isTrue);
      expect(suggestion.region.top, closeTo(0, 0.0001));
    });

    test('combined uniformity and edge scoring favors the sparse-detail area',
        () {
      final suggestion = _analyze(
        _calmVersusBusyEqualContrastPng(),
      );

      expect(suggestion, isNotNull);
      final s = suggestion!;
      expect(s.passesAa, isTrue);
      expect(s.region.top, closeTo(31 / 80, 0.0001));
      expect(s.stdDev, lessThan(0.02));
    });

    test('evaluates an off-grid window when it is the only AA candidate', () {
      final suggestion = _analyze(_offGridOnlyAaPng());

      expect(suggestion, isNotNull);
      expect(suggestion!.passesAa, isTrue);
      expect(suggestion.region.left, closeTo(17 / 120, 0.0001));
      expect(suggestion.region.top, closeTo(31 / 80, 0.0001));
      expect(suggestion.useWhiteText, isTrue);
      expect(suggestion.contrastRatio, closeTo(21, 0.0001));
    });

    test('edge density alone favors lower spatial frequency', () {
      final imageData = _edgeDensityOnlyPng();
      final decoded = img.decodePng(imageData)!;
      final suggestion = _analyze(imageData);

      int grayCountAt(int startY) {
        var count = 0;
        for (var y = startY; y < startY + 24; y++) {
          for (var x = 24; x < 96; x++) {
            if (decoded.getPixel(x, y).r == 110) count++;
          }
        }
        return count;
      }

      // These two windows have identical two-value luminance histograms.
      expect(grayCountAt(0), 72 * 24 ~/ 2);
      expect(grayCountAt(56), grayCountAt(0));
      expect(suggestion, isNotNull);
      expect(suggestion!.region.top, closeTo(0, 0.0001));
    });

    test('composites translucent pixels over the explicit viewer backdrop', () {
      final translucentWhite = _analyze(
        _solidRgbaPng(img.ColorRgba8(255, 255, 255, 128)),
      );
      final translucentBlack = _analyze(
        _solidRgbaPng(img.ColorRgba8(0, 0, 0, 128)),
        backdropColor: Colors.white,
      );

      final whiteOverBlack =
          TextPlacementService.relativeLuminance(128, 128, 128);
      final blackOverWhite =
          TextPlacementService.relativeLuminance(127, 127, 127);
      expect(translucentWhite, isNotNull);
      expect(translucentWhite!.useWhiteText, isFalse);
      expect(
        translucentWhite.contrastRatio,
        closeTo(ColorContrast.contrastRatio(whiteOverBlack, 0), 0.0001),
      );
      expect(translucentBlack, isNotNull);
      expect(translucentBlack!.useWhiteText, isFalse);
      expect(
        translucentBlack.contrastRatio,
        closeTo(ColorContrast.contrastRatio(blackOverWhite, 0), 0.0001),
      );
    });

    test('normalizes 16-bit PNG channels before computing luminance', () {
      const channel = 149 * 257;
      final imageData = _solid16BitPng(channel);
      final decoded = img.decodePng(imageData);
      final suggestion = _analyze(imageData);

      expect(decoded, isNotNull);
      expect(decoded!.bitsPerChannel, 16);
      expect(decoded.getPixel(0, 0).rNormalized, closeTo(149 / 255, 0.0001));
      expect(suggestion, isNotNull);
      expect(suggestion!.useWhiteText, isFalse);
      expect(suggestion.contrastRatio, closeTo(7, 0.1));
    });

    test('treats grayscale pixels like equivalent RGB pixels', () {
      final grayscaleData = _solidChannelPng(
        format: img.Format.uint8,
        numChannels: 1,
        gray: 149,
      );
      final rgbData = _solidChannelPng(
        format: img.Format.uint8,
        numChannels: 3,
        gray: 149,
      );
      final grayscale = img.decodePng(grayscaleData)!;
      final rgb = img.decodePng(rgbData)!;

      expect(grayscale.numChannels, 1);
      expect(rgb.numChannels, 3);
      expect(
        TextPlacementService.relativeLuminanceFromPixel(
          grayscale.getPixel(0, 0),
          backdropColor: Colors.black,
        ),
        closeTo(
          TextPlacementService.relativeLuminanceFromPixel(
            rgb.getPixel(0, 0),
            backdropColor: Colors.black,
          ),
          0.0000001,
        ),
      );
      _expectEquivalentPlacement(
        _analyze(grayscaleData),
        _analyze(rgbData),
      );
    });

    test('treats 16-bit grayscale-alpha like equivalent RGBA', () {
      const gray = 149 * 257;
      const alpha = 128 * 257;
      const backdrop = Color(0xff204060);
      final grayscaleAlphaData = _solidChannelPng(
        format: img.Format.uint16,
        numChannels: 2,
        gray: gray,
        alpha: alpha,
      );
      final rgbaData = _solidChannelPng(
        format: img.Format.uint16,
        numChannels: 4,
        gray: gray,
        alpha: alpha,
      );
      final grayscaleAlpha = img.decodePng(grayscaleAlphaData)!;
      final rgba = img.decodePng(rgbaData)!;

      expect(grayscaleAlpha.bitsPerChannel, 16);
      expect(grayscaleAlpha.numChannels, 2);
      expect(rgba.bitsPerChannel, 16);
      expect(rgba.numChannels, 4);
      expect(
        TextPlacementService.relativeLuminanceFromPixel(
          grayscaleAlpha.getPixel(0, 0),
          backdropColor: backdrop,
        ),
        closeTo(
          TextPlacementService.relativeLuminanceFromPixel(
            rgba.getPixel(0, 0),
            backdropColor: backdrop,
          ),
          0.0000001,
        ),
      );
      _expectEquivalentPlacement(
        _analyze(grayscaleAlphaData, backdropColor: backdrop),
        _analyze(rgbaData, backdropColor: backdrop),
      );
    });

    test('breaks equal-readability ties toward a lower-centre banner', () {
      final image = _solidPng(img.ColorRgb8(149, 149, 149));
      final first = _analyze(image);
      final second = _analyze(image);

      expect(first, isNotNull);
      expect(second, isNotNull);
      expect(first!.region, second!.region);
      expect(first.region.left, closeTo(0.2, 0.0001));
      expect(first.region.top, closeTo(0.65, 0.0001));
    });

    test('returns null without throwing for undecodable data', () {
      final corrupt = Uint8List.fromList(
        List.generate(32, (index) => (index * 37 + 11) & 0xff),
      );

      expect(_analyze(Uint8List(4)), isNull);
      expect(_analyze(corrupt), isNull);
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
