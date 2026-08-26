import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photocanvas/models/accessibility_report.dart';
import 'package:photocanvas/models/image_analysis.dart';

void main() {
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
  });
}
