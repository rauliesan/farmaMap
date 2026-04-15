import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/extensions/context_extensions.dart';
import '../../core/extensions/num_extensions.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/farmacia.dart';

/// Bottom sheet shown when a pharmacy marker is tapped on the map
class FarmaciaBottomSheet extends ConsumerWidget {
  const FarmaciaBottomSheet({
    super.key,
    required this.farmacia,
    this.distanceMeters,
    this.onDetailsTap,
    this.onDirectionsTap,
  });

  final Farmacia farmacia;
  final double? distanceMeters;
  final VoidCallback? onDetailsTap;
  final VoidCallback? onDirectionsTap;

  static Future<void> show(
    BuildContext context, {
    required Farmacia farmacia,
    double? distanceMeters,
    VoidCallback? onDetailsTap,
    VoidCallback? onDirectionsTap,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FarmaciaBottomSheet(
        farmacia: farmacia,
        distanceMeters: distanceMeters,
        onDetailsTap: onDetailsTap,
        onDirectionsTap: onDirectionsTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Pharmacy icon + name
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.local_pharmacy_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1.0, 1.0),
                    duration: 400.ms,
                    curve: Curves.elasticOut,
                  ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      farmacia.displayNombre,
                      style: context.textTheme.titleMedium,
                      maxLines: 2,
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
                  ],
                ),
              ),
            ],
          ),

          // Distance indicator
          if (distanceMeters != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.directions_walk_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'A ${distanceMeters!.toDistanceString()} de ti',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 300.ms),
          ],

          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDirectionsTap,
                  icon: const Icon(Icons.directions_rounded, size: 18),
                  label: const Text('Cómo llegar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onDetailsTap,
                  icon: const Icon(Icons.info_outline_rounded, size: 18),
                  label: const Text('Ver detalles'),
                ),
              ),
            ],
          )
              .animate()
              .fadeIn(delay: 300.ms, duration: 300.ms)
              .slideY(begin: 0.1, end: 0, delay: 300.ms, duration: 300.ms),

          SizedBox(height: context.bottomPadding),
        ],
      ),
    );
  }
}
