import 'package:flutter/material.dart';
import 'package:photocanvas/models/accessibility_report.dart';

/// Where overlay text should sit on an image so it stays readable.
///
/// [region] is normalized to the image size (0..1 on both axes) so the UI
/// can map it onto any rendered dimension.
@immutable
class TextPlacementSuggestion {
  const TextPlacementSuggestion({
    required this.region,
    required this.meanLuminance,
    required this.stdDev,
    required this.contrastRatio,
    required this.useWhiteText,
  });

  /// Best rectangle for text, normalized to the image dimensions.
  final Rect region;

  /// Average perceived brightness inside [region], 0.0 to 1.0.
  final double meanLuminance;

  /// Luminance standard deviation inside [region]; low means flat/uniform,
  /// which keeps text legible.
  final double stdDev;

  /// Conservative WCAG contrast ratio of the suggested text color against
  /// the varying pixels in [region].
  final double contrastRatio;

  /// Whether white text has the stronger conservative contrast in [region].
  final bool useWhiteText;

  /// The suggested overlay text color.
  Color get textColor => useWhiteText ? Colors.white : Colors.black;

  bool get passesAa => contrastRatio >= ColorContrast.aaThreshold;
}
