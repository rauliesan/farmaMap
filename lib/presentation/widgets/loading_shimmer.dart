import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/extensions/context_extensions.dart';

/// Shimmer loading placeholder for list items
class LoadingShimmer extends StatelessWidget {
  const LoadingShimmer({
    super.key,
    this.itemCount = 5,
  });

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final baseColor = context.isDarkMode
        ? Colors.grey.shade800
        : Colors.grey.shade300;
    final highlightColor = context.isDarkMode
        ? Colors.grey.shade700
        : Colors.grey.shade100;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemBuilder: (_, __) => const _ShimmerListItem(),
      ),
    );
  }
}

class _ShimmerListItem extends StatelessWidget {
  const _ShimmerListItem();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          // Icon placeholder
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 200,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 80,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shimmer loading for map screen
class MapLoadingShimmer extends StatelessWidget {
  const MapLoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final baseColor = context.isDarkMode
        ? Colors.grey.shade800
        : Colors.grey.shade300;
    final highlightColor = context.isDarkMode
        ? Colors.grey.shade700
        : Colors.grey.shade100;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        color: Colors.white,
      ),
    );
  }
}
