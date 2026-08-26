import 'package:flutter/material.dart';
import 'package:photocanvas/theme/app_theme.dart';

/// Decorative page backdrop: deep gradient with two soft color glows.
/// Sits behind every screen so the app shares one atmospheric identity.
class AppBackground extends StatelessWidget {
  const AppBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0E1220), AppTheme.background],
        ),
      ),
      child: Stack(
        children: [
          const Positioned(
            top: -220,
            left: -160,
            child: _Glow(color: AppTheme.primary),
          ),
          const Positioned(
            bottom: -260,
            right: -180,
            child: _Glow(color: Color(0xFF1B6B8F)),
          ),
          child,
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: 560,
        height: 560,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: 0.16),
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}
