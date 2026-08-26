import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:photocanvas/constants.dart';
import 'package:photocanvas/theme/app_theme.dart';

class UiHelper {
  /// Shows a snackbar confirming a copied color. The bar itself is painted
  /// in the copied color, with text contrast picked automatically.
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>
      showCopySnackBar(
    BuildContext context,
    Color color,
  ) {
    final onColor = color.computeLuminance() > 0.4
        ? Colors.black.withValues(alpha: 0.85)
        : Colors.white;
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.25)),
        ),
        content: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd - 1),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
            child: ColoredBox(
              color: color.withValues(alpha: 0.88),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppTheme.space3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_rounded, size: 18, color: onColor),
                    const SizedBox(width: AppTheme.space2),
                    Flexible(
                      child: Text(
                        '${kColorToHexString(color)} copied to clipboard!',
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: onColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Shows an error snackbar for invalid file formats and processing
  /// failures.
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>
      showErrorSnackBar(
    BuildContext context, {
    required String message,
    Color? backgroundColor,
  }) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.surfaceAlt,
        elevation: 8,
        duration: const Duration(seconds: 5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          side: BorderSide(
            color: (backgroundColor ?? AppTheme.error).withValues(alpha: 0.6),
          ),
        ),
        content: Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 20,
              color: backgroundColor ?? AppTheme.error,
            ),
            const SizedBox(width: AppTheme.space2),
            Expanded(
              child: Text(
                message,
                style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
