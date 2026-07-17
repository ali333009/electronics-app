import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_shimmer.dart';

class DetailShimmer extends StatelessWidget {
  const DetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppShimmer(height: 300, borderRadius: 0),
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppShimmer(width: 220, height: 28),
                          const SizedBox(height: 12), AppShimmer(width: 120, height: 20),
                          const SizedBox(height: 12), AppShimmer(width: 180, height: 18),
                          const SizedBox(height: 16), AppShimmer(width: 160, height: 26),
                          const SizedBox(height: 20),
                          const Divider(color: AppColors.divider),
                          const SizedBox(height: 20), AppShimmer(width: 80, height: 20),
                          const SizedBox(height: 12), AppShimmer(width: double.infinity, height: 14),
                          const SizedBox(height: 6), AppShimmer(width: double.infinity, height: 14),
                          const SizedBox(height: 6), AppShimmer(width: 200, height: 14),
                          const SizedBox(height: 24),
                          const Divider(color: AppColors.divider),
                          const SizedBox(height: 20), AppShimmer(width: 100, height: 20),
                          const SizedBox(height: 12),
                          ...List.generate(3, (_) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(children: [AppShimmer(width: 80, height: 16), const Spacer(), AppShimmer(width: 120, height: 16)]),
                          )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
