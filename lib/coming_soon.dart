import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:photocanvas/constants.dart';
import 'package:photocanvas/helper/assets.dart';
import 'package:photocanvas/theme/app_theme.dart';
import 'package:photocanvas/widgets/common/app_background.dart';
import 'package:photocanvas/widgets/common/app_header.dart';
import 'package:photocanvas/widgets/title.dart';

/// Shown on mobile/tablet/watch where the full editor is not available
/// yet. Displays one of the playful [comingSoonMessages] at random.
class ComingSoon extends StatelessWidget {
  const ComingSoon({super.key});

  @override
  Widget build(BuildContext context) {
    final random = Random().nextInt(comingSoonMessages.length);
    kLog.f(random);
    return AppBackground(
      child: Scaffold(
        appBar: const AppHeader(
          title: PhotocanvasTitle(title: 'Photocanvas'),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.space6),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Container(
                padding: const EdgeInsets.all(AppTheme.space8),
                decoration: BoxDecoration(
                  color: AppTheme.surface.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                  border: Border.all(color: AppTheme.stroke),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      Assets.unavailable,
                      height: 44,
                      colorFilter: const ColorFilter.mode(
                        AppTheme.warning,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(height: AppTheme.space5),
                    Text(
                      comingSoonMessages[random],
                      textAlign: TextAlign.center,
                      style: AppTheme.bodyLarge.copyWith(height: 1.65),
                    ),
                    const SizedBox(height: AppTheme.space6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.space3,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                        border: Border.all(color: AppTheme.strokeStrong),
                        color: AppTheme.surfaceAlt,
                      ),
                      child: Text(
                        'Desktop experience available now',
                        style: AppTheme.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
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
}
