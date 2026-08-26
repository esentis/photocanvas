import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show Color, Rect;

import 'package:image/image.dart' as img;
import 'package:photocanvas/models/accessibility_report.dart';
import 'package:photocanvas/models/text_placement.dart';

/// Pure image-math service: locates the most readable rectangle for
/// overlay text on an image. Deliberately free of web-only dependencies
/// so it stays unit-testable.
abstract final class TextPlacementService {
  /// Sliding windows are scored primarily by conservative WCAG contrast, then
  /// by luminance uniformity and visual calm. The image is composited over the
  /// same explicit opaque [backdropColor] used by its viewer before any
  /// luminance is measured.
  ///
  /// Integral images and separable sliding extrema keep every candidate
  /// evaluation O(1), allowing every valid integer window start to be tested
  /// in O(image area) total time.
  static TextPlacementSuggestion? analyze(
    Uint8List imageData, {
    required Color backdropColor,
  }) {
    _validateOpaqueBackdrop(backdropColor);
    final image = _tryDecode(imageData);
    if (image == null) return null;

    return _analyzeDecoded(
      image,
      _NormalizedBackdrop.fromColor(backdropColor),
    );
  }

  /// Decoding arbitrary bytes can throw inside format probes; a placement
  /// suggestion must never be the reason a drop fails.
  static img.Image? _tryDecode(Uint8List imageData) {
    if (imageData.length < 16) return null;
    try {
      return img.decodeImage(imageData);
    } on Object catch (_) {
      return null;
    }
  }

