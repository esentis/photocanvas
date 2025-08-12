import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:photocanvas/constants.dart';
import 'package:photocanvas/theme/app_theme.dart';

class UiHelper {
  /// Shows a snackbar with copied color information
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>
      showCopySnackBar(
    BuildContext context,
    Color color,
  ) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        content: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 7,
              sigmaY: 7,
            ),
            child: ColoredBox(
              color: color.withValues(alpha: 0.8),
              child: Center(
                child: Text(
                  '${kColorToHexString(color)}\ncopied to clipboard!',
                  style: AppTheme.bodyMedium.copyWith(
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Shows an error snackbar for invalid file formats
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>
      showErrorSnackBar(
    BuildContext context, {
    required String message,
    Color? backgroundColor,
  }) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor ?? AppTheme.error,
        content: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 7,
              sigmaY: 7,
            ),
            child: Container(
              height: 80,
              color: backgroundColor ?? AppTheme.error,
              child: Center(
                child: Text(
                  message,
                  style: AppTheme.bodyMedium.copyWith(
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
