import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:photocanvas/constants.dart';
import 'package:photocanvas/helper/assets.dart';
import 'package:photocanvas/helper/utils.dart';
import 'package:photocanvas/theme/app_theme.dart';

/// App brand lockup: gradient logo tile, wordmark and version chip.
/// Tapping anywhere opens the project's GitHub profile (existing
/// behaviour preserved).
class PhotocanvasTitle extends StatelessWidget {
  const PhotocanvasTitle({
    required this.title,
    super.key,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => launchLink(kGithubLink),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: AppTheme.brandGradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: SvgPicture.asset(
                  Assets.palette,
                  height: 22,
                  width: 22,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppTheme.space3),
            Flexible(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.titleLarge.copyWith(
                  fontSize: 22,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            const SizedBox(width: AppTheme.space2),
            _VersionChip(version: '${Utils.version}'),
          ],
        ),
      ),
    );
  }
}

class _VersionChip extends StatelessWidget {
  const _VersionChip({required this.version});

  final String version;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.surfaceAlt,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.strokeStrong),
      ),
      child: Text(
        'v$version',
        style: AppTheme.mono.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }
}
