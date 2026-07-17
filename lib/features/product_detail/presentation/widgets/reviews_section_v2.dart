import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../reviews/presentation/providers/reviews_provider.dart';
import 'package:elct/l10n/app_localizations.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import 'reviews_shimmer.dart';
import 'reviews_content.dart';
import 'section_title.dart';

class ReviewsSectionV2 extends ConsumerWidget {
  final String productId;
  final String? userId;
  final String? userName;

  const ReviewsSectionV2({super.key, required this.productId, this.userId, this.userName});

  @override
  Widget build(BuildContext context, WidgetRef widgetRef) {
    final reviewsAsync = widgetRef.watch(reviewsProvider(productId));
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(title: AppLocalizations.of(context)!.reviews),
          const SizedBox(height: 16),
          reviewsAsync.when(
            loading: () => const ReviewsShimmer(),
            error: (_, _) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Column(
                  children: [
                    Text(AppLocalizations.of(context)!.loadError, style: AppTypography.bodyMedium),
                    const SizedBox(height: AppSpacing.md),
                    AppButton(
                      text: AppLocalizations.of(context)!.retry,
                      onPressed: () => widgetRef.invalidate(reviewsProvider(productId)),
                    ),
                  ],
                ),
              ),
            ),
            data: (reviews) => ReviewsContent(
              reviews: reviews, productId: productId, userId: userId, userName: userName,
              onAddReview: (rv) async {
                await widgetRef.read(reviewsRepositoryProvider).addReview(rv);
                widgetRef.invalidate(reviewsProvider(productId));
              },
            ),
          ),
        ],
      ),
    );
  }
}
