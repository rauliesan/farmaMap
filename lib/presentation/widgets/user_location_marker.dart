import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Animated pulsing blue dot for user's current location
class UserLocationMarker extends StatefulWidget {
  const UserLocationMarker({super.key, this.size = 24});

  final double size;

  @override
  State<UserLocationMarker> createState() => _UserLocationMarkerState();
}

class _UserLocationMarkerState extends State<UserLocationMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 1.0, end: 2.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.5, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size * 3,
      height: widget.size * 3,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Pulse ring
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Container(
                  width: widget.size * _pulseAnimation.value,
                  height: widget.size * _pulseAnimation.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.markerUserGlow
                        .withValues(alpha: _opacityAnimation.value),
                  ),
                );
              },
            ),
            // Outer ring
            Container(
              width: widget.size + 8,
              height: widget.size + 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.markerUser.withValues(alpha: 0.2),
              ),
            ),
            // Inner dot
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.markerUser,
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.markerUser.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