  static TextPlacementSuggestion? _analyzeDecoded(
    img.Image image,
    _NormalizedBackdrop backdrop,
  ) {
    final width = image.width;
    final height = image.height;
    if (width < 16 || height < 16) return null;

    // Row-major relative luminance of every pixel.
    final lum = Float64List(width * height);
    var index = 0;
    for (final pixel in image.data!) {
      lum[index++] = _relativeLuminanceFromPixel(
        pixel,
        backdrop: backdrop,
      );
    }

    // Integral sums of luminance, squared luminance, and adjacent-pixel edge
    // strength. Horizontal and vertical edges stay separate so a candidate is
    // not penalized for a contrast boundary immediately outside its region.
    final stride = width + 1;
    final sum = Float64List(stride * (height + 1));
    final sumSq = Float64List(stride * (height + 1));
    final horizontalEdges = Float64List(stride * (height + 1));
    final verticalEdges = Float64List(stride * (height + 1));
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final l = lum[y * width + x];
        final i = (y + 1) * stride + (x + 1);
        sum[i] = l + sum[i - 1] + sum[i - stride] - sum[i - stride - 1];
        sumSq[i] =
            l * l + sumSq[i - 1] + sumSq[i - stride] - sumSq[i - stride - 1];
        final horizontalEdge =
            x == 0 ? 0.0 : (l - lum[y * width + x - 1]).abs();
        final verticalEdge =
            y == 0 ? 0.0 : (l - lum[(y - 1) * width + x]).abs();
        horizontalEdges[i] = horizontalEdge +
            horizontalEdges[i - 1] +
            horizontalEdges[i - stride] -
            horizontalEdges[i - stride - 1];
        verticalEdges[i] = verticalEdge +
            verticalEdges[i - 1] +
            verticalEdges[i - stride] -
            verticalEdges[i - stride - 1];
      }
    }

    double windowSum(Float64List table, int x, int y, int w, int h) =>
        table[(y + h) * stride + (x + w)] -
        table[y * stride + (x + w)] -
        table[(y + h) * stride + x] +
        table[y * stride + x];

    // Search window ≈ a classic lower-third banner, position-free.
    final winW = (width * 0.6).round().clamp(8, width);
    final winH = (height * 0.3).round().clamp(6, height);
    final maxX = width - winW;
    final maxY = height - winH;
    final extrema = _slidingWindowExtrema(
      lum,
      imageWidth: width,
      imageHeight: height,
      windowWidth: winW,
      windowHeight: winH,
    );

    var bestScore = -1.0;
    var bestAestheticScore = -double.infinity;
    var bestPassesAa = false;
    var bestX = 0;
    var bestY = 0;
    var bestMean = 0.0;
    var bestStdDev = 0.0;
    var bestContrastRatio = 1.0;
    var bestUseWhiteText = true;

    for (var y = 0; y <= maxY; y++) {
      for (var x = 0; x <= maxX; x++) {
        final n = (winW * winH).toDouble();
        final mean = windowSum(sum, x, y, winW, winH) / n;
        final variance = (windowSum(sumSq, x, y, winW, winH) / n - mean * mean)
            .clamp(0.0, 1.0);
        final stdDev = math.sqrt(variance);

        // WCAG contrast is evaluated separately for white and black against
        // the adverse pixel for that text color. A mean or percentile can
        // hide a small unreadable patch; extrema make the displayed AA claim
        // true for every pixel that this candidate contains.
        final extremaIndex = y * (maxX + 1) + x;
        final contrast = _evaluateContrast(
          darkestBackground: extrema.minimum[extremaIndex],
          brightestBackground: extrema.maximum[extremaIndex],
        );
        final passesAa = contrast.ratio >= ColorContrast.aaThreshold;

        final horizontalEdgeCount = (winW - 1) * winH;
        final verticalEdgeCount = winW * (winH - 1);
        final edgeCount = horizontalEdgeCount + verticalEdgeCount;
        final horizontalEdgeSum = winW > 1
            ? windowSum(horizontalEdges, x + 1, y, winW - 1, winH)
            : 0.0;
        final verticalEdgeSum =
            winH > 1 ? windowSum(verticalEdges, x, y + 1, winW, winH - 1) : 0.0;
        final edgeDensity = edgeCount == 0
            ? 0.0
            : (horizontalEdgeSum + verticalEdgeSum) / edgeCount;

        final contrastQuality = ((contrast.ratio - 1) / 20).clamp(0.0, 1.0);
        final uniformity = 1 - (stdDev * 2).clamp(0.0, 1.0);
        final visualCalm = 1 - (edgeDensity * 4).clamp(0.0, 1.0);
        final score =
            contrastQuality * 0.72 + uniformity * 0.18 + visualCalm * 0.10;
        final aestheticScore = _aestheticScore(
          x: x,
          y: y,
          width: width,
          height: height,
          windowWidth: winW,
          windowHeight: winH,
        );

        if (_isBetterCandidate(
          passesAa: passesAa,
          score: score,
          aestheticScore: aestheticScore,
          x: x,
          y: y,
          bestScore: bestScore,
          bestAestheticScore: bestAestheticScore,
          bestPassesAa: bestPassesAa,
          bestX: bestX,
          bestY: bestY,
        )) {
          bestScore = score;
          bestAestheticScore = aestheticScore;
          bestPassesAa = passesAa;
          bestX = x;
          bestY = y;
          bestMean = mean;
          bestStdDev = stdDev;
          bestContrastRatio = contrast.ratio;
          bestUseWhiteText = contrast.useWhiteText;
        }
      }
    }

    final region = Rect.fromLTWH(
      bestX / width,
      bestY / height,
      winW / width,
      winH / height,
    );

    return TextPlacementSuggestion(
      region: region,
      meanLuminance: bestMean,
      stdDev: bestStdDev,
      contrastRatio: bestContrastRatio,
      useWhiteText: bestUseWhiteText,
    );
  }

  /// Returns the stronger text color's worst contrast against this region.
  ///
  /// White text is weakest against the brightest pixel and black text is
  /// weakest against the darkest pixel. Comparing those two minima produces a
  /// conservative ratio that applies to every analyzed pixel in the region.
  static _ContrastEvaluation _evaluateContrast({
    required double darkestBackground,
    required double brightestBackground,
  }) {
    final whiteRatio = ColorContrast.contrastRatio(1, brightestBackground);
    final blackRatio = ColorContrast.contrastRatio(darkestBackground, 0);
    final useWhiteText = whiteRatio >= blackRatio;
    return _ContrastEvaluation(
      ratio: useWhiteText ? whiteRatio : blackRatio,
      useWhiteText: useWhiteText,
    );
  }

  /// Computes each window's minimum and maximum luminance with monotonic
  /// deques: horizontal passes reduce rows to window-width extrema, then
  /// vertical passes reduce those values to full 2D window extrema.
  static _WindowExtrema _slidingWindowExtrema(
    Float64List luminance, {
    required int imageWidth,
    required int imageHeight,
    required int windowWidth,
    required int windowHeight,
  }) {
    final outputWidth = imageWidth - windowWidth + 1;
    final outputHeight = imageHeight - windowHeight + 1;
    final horizontalMinimum = Float64List(outputWidth * imageHeight);
    final horizontalMaximum = Float64List(outputWidth * imageHeight);
    final minimumDeque = Int32List(math.max(imageWidth, imageHeight));
    final maximumDeque = Int32List(math.max(imageWidth, imageHeight));

    for (var y = 0; y < imageHeight; y++) {
      final inputRow = y * imageWidth;
      final outputRow = y * outputWidth;
      var minimumHead = 0;
      var minimumTail = 0;
      var maximumHead = 0;
      var maximumTail = 0;

      for (var x = 0; x < imageWidth; x++) {
        final expired = x - windowWidth;
        if (minimumHead < minimumTail && minimumDeque[minimumHead] <= expired) {
          minimumHead++;
        }
        if (maximumHead < maximumTail && maximumDeque[maximumHead] <= expired) {
          maximumHead++;
        }

        final value = luminance[inputRow + x];
        while (minimumHead < minimumTail &&
            luminance[inputRow + minimumDeque[minimumTail - 1]] >= value) {
          minimumTail--;
        }
        while (maximumHead < maximumTail &&
            luminance[inputRow + maximumDeque[maximumTail - 1]] <= value) {
          maximumTail--;
        }
        minimumDeque[minimumTail++] = x;
        maximumDeque[maximumTail++] = x;

        if (x >= windowWidth - 1) {
          final outputX = x - windowWidth + 1;
          horizontalMinimum[outputRow + outputX] =
              luminance[inputRow + minimumDeque[minimumHead]];
          horizontalMaximum[outputRow + outputX] =
              luminance[inputRow + maximumDeque[maximumHead]];
        }
      }
    }

    final minimum = Float64List(outputWidth * outputHeight);
    final maximum = Float64List(outputWidth * outputHeight);
    for (var x = 0; x < outputWidth; x++) {
      var minimumHead = 0;
      var minimumTail = 0;
      var maximumHead = 0;
      var maximumTail = 0;

      for (var y = 0; y < imageHeight; y++) {
        final expired = y - windowHeight;
        if (minimumHead < minimumTail && minimumDeque[minimumHead] <= expired) {
          minimumHead++;
        }
        if (maximumHead < maximumTail && maximumDeque[maximumHead] <= expired) {
          maximumHead++;
        }

        final valueIndex = y * outputWidth + x;
        final minimumValue = horizontalMinimum[valueIndex];
        final maximumValue = horizontalMaximum[valueIndex];
        while (minimumHead < minimumTail &&
            horizontalMinimum[
                    minimumDeque[minimumTail - 1] * outputWidth + x] >=
                minimumValue) {
          minimumTail--;
        }
        while (maximumHead < maximumTail &&
            horizontalMaximum[
                    maximumDeque[maximumTail - 1] * outputWidth + x] <=
                maximumValue) {
          maximumTail--;
        }
        minimumDeque[minimumTail++] = y;
        maximumDeque[maximumTail++] = y;

        if (y >= windowHeight - 1) {
          final outputY = y - windowHeight + 1;
          final outputIndex = outputY * outputWidth + x;
          minimum[outputIndex] =
              horizontalMinimum[minimumDeque[minimumHead] * outputWidth + x];
          maximum[outputIndex] =
              horizontalMaximum[maximumDeque[maximumHead] * outputWidth + x];
        }
      }
    }

    return _WindowExtrema(minimum: minimum, maximum: maximum);
  }

  /// A lower-centre banner is the deliberate tie preference. A final explicit
  /// y/x ordering makes even geometrically symmetric ties deterministic.
  static double _aestheticScore({
    required int x,
    required int y,
    required int width,
    required int height,
    required int windowWidth,
    required int windowHeight,
  }) {
    final centerX = (x + windowWidth / 2) / width;
    final centerY = (y + windowHeight / 2) / height;
    return -math.sqrt(
      math.pow(centerX - 0.5, 2) + math.pow(centerY - 0.8, 2),
    );
  }

  static bool _isBetterCandidate({
    required bool passesAa,
    required double score,
    required double aestheticScore,
    required int x,
    required int y,
    required double bestScore,
    required double bestAestheticScore,
    required bool bestPassesAa,
    required int bestX,
    required int bestY,
  }) {
    // Candidate comparison is lexicographic. WCAG AA compliance is the hard
    // primary tier, so no failing region can outrank a passing one regardless
    // of how calm it looks. The weighted contrast/uniformity/edge score is
    // compared only within that tier, followed by the aesthetic tie-breakers.
    if (passesAa != bestPassesAa) return passesAa;

    // Integral-image arithmetic can differ by a few ulps between otherwise
    // identical windows, so treat sub-millionth score changes as a real tie.
    const epsilon = 0.000001;
    if (score > bestScore + epsilon) return true;
    if ((score - bestScore).abs() > epsilon) return false;
    if (aestheticScore > bestAestheticScore + epsilon) return true;
    if ((aestheticScore - bestAestheticScore).abs() > epsilon) return false;
    if (y != bestY) return y > bestY;
    return x < bestX;
  }

  /// sRGB channel to linear-light conversion per WCAG 2.1.
  static double linearChannel(num channel) =>
      linearNormalizedChannel(channel / 255);

  /// Normalized sRGB channel to linear-light conversion per WCAG 2.1.
  static double linearNormalizedChannel(num channel) {
    final c = channel.toDouble().clamp(0.0, 1.0);
    return c <= 0.03928
        ? c / 12.92
        : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
  }

  /// WCAG relative luminance from 0-255 sRGB channels.
  static double relativeLuminance(num r, num g, num b) =>
      relativeLuminanceNormalized(r / 255, g / 255, b / 255);

  /// WCAG relative luminance from normalized 0..1 sRGB channels.
  static double relativeLuminanceNormalized(num r, num g, num b) =>
      linearNormalizedChannel(r) * 0.2126 +
      linearNormalizedChannel(g) * 0.7152 +
      linearNormalizedChannel(b) * 0.0722;

  /// WCAG relative luminance for an image-package pixel of any channel depth.
  /// Non-palette grayscale pixels are expanded to RGB explicitly because the
  /// package's normalized color accessors are inconsistent for one- and
  /// two-channel pixel implementations. Palette pixels keep using their
  /// palette-expanded accessors.
  /// If [backdropColor] is supplied, source-over alpha compositing is applied
  /// in normalized sRGB before the transfer function, matching how the viewer
  /// paints the image over its opaque backdrop. Omitting it preserves the
  /// original API behavior for callers analyzing raw RGB independently.
  static double relativeLuminanceFromPixel(
    img.Pixel pixel, {
    Color? backdropColor,
  }) {
    _NormalizedBackdrop? backdrop;
    if (backdropColor != null) {
      _validateOpaqueBackdrop(backdropColor);
      backdrop = _NormalizedBackdrop.fromColor(backdropColor);
    }
    return _relativeLuminanceFromPixel(pixel, backdrop: backdrop);
  }

  static double _relativeLuminanceFromPixel(
    img.Pixel pixel, {
    _NormalizedBackdrop? backdrop,
  }) {
    late double r;
    late double g;
    late double b;
    var alpha = 1.0;

    if (!pixel.hasPalette && (pixel.length == 1 || pixel.length == 2)) {
      final gray = _normalizedPixelChannel(pixel[0], pixel.maxChannelValue);
      r = gray;
      g = gray;
      b = gray;
      if (pixel.length == 2) {
        alpha = _normalizedPixelChannel(pixel[1], pixel.maxChannelValue);
      }
    } else {
      // Palette accessors expand the stored index through the palette. They
      // are also reliable for ordinary RGB/RGBA pixels.
      r = pixel.rNormalized.toDouble().clamp(0.0, 1.0);
      g = pixel.gNormalized.toDouble().clamp(0.0, 1.0);
      b = pixel.bNormalized.toDouble().clamp(0.0, 1.0);
      if (pixel.length == 2 || pixel.length == 4) {
        alpha = pixel.aNormalized.toDouble().clamp(0.0, 1.0);
      }
    }

    if (backdrop != null) {
      final inverseAlpha = 1 - alpha;
      r = r * alpha + backdrop.r * inverseAlpha;
      g = g * alpha + backdrop.g * inverseAlpha;
      b = b * alpha + backdrop.b * inverseAlpha;
    }
    return relativeLuminanceNormalized(r, g, b);
  }

  static double _normalizedPixelChannel(num channel, num maxChannelValue) =>
      (channel / maxChannelValue).clamp(0.0, 1.0);

  static void _validateOpaqueBackdrop(Color backdropColor) {
    if ((backdropColor.toARGB32() >>> 24) != 0xff) {
      throw ArgumentError.value(
        backdropColor,
        'backdropColor',
        'must be fully opaque so analysis matches rendering',
      );
    }
  }
}

class _ContrastEvaluation {
  const _ContrastEvaluation({required this.ratio, required this.useWhiteText});

  final double ratio;
  final bool useWhiteText;
}

class _WindowExtrema {
  const _WindowExtrema({required this.minimum, required this.maximum});

  final Float64List minimum;
  final Float64List maximum;
}

class _NormalizedBackdrop {
  const _NormalizedBackdrop({
    required this.r,
    required this.g,
    required this.b,
  });

  factory _NormalizedBackdrop.fromColor(Color color) {
    final argb = color.toARGB32();
    return _NormalizedBackdrop(
      r: ((argb >> 16) & 0xff) / 255,
      g: ((argb >> 8) & 0xff) / 255,
      b: (argb & 0xff) / 255,
    );
  }

  final double r;
  final double g;
  final double b;
}
