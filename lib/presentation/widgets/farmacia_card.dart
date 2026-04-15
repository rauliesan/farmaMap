import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/extensions/context_extensions.dart';
import '../../core/extensions/num_extensions.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/farmacia.dart';

/// Reusable pharmacy card widget for list views
class FarmaciaCard extends StatelessWidget {
  const FarmaciaCard({
    super.key,
    required this.farmacia,
    this.distanceMeters,
    this.onTap,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.animationIndex = 0,
  });

  final Farmacia farmacia;
  final double? distanceMeters;
  final VoidCallback? onTap;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final int animationIndex;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Pharmacy icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_pharmacy_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),

              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      farmacia.displayNombre,
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      farmacia.shortDireccion,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (distanceMeters != null) ...[
                      const SizedBox(height: 6),
                      DistanceChip(distanceMeters: distanceMeters!),
                    ],
                  ],
                ),
              ),



              // Chevron
              Icon(
                Icons.chevron_right_rounded,
                color: context.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
          duration: 300.ms,
          delay: (50 * animationIndex).ms,
        )
        .slideX(
          begin: 0.05,
          end: 0,
          duration: 300.ms,
          delay: (50 * animationIndex).ms,
          curve: Curves.easeOutCubic,
        );
  }
}

/// Small chip showing walking distance
class DistanceChip extends StatelessWidget {
  const DistanceChip({super.key, required this.distanceMeters});

  final double distanceMeters;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.directions_walk_rounded,
          size: 14,
          color: AppColors.primary,
        ),
        const SizedBox(width: 4),
        Text(
          distanceMeters.toDistanceString(),
          style: context.textTheme.labelSmall?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
