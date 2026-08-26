import 'package:flutter/material.dart';

/// WCAG 2.1 contrast measurements of a single color against pure
/// white and black text, the two most common overlay choices.
@immutable
class ColorContrast {
  const ColorContrast({
    required this.color,
    required this.contrastWithWhite,
    required this.contrastWithBlack,
  });

  static const double aaThreshold = 4.5;
  static const double aaaThreshold = 7;

  final Color color;
  final double contrastWithWhite;
  final double contrastWithBlack;

  bool passesAaWithWhite() => contrastWithWhite >= aaThreshold;

  bool passesAaaWithWhite() => contrastWithWhite >= aaaThreshold;

  bool passesAaWithBlack() => contrastWithBlack >= aaThreshold;

  bool passesAaaWithBlack() => contrastWithBlack >= aaaThreshold;

  /// Whether white or black is the stronger text choice on [color].
  bool get prefersWhiteText => contrastWithWhite >= contrastWithBlack;

  /// WCAG 2.1 contrast ratio between two relative luminances; either may
  /// be the lighter one so callers pass them in any order.
  static double contrastRatio(double a, double b) {
    final lighter = a > b ? a : b;
    final darker = a > b ? b : a;
    return (lighter + 0.05) / (darker + 0.05);
  }
}

/// Accessibility summary computed once per loaded image.
@immutable
class AccessibilityReport {
  const AccessibilityReport({
    required this.averageLuminance,
    required this.colorContrasts,
  });

  /// Perceived brightness of the whole image, 0.0 (black) to 1.0 (white).
  final double averageLuminance;
  final List<ColorContrast> colorContrasts;

  /// Percentage of palette colors readable with white text per WCAG AA.
  double get aaWhiteTextCoverage {
    if (colorContrasts.isEmpty) return 0;
    final passing = colorContrasts.where((c) => c.passesAaWithWhite()).length;
    return passing / colorContrasts.length;
  }

  /// Contrast ratio of pure white text against the image's average
  /// perceived brightness.
  double get whiteTextRatio => ColorContrast.contrastRatio(1, averageLuminance);

  /// Contrast ratio of pure black text against the image's average
  /// perceived brightness.
  double get blackTextRatio => ColorContrast.contrastRatio(averageLuminance, 0);

  /// Whether pure white or pure black is the stronger overlay choice
  /// overall, based on which has the larger contrast margin.
  bool get recommendsWhiteText => whiteTextRatio >= blackTextRatio;

  /// Contrast ratio achieved by the recommended overlay text color.
  double get recommendedTextRatio =>
      recommendsWhiteText ? whiteTextRatio : blackTextRatio;

  bool get recommendedPassesAa =>
      recommendedTextRatio >= ColorContrast.aaThreshold;

  bool get recommendedPassesAaa =>
      recommendedTextRatio >= ColorContrast.aaaThreshold;

  /// Short guidance for overlaying text on this image.
  String get textRecommendation {
    if (averageLuminance >= 0.6) {
      return 'Bright image — dark text overlays will read best';
    }
    if (averageLuminance <= 0.3) {
      return 'Dark image — light text overlays will read best';
    }
    return 'Mid-tone image — verify text contrast before overlaying';
  }
}
