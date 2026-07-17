import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_shimmer.dart';

class ReviewShimmerRow extends StatelessWidget {
  const ReviewShimmerRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        color: AppColors.surfaceCard,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppShimmer(width: 36, height: 36, borderRadius: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppShimmer(width: 100, height: 14),
                const SizedBox(height: 6),
                AppShimmer(width: 80, height: 12),
                const SizedBox(height: 8),
                AppShimmer(width: double.infinity, height: 12),
                const SizedBox(height: 4),
                AppShimmer(width: 160, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
