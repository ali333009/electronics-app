import 'package:flutter/material.dart';
import 'package:elct/core/theme/app_spacing.dart';
import 'package:elct/core/widgets/app_shimmer.dart';

class AppProductsGridShimmer extends StatelessWidget {
  final int itemCount;
  
  const AppProductsGridShimmer({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.sm),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 12,
        childAspectRatio: 0.55,
      ),
      itemCount: itemCount,
      itemBuilder: (_, _) => const AppShimmer(height: double.infinity, borderRadius: 12),
    );
  }
}
