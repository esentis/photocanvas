import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show Rect;

import 'package:image/image.dart' as img;
import 'package:photocanvas/models/accessibility_report.dart';
import 'package:photocanvas/models/text_placement.dart';

/// Pure image-math service: locates the most readable rectangle for
/// overlay text on an image. Deliberately free of web-only dependencies
/// so it stays unit-testable.
abstract final class TextPlacementService {
  /// Sliding windows are scored primarily by conservative WCAG contrast, then
  /// by luminance uniformity and visual calm. Integral images keep the
  /// variance and edge-density parts of every candidate evaluation O(1).
  static TextPlacementSuggestion? analyze(Uint8List imageData) {
    final image = _tryDecode(imageData);
    if (image == null) return null;

    return _analyzeDecoded(image);
  }

  /// Decoding arbitrary bytes can throw inside format probes; a placement
  /// suggestion must never be the reason a drop fails.
  static img.Image? _tryDecode(Uint8List imageData) {
    if (imageData.length < 16) return null;
    try {
      return img.decodeImage(imageData);
    } on Exception {
      return null;
    }
  }

  static TextPlacementSuggestion? _analyzeDecoded(img.Image image) {
    final width = image.width;
    final height = image.height;
    if (width < 16 || height < 16) return null;

    // Row-major relative luminance of every pixel.
    final lum = Float64List(width * height);
    var index = 0;
    for (final pixel in image.data!) {
      lum[index++] = relativeLuminance(pixel.r, pixel.g, pixel.b);
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
    final stepX = (winW / 4).floor().clamp(1, winW);
    final stepY = (winH / 4).floor().clamp(1, winH);
    final maxX = width - winW;
    final maxY = height - winH;
    final preferredX = (width * 0.5 - winW / 2).round().clamp(0, maxX);
    final preferredY = (height * 0.8 - winH / 2).round().clamp(0, maxY);
    final xCandidates = _candidateStarts(maxX, stepX, preferredX);
    final yCandidates = _candidateStarts(maxY, stepY, preferredY);

    var bestScore = -1.0;
    var bestAestheticScore = -double.infinity;
    var bestX = 0;
    var bestY = 0;
    var bestMean = 0.0;
    var bestStdDev = 0.0;
    var bestContrastRatio = 1.0;
    var bestUseWhiteText = true;

    for (final y in yCandidates) {
      for (final x in xCandidates) {
        final n = (winW * winH).toDouble();
        final mean = windowSum(sum, x, y, winW, winH) / n;
        final variance = (windowSum(sumSq, x, y, winW, winH) / n - mean * mean)
            .clamp(0.0, 1.0);
        final stdDev = math.sqrt(variance);

        // WCAG contrast is evaluated separately for white and black using
        // conservative background percentiles. A mean can hide unreadable
        // pixels, while the bright/dark tails expose them.
        final contrast = _evaluateContrast(lum, width, x, y, winW, winH);

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
          score: score,
          aestheticScore: aestheticScore,
          x: x,
          y: y,
          bestScore: bestScore,
          bestAestheticScore: bestAestheticScore,
          bestX: bestX,
          bestY: bestY,
        )) {
          bestScore = score;
          bestAestheticScore = aestheticScore;
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

  /// Produces all stepped starts plus the exact preferred and far-edge starts.
  /// Including [maxStart] guarantees that right/bottom-aligned regions are
  /// considered even when the step does not divide the available space.
  static List<int> _candidateStarts(
    int maxStart,
    int step,
    int preferredStart,
  ) {
    final starts = <int>{0, preferredStart, maxStart};
    for (var start = 0; start <= maxStart; start += step) {
      starts.add(start);
    }
    return starts.toList()..sort();
  }

  /// Uses the 90th luminance percentile for white text and the 10th for black.
  /// Those are the adverse tails for each color and avoid the false confidence
  /// that a regional mean can create, while ignoring isolated compression noise.
  static _ContrastEvaluation _evaluateContrast(
    Float64List luminance,
    int imageWidth,
    int x,
    int y,
    int width,
    int height,
  ) {
    const histogramSize = 256;
    final histogram = Uint32List(histogramSize);
    final bucketMinimum = Float64List(histogramSize)
      ..fillRange(0, histogramSize, double.infinity);
    final bucketMaximum = Float64List(histogramSize)
      ..fillRange(0, histogramSize, -double.infinity);
    for (var sampleY = y; sampleY < y + height; sampleY++) {
      final rowOffset = sampleY * imageWidth;
      for (var sampleX = x; sampleX < x + width; sampleX++) {
        final value = luminance[rowOffset + sampleX];
        final bucket = (value * (histogramSize - 1)).floor();
        histogram[bucket]++;
        bucketMinimum[bucket] = math.min(bucketMinimum[bucket], value);
        bucketMaximum[bucket] = math.max(bucketMaximum[bucket], value);
      }
    }

    final pixelCount = width * height;
    final darkBackground = _percentileFromHistogram(
      histogram,
      bucketMinimum,
      bucketMaximum,
      pixelCount,
      0.10,
      useUpperBucketValue: false,
    );
    final brightBackground = _percentileFromHistogram(
      histogram,
      bucketMinimum,
      bucketMaximum,
      pixelCount,
      0.90,
      useUpperBucketValue: true,
    );
    final whiteRatio = ColorContrast.contrastRatio(1, brightBackground);
    final blackRatio = ColorContrast.contrastRatio(darkBackground, 0);
    final useWhiteText = whiteRatio >= blackRatio;
    return _ContrastEvaluation(
      ratio: useWhiteText ? whiteRatio : blackRatio,
      useWhiteText: useWhiteText,
    );
  }

  static double _percentileFromHistogram(
    Uint32List histogram,
    Float64List bucketMinimum,
    Float64List bucketMaximum,
    int count,
    double percentile, {
    required bool useUpperBucketValue,
  }) {
    final target = math.max(1, (count * percentile).ceil());
    var seen = 0;
    for (var bucket = 0; bucket < histogram.length; bucket++) {
      seen += histogram[bucket];
      if (seen >= target) {
        return useUpperBucketValue
            ? bucketMaximum[bucket]
            : bucketMinimum[bucket];
      }
    }
    return 1;
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
    required double score,
    required double aestheticScore,
    required int x,
    required int y,
    required double bestScore,
    required double bestAestheticScore,
    required int bestX,
    required int bestY,
  }) {
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
  static double linearChannel(num channel) {
    final c = channel / 255;
    return c <= 0.03928
        ? c / 12.92
        : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
  }

  /// WCAG relative luminance from 0-255 sRGB channels.
  static double relativeLuminance(num r, num g, num b) =>
      linearChannel(r) * 0.2126 +
      linearChannel(g) * 0.7152 +
      linearChannel(b) * 0.0722;
}

class _ContrastEvaluation {
  const _ContrastEvaluation({required this.ratio, required this.useWhiteText});

  final double ratio;
  final bool useWhiteText;
}
