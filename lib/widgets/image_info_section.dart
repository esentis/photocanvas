import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/material.dart';
import 'package:photocanvas/constants.dart';
import 'package:photocanvas/models/accessibility_report.dart';
import 'package:photocanvas/models/image_analysis.dart';
import 'package:photocanvas/theme/app_theme.dart';

/// Displays file metadata of the dropped image plus WCAG accessibility
/// insights derived from its palette and average brightness.
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
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Wrap(
        spacing: 60,
        runSpacing: 30,
        alignment: WrapAlignment.center,
        children: [
          _ImageInfoCard(analysis: analysis),
          if (report != null) _AccessibilityCard(report: report!),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return ClayText(
      title,
      style: AppTheme.bodyMedium,
      color: AppTheme.text,
      parentColor: AppTheme.background,
      spread: AppTheme.defaultSpread,
      depth: AppTheme.defaultDepth.toInt(),
      textColor: AppTheme.text,
      emboss: true,
    );
  }
}

class _ImageInfoCard extends StatelessWidget {
  const _ImageInfoCard({required this.analysis});

  final ImageAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const _SectionHeader('Image information'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 28,
          runSpacing: 14,
          children: [
            _InfoStat(label: 'File', value: analysis.fileName),
            _InfoStat(label: 'Format', value: analysis.format),
            _InfoStat(label: 'Size', value: analysis.formattedFileSize),
            _InfoStat(label: 'Dimensions', value: analysis.resolution),
            _InfoStat(
              label: 'Megapixels',
              value: analysis.megapixels.toStringAsFixed(2),
            ),
            _InfoStat(label: 'Aspect ratio', value: analysis.aspectRatio),
            _InfoStat(label: 'Orientation', value: analysis.orientation),
            if (analysis.isLowResolution)
              const _WarningStat(
                message: 'Low resolution — may blur when zoomed',
              ),
          ],
        ),
      ],
    );
  }
}

class _AccessibilityCard extends StatelessWidget {
  const _AccessibilityCard({required this.report});

  final AccessibilityReport report;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const _SectionHeader('Accessibility'),
        const SizedBox(height: 12),
        Text(
          report.textRecommendation,
          style: AppTheme.bodySmall.copyWith(color: AppTheme.text),
        ),
        Text(
          'Average brightness: ${(report.averageLuminance * 100).round()}%',
          style: AppTheme.bodySmall.copyWith(color: AppTheme.text),
        ),
        const SizedBox(height: 10),
        if (report.colorContrasts.isEmpty)
          Text(
            'No palette colors to evaluate',
            style: AppTheme.bodySmall.copyWith(color: AppTheme.text),
          )
        else
          ...report.colorContrasts.map(_ContrastRow.new),
        const SizedBox(height: 6),
        Text(
          'WCAG AA needs 4.5:1 · AAA needs 7:1 (vs white / black text)',
          style: AppTheme.bodySmall.copyWith(color: AppTheme.text),
        ),
      ],
    );
  }
}

class _ContrastRow extends StatelessWidget {
  const _ContrastRow(this.contrast);

  final ColorContrast contrast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: contrast.color,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.text, width: 1.5),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 78,
            child: Text(
              kColorToHexString(contrast.color),
              style: AppTheme.bodySmall.copyWith(color: AppTheme.text),
            ),
          ),
          _ContrastGroup(
            label: 'White',
            ratio: contrast.contrastWithWhite,
            passesAa: contrast.passesAaWithWhite(),
            passesAaa: contrast.passesAaaWithWhite(),
          ),
          const SizedBox(width: 18),
          _ContrastGroup(
            label: 'Black',
            ratio: contrast.contrastWithBlack,
            passesAa: contrast.passesAaWithBlack(),
            passesAaa: contrast.passesAaaWithBlack(),
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
  });

  final String label;
  final double ratio;
  final bool passesAa;
  final bool passesAaa;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label ${ratio.toStringAsFixed(1)}:1',
          style: AppTheme.defaultStyle.copyWith(
            fontSize: 16,
            height: 1,
            color: AppTheme.text.withValues(alpha: 0.55),
          ),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            _PassBadge(passed: passesAa, label: 'AA'),
            const SizedBox(width: 4),
            _PassBadge(passed: passesAaa, label: 'AAA'),
          ],
        ),
      ],
    );
  }
}

class _PassBadge extends StatelessWidget {
  const _PassBadge({required this.passed, required this.label});

  final bool passed;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = passed ? AppTheme.success : AppTheme.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        passed ? label : '$label ✕',
        style: AppTheme.defaultStyle.copyWith(fontSize: 14, height: 1, color: color),
      ),
    );
  }
}

class _InfoStat extends StatelessWidget {
  const _InfoStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTheme.defaultStyle.copyWith(
            fontSize: 16,
            height: 1,
            letterSpacing: 1.5,
            color: AppTheme.text.withValues(alpha: 0.55),
          ),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 220),
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.text),
          ),
        ),
      ],
    );
  }
}

class _WarningStat extends StatelessWidget {
  const _WarningStat({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.error, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning_amber_rounded, size: 18, color: AppTheme.error),
          const SizedBox(width: 6),
          Text(
            message,
            style: AppTheme.defaultStyle.copyWith(
              fontSize: 18,
              height: 1,
              color: AppTheme.error,
            ),
          ),
        ],
      ),
    );
  }
}
