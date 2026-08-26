import 'package:flutter/material.dart';

/// Central design system for Photocanvas.
///
/// Contains the color palette, typography scale, spacing/radii/shadow tokens
/// and the [MaterialApp]-level [ThemeData] so every Material widget (snack
/// bars, dialogs, tooltips...) inherits the same visual language.
abstract final class AppTheme {
  // ── Colors ────────────────────────────────────────────────────────────────
  /// Page background base.
  static const Color background = Color(0xFF0B0E15);

  /// Card / panel surface.
  static const Color surface = Color(0xFF12161F);

  /// Elevated nested surface (chips inside cards, dialog headers).
  static const Color surfaceAlt = Color(0xFF181D29);

  static const Color stroke = Color(0x12FFFFFF);
  static const Color strokeStrong = Color(0x24FFFFFF);

  static const Color primary = Color(0xFF8B7CF6);
  static const Color primaryStrong = Color(0xFFA78BFA);
  static const Color primaryContainer = Color(0x2E8B7CF6);

  /// Cyan accent used sparingly for focus rings and secondary highlights.
  static const Color secondary = Color(0xFF22D3EE);

  static const Color success = Color(0xFF34D399);
  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFFB7185);
  static const Color errorContainer = Color(0x2EFB7185);

  static const Color text = Color(0xFFEEF2F9);
  static const Color textSecondary = Color(0xFFA3ADC2);
  static const Color textMuted = Color(0xFF6B7690);

  // ── Typography ────────────────────────────────────────────────────────────
  static const String _fontFamily = 'Inter';
  static const String monoFamily = 'JetBrains Mono';

  static const TextStyle defaultStyle = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    height: 1.5,
    color: text,
  );

  /// Large hero heading used on the empty state.
  static TextStyle get heroDisplay => defaultStyle.copyWith(
        fontSize: 40,
        height: 1.1,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
      );

  static TextStyle get titleLarge => defaultStyle.copyWith(
        fontSize: 28,
        height: 1.15,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      );

  static TextStyle get titleMedium => defaultStyle.copyWith(
        fontSize: 20,
        height: 1.25,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get titleSmall => defaultStyle.copyWith(
        fontSize: 16,
        height: 1.3,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get bodyLarge =>
      defaultStyle.copyWith(fontSize: 16, height: 1.55);

  static TextStyle get bodyMedium => defaultStyle;

  static TextStyle get bodySmall =>
      defaultStyle.copyWith(fontSize: 13, height: 1.45);

  /// Small uppercase label used for section headers and stat captions.
  static TextStyle get label => defaultStyle.copyWith(
        fontSize: 11.5,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
        color: textSecondary,
      );

  /// Monospace style for hex codes and numeric values.
  static TextStyle get mono => defaultStyle.copyWith(
        fontFamily: monoFamily,
        fontSize: 13.5,
        height: 1.3,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
      );

  // ── Spacing ───────────────────────────────────────────────────────────────
  static const double space1 = 4;
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space5 = 20;
  static const double space6 = 24;
  static const double space8 = 32;
  static const double space10 = 40;

  // ── Radii ─────────────────────────────────────────────────────────────────
  static const double radiusSm = 10;
  static const double radiusMd = 14;
  static const double radiusLg = 18;
  static const double radiusXl = 26;

  // ── Breakpoints ───────────────────────────────────────────────────────────
  /// Below this width the dashboard collapses to a single column.
  static const double wideLayoutBreakpoint = 1060;

  // ── Shadows ───────────────────────────────────────────────────────────────
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.35),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ];

  static List<BoxShadow> get glowShadow => [
        BoxShadow(
          color: primary.withValues(alpha: 0.35),
          blurRadius: 32,
          spreadRadius: 2,
        ),
      ];

  // ── Theme ─────────────────────────────────────────────────────────────────
  static ThemeData buildTheme() {
    const colorScheme = ColorScheme.dark(
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: primaryContainer,
      onPrimaryContainer: primaryStrong,
      secondary: secondary,
      onSecondary: background,
      surface: surface,
      onSurface: text,
      surfaceContainerHighest: surfaceAlt,
      onSurfaceVariant: textSecondary,
      error: error,
      outline: strokeStrong,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.transparent,
      splashFactory: InkSparkle.splashFactory,
      fontFamily: _fontFamily,
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(bodyColor: text, displayColor: text),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: surfaceAlt,
        contentTextStyle: bodySmall.copyWith(color: text),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          side: const BorderSide(color: strokeStrong),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXl),
          side: const BorderSide(color: stroke),
        ),
        titleTextStyle: titleLarge,
        contentTextStyle: bodyMedium,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: surfaceAlt,
          borderRadius: BorderRadius.circular(radiusSm),
          border: Border.all(color: strokeStrong),
        ),
        textStyle: bodySmall,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(textMuted.withValues(alpha: 0.4)),
        radius: const Radius.circular(radiusSm),
      ),
      dividerTheme: const DividerThemeData(color: stroke, thickness: 1),
    );
  }

  /// Linear gradient used for primary actions and brand marks.
  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFF8B7CF6), Color(0xFF6D67E4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
