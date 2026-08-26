import 'package:flutter/material.dart';
import 'package:photocanvas/theme/app_theme.dart';

/// Top navigation bar shared by every page.
///
/// A translucent panel over the page background with a hairline bottom
/// border and a subtle brand-gradient hairline on the very top edge.
/// Implements [PreferredSizeWidget] so it can be passed straight to
/// [Scaffold.appBar].
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({
    required this.title,
    this.actions = const [],
    super.key,
  });

  static const double height = 76;

  /// Leading widget — usually the brand lockup.
  final Widget title;

  /// Trailing action buttons.
  final List<Widget> actions;

  @override
  Size get preferredSize => const Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.background.withValues(alpha: 0.85),
        border: const Border(
          bottom: BorderSide(color: AppTheme.strokeStrong),
        ),
      ),
      child: Stack(
        children: [
          // Signature gradient fading out along the very top edge.
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: IgnorePointer(
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primary.withValues(alpha: 0.9),
                      AppTheme.primary.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.space5),
            child: Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: title,
                  ),
                ),
                const SizedBox(width: AppTheme.space3),
                for (final (index, action) in actions.indexed) ...[
                  if (index > 0) const SizedBox(width: AppTheme.space2),
                  action,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact square icon action with a defined outline and hover tint.
class HeaderIconButton extends StatefulWidget {
  const HeaderIconButton({
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.hoverColor = AppTheme.primaryStrong,
    super.key,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  /// Content/border tint applied while hovered.
  final Color hoverColor;

  @override
  State<HeaderIconButton> createState() => _HeaderIconButtonState();
}

class _HeaderIconButtonState extends State<HeaderIconButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final button = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: _hovered ? AppTheme.surfaceAlt : AppTheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm + 1),
            border: Border.all(
              color: _hovered
                  ? widget.hoverColor.withValues(alpha: 0.6)
                  : AppTheme.strokeStrong,
            ),
          ),
          child: Icon(
            widget.icon,
            size: 18,
            color: _hovered ? widget.hoverColor : AppTheme.textSecondary,
          ),
        ),
      ),
    );

    final tooltip = widget.tooltip;
    if (tooltip == null) return button;
    return Tooltip(message: tooltip, child: button);
  }
}
