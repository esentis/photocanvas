import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:photocanvas/models/accessibility_report.dart';
import 'package:photocanvas/models/image_analysis.dart';

// Sentinel object for copyWith method
const Object _sentinel = Object();

@immutable
class HomePageState {
  const HomePageState({
    this.containerColor = Colors.white,
    this.containerText = 'Drop your image here',
    this.focusedColorHex = '',
    this.paletteGenerator,
    this.activeColors = const [],
    this.imageData,
    this.showOverlay = false,
    this.pinnedDetailedColors = false,
    this.copiedColor,
    this.imageAnalysis,
    this.accessibilityReport,
  });

  final Color containerColor;
  final String containerText;
  final String focusedColorHex;
  final PaletteGenerator? paletteGenerator;
  final List<Color> activeColors;
  final Uint8List? imageData;
  final bool showOverlay;
  final bool pinnedDetailedColors;
  final Color? copiedColor;

  /// Metadata of the originally dropped file.
  final ImageAnalysis? imageAnalysis;
  final AccessibilityReport? accessibilityReport;

  HomePageState copyWith({
    Color? containerColor,
    String? containerText,
    String? focusedColorHex,
    Object? paletteGenerator = _sentinel,
    List<Color>? activeColors,
    Object? imageData = _sentinel,
    bool? showOverlay,
    bool? pinnedDetailedColors,
    Object? copiedColor = _sentinel,
    Object? imageAnalysis = _sentinel,
    Object? accessibilityReport = _sentinel,
  }) {
    return HomePageState(
      containerColor: containerColor ?? this.containerColor,
      containerText: containerText ?? this.containerText,
      focusedColorHex: focusedColorHex ?? this.focusedColorHex,
      paletteGenerator: paletteGenerator == _sentinel
          ? this.paletteGenerator
          : paletteGenerator as PaletteGenerator?,
      activeColors: activeColors ?? this.activeColors,
      imageData:
          imageData == _sentinel ? this.imageData : imageData as Uint8List?,
      showOverlay: showOverlay ?? this.showOverlay,
      pinnedDetailedColors: pinnedDetailedColors ?? this.pinnedDetailedColors,
      copiedColor:
          copiedColor == _sentinel ? this.copiedColor : copiedColor as Color?,
      imageAnalysis: imageAnalysis == _sentinel
          ? this.imageAnalysis
          : imageAnalysis as ImageAnalysis?,
      accessibilityReport: accessibilityReport == _sentinel
          ? this.accessibilityReport
          : accessibilityReport as AccessibilityReport?,
    );
  }

  /// Clear all image-related data
  HomePageState clearImage() {
    return copyWith(
      imageData: null,
      paletteGenerator: null,
      activeColors: const [],
      copiedColor: null,
      containerColor: Colors.white,
      containerText: 'Drop your image here',
      imageAnalysis: null,
      accessibilityReport: null,
    );
  }

  /// Check if an image is loaded
  bool get hasImage => imageData != null;

  /// Check if there's a valid palette
  bool get hasPalette => paletteGenerator != null;

  /// Check if there's a dominant color available
  bool get hasDominantColor => paletteGenerator?.dominantColor?.color != null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is HomePageState &&
        other.containerColor == containerColor &&
        other.containerText == containerText &&
        other.focusedColorHex == focusedColorHex &&
        other.paletteGenerator == paletteGenerator &&
        other.activeColors == activeColors &&
        other.imageData == imageData &&
        other.showOverlay == showOverlay &&
        other.pinnedDetailedColors == pinnedDetailedColors &&
        other.copiedColor == copiedColor &&
        other.imageAnalysis == imageAnalysis &&
        other.accessibilityReport == accessibilityReport;
  }

  @override
  int get hashCode {
    return Object.hashAll([
      containerColor,
      containerText,
      focusedColorHex,
      paletteGenerator,
      activeColors,
      imageData,
      showOverlay,
      pinnedDetailedColors,
      copiedColor,
      imageAnalysis,
      accessibilityReport,
    ]);
  }
}
