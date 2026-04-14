import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/theme/app_colors.dart';

/// Horizontal chip selector for search radius
class RadiusSelector extends StatelessWidget {
  const RadiusSelector({
    super.key,
    required this.selectedRadius,
    required this.onChanged,
  });

  final double selectedRadius;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: AppConstants.radiusOptions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final radius = AppConstants.radiusOptions[index];
          final isSelected = radius == selectedRadius;
          final label = AppConstants.radiusLabels[radius] ?? '${radius.toInt()} m';

          return FilterChip(
            label: Text(label),
            selected: isSelected,
            onSelected: (_) => onChanged(radius),
            labelStyle: context.textTheme.labelMedium?.copyWith(
              color: isSelected ? AppColors.onPrimary : null,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
            backgroundColor: context.colorScheme.surfaceContainerHighest,
            selectedColor: AppColors.primary,
            checkmarkColor: AppColors.onPrimary,
            showCheckmark: false,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            side: isSelected
                ? BorderSide.none
                : BorderSide(
                    color: context.colorScheme.outlineVariant,
                    width: 1,
                  ),
          );
        },
      ),
    );
  }
}
