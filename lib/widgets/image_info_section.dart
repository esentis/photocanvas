import 'package:flutter/material.dart';
import 'package:photocanvas/constants.dart';
import 'package:photocanvas/models/accessibility_report.dart';
import 'package:photocanvas/models/image_analysis.dart';
import 'package:photocanvas/theme/app_theme.dart';
import 'package:photocanvas/widgets/common/app_card.dart';
import 'package:photocanvas/widgets/common/status_badge.dart';

/// File metadata of the dropped image plus WCAG accessibility insights
/// derived from its palette and average brightness.
class ImageInfoSection extends StatelessWidget {
  const ImageInfoSection({
    required this.analysis,
    required this.report,
    super.key,
  });

  final ImageAnalysis analysis;
  final AccessibilityReport? report;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ImageInfoCard(analysis: analysis),
        if (report != null) ...[
          const SizedBox(height: AppTheme.space4),
          _AccessibilityCard(report: report!),
        ],
      ],
    );
  }
}

class _ImageInfoCard extends StatelessWidget {
  const _ImageInfoCard({required this.analysis});

  final ImageAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SectionHeader('Image information', icon: Icons.image_outlined),
          const SizedBox(height: AppTheme.space3),
          Wrap(
            spacing: AppTheme.space5,
            runSpacing: AppTheme.space3,
            children: [
              StatTile(label: 'File', value: analysis.fileName),
              StatTile(label: 'Format', value: analysis.format, mono: true),
              StatTile(
                label: 'Size',
                value: analysis.formattedFileSize,
                mono: true,
              ),
              StatTile(
                label: 'Dimensions',
                value: analysis.resolution,
                mono: true,
              ),
              StatTile(
                label: 'Megapixels',
                value: analysis.megapixels.toStringAsFixed(2),
                mono: true,
              ),
              StatTile(
                label: 'Aspect ratio',
                value: analysis.aspectRatio,
                mono: true,
              ),
              StatTile(label: 'Orientation', value: analysis.orientation),
            ],
          ),
          if (analysis.isLowResolution) ...[
            const SizedBox(height: AppTheme.space3),
            const WarningBadge(
              message: 'Low resolution — may blur when zoomed',
            ),
          ],
        ],
      ),
    );
  }
}

class _AccessibilityCard extends StatelessWidget {
  const _AccessibilityCard({required this.report});

  final AccessibilityReport report;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SectionHeader(
            'Accessibility',
            icon: Icons.accessibility_new_rounded,
          ),
          const SizedBox(height: AppTheme.space2),
          Text(report.textRecommendation, style: AppTheme.bodyMedium),
          const SizedBox(height: AppTheme.space3),
          _RecommendedOverlay(report: report),
          const SizedBox(height: AppTheme.space2),
          Row(
            children: [
              Flexible(
                child: Text(
                  'Average brightness',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.bodySmall,
                ),
              ),
              const SizedBox(width: AppTheme.space2),
              Expanded(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: report.averageLuminance),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) => ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: value,
                      minHeight: 6,
                      backgroundColor: AppTheme.surfaceAlt,
                      valueColor: const AlwaysStoppedAnimation(
                        AppTheme.warning,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.space2),
              Text(
                '${(report.averageLuminance * 100).round()}%',
                style: AppTheme.mono.copyWith(color: AppTheme.text),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space3),
          if (report.colorContrasts.isEmpty)
            Text(
              'No palette colors to evaluate',
              style: AppTheme.bodySmall.copyWith(fontStyle: FontStyle.italic),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceAlt.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: AppTheme.stroke),
              ),
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.space3),
              child: Column(
                children: [
                  for (final (index, contrast)
                      in report.colorContrasts.indexed) ...[
                    if (index > 0)
                      const Divider(height: 1, color: AppTheme.stroke),
                    _ContrastRow(contrast),
                  ],
                ],
              ),
            ),
          const SizedBox(height: AppTheme.space2),
          Text(
            'WCAG AA needs 4.5:1 · AAA needs 7:1 (vs white / black text)',
            style: AppTheme.bodySmall.copyWith(color: AppTheme.textMuted),
          ),
          if (report.colorContrasts.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              'White text meets AA on '
              '${(report.aaWhiteTextCoverage * 100).round()}% of palette colors.',
              style: AppTheme.bodySmall.copyWith(color: AppTheme.textMuted),
            ),
          ],
        ],
      ),
    );
  }
}

