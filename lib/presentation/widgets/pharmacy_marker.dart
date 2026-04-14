import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Custom pharmacy marker for the map
class PharmacyMarker extends StatelessWidget {
  const PharmacyMarker({
    super.key,
    this.isSelected = false,
    this.size = 40,
  });

  final bool isSelected;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size + 8,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Shadow
          Positioned(
            bottom: 0,
            child: Container(
              width: size * 0.5,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          // Pin body
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryDark : AppColors.markerPharmacy,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.local_pharmacy_rounded,
              color: Colors.white,
              size: size * 0.45,
            ),
          ),
        ],
      ),
    );
  }
}
