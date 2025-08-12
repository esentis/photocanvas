import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

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
    this.hovering = false,
    this.pinnedDetailedColors = false,
    this.dx,
    this.dy,
    this.hoveredColor,
    this.copiedColor,
    this.localDx,
    this.localDy,
  });

  final Color containerColor;
  final String containerText;
  final String focusedColorHex;
  final PaletteGenerator? paletteGenerator;
  final List<Color> activeColors;
  final Uint8List? imageData;
  final bool showOverlay;
  final bool hovering;
  final bool pinnedDetailedColors;
  final int? dx;
  final int? dy;
  final Color? hoveredColor;
  final Color? copiedColor;
  final double? localDx;
  final double? localDy;

  HomePageState copyWith({
    Color? containerColor,
    String? containerText,
    String? focusedColorHex,
    Object? paletteGenerator = _sentinel,
    List<Color>? activeColors,
    Object? imageData = _sentinel,
    bool? showOverlay,
    bool? hovering,
    bool? pinnedDetailedColors,
    Object? dx = _sentinel,
    Object? dy = _sentinel,
    Object? hoveredColor = _sentinel,
    Object? copiedColor = _sentinel,
    Object? localDx = _sentinel,
    Object? localDy = _sentinel,
  }) {
    return HomePageState(
      containerColor: containerColor ?? this.containerColor,
      containerText: containerText ?? this.containerText,
      focusedColorHex: focusedColorHex ?? this.focusedColorHex,
      paletteGenerator: paletteGenerator == _sentinel ? this.paletteGenerator : paletteGenerator as PaletteGenerator?,
      activeColors: activeColors ?? this.activeColors,
      imageData: imageData == _sentinel ? this.imageData : imageData as Uint8List?,
      showOverlay: showOverlay ?? this.showOverlay,
      hovering: hovering ?? this.hovering,
      pinnedDetailedColors: pinnedDetailedColors ?? this.pinnedDetailedColors,
      dx: dx == _sentinel ? this.dx : dx as int?,
      dy: dy == _sentinel ? this.dy : dy as int?,
      hoveredColor: hoveredColor == _sentinel ? this.hoveredColor : hoveredColor as Color?,
      copiedColor: copiedColor == _sentinel ? this.copiedColor : copiedColor as Color?,
      localDx: localDx == _sentinel ? this.localDx : localDx as double?,
      localDy: localDy == _sentinel ? this.localDy : localDy as double?,
    );
  }

  /// Clear all image-related data
  HomePageState clearImage() {
    return copyWith(
      imageData: null,
      paletteGenerator: null,
      activeColors: const [],
      copiedColor: null,
      hoveredColor: null,
      dx: null,
      dy: null,
      localDx: null,
      localDy: null,
      hovering: false,
      containerColor: Colors.white,
      containerText: 'Drop your image here',
    );
  }

  /// Check if an image is loaded
  bool get hasImage => imageData != null;

  /// Check if there's a valid palette
  bool get hasPalette => paletteGenerator != null;

  /// Check if there's a dominant color available
  bool get hasDominantColor =>
      paletteGenerator?.dominantColor?.color != null;

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
        other.hovering == hovering &&
        other.pinnedDetailedColors == pinnedDetailedColors &&
        other.dx == dx &&
        other.dy == dy &&
        other.hoveredColor == hoveredColor &&
        other.copiedColor == copiedColor &&
        other.localDx == localDx &&
        other.localDy == localDy;
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
      hovering,
      pinnedDetailedColors,
      dx,
      dy,
      hoveredColor,
      copiedColor,
      localDx,
      localDy,
    ]);
  }
}