/// Highlighted verdict: which standard text color reads best over this
/// image, with the achieved ratio and WCAG badges.
class _RecommendedOverlay extends StatelessWidget {
  const _RecommendedOverlay({required this.report});

  final AccessibilityReport report;

  @override
  Widget build(BuildContext context) {
    final isWhite = report.recommendsWhiteText;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space3,
        vertical: AppTheme.space2 + 2,
      ),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: isWhite ? Colors.white : Colors.black,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.strokeStrong, width: 1.5),
            ),
          ),
          const SizedBox(width: AppTheme.space2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'RECOMMENDED OVERLAY TEXT',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.label.copyWith(fontSize: 10),
                ),
                const SizedBox(height: 1),
                RichText(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    style: AppTheme.titleSmall,
                    children: [
                      TextSpan(text: isWhite ? 'White' : 'Black'),
                      TextSpan(
                        text:
                            ' · ${report.recommendedTextRatio.toStringAsFixed(1)}:1',
                        style: AppTheme.mono.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Wrap(
            spacing: 4,
            runSpacing: 2,
            children: [
              StatusBadge(passed: report.recommendedPassesAa, label: 'AA'),
              StatusBadge(passed: report.recommendedPassesAaa, label: 'AAA'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContrastRow extends StatelessWidget {
  const _ContrastRow(this.contrast);

  final ColorContrast contrast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.space2),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: contrast.color,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.strokeStrong, width: 1.5),
            ),
          ),
          const SizedBox(width: AppTheme.space2),
          Expanded(
            flex: 2,
            child: Text(
              kColorToHexString(contrast.color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.mono.copyWith(fontSize: 12.5),
            ),
          ),
          const SizedBox(width: AppTheme.space2),
          Expanded(
            flex: 3,
            child: _ContrastGroup(
              label: 'White',
              ratio: contrast.contrastWithWhite,
              passesAa: contrast.passesAaWithWhite(),
              passesAaa: contrast.passesAaaWithWhite(),
              recommended: contrast.prefersWhiteText,
            ),
          ),
          const SizedBox(width: AppTheme.space1),
          Expanded(
            flex: 3,
            child: _ContrastGroup(
              label: 'Black',
              ratio: contrast.contrastWithBlack,
              passesAa: contrast.passesAaWithBlack(),
              passesAaa: contrast.passesAaaWithBlack(),
              recommended: !contrast.prefersWhiteText,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContrastGroup extends StatelessWidget {
  const _ContrastGroup({
    required this.label,
    required this.ratio,
    required this.passesAa,
    required this.passesAaa,
    required this.recommended,
  });

  final String label;
  final double ratio;
  final bool passesAa;
  final bool passesAaa;

  /// Whether white/black (this column) is the stronger choice for this
  /// color; rendered with a subtle tinted pill to steer the eye.
  final bool recommended;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      decoration: BoxDecoration(
        color: recommended ? AppTheme.primary.withValues(alpha: 0.10) : null,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      // Wrap-based layout so narrow sidebars degrade gracefully instead of
      // overflowing.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label ${ratio.toStringAsFixed(1)}:1',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.bodySmall.copyWith(
              fontSize: 12,
              fontWeight: recommended ? FontWeight.w700 : FontWeight.w400,
              color: recommended ? AppTheme.text : AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Wrap(
            spacing: 4,
            runSpacing: 2,
            children: [
              StatusBadge(passed: passesAa, label: 'AA'),
              StatusBadge(passed: passesAaa, label: 'AAA'),
            ],
          ),
        ],
      ),
    );
  }
}
