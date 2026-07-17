import 'package:flutter/material.dart';
import '../../../reviews/domain/entities/review_entity.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import 'package:elct/l10n/app_localizations.dart';
import 'star_rating.dart';

class ReviewCard extends StatelessWidget {
  final ReviewEntity review;
  const ReviewCard({super.key, required this.review});
  @override
  Widget build(BuildContext context) {
    final diff = DateTime.now().difference(review.date);
    final timeAgo = diff.inDays > 30 ? AppLocalizations.of(context)!.timeMonth(diff.inDays ~/ 30)
        : diff.inDays > 0 ? AppLocalizations.of(context)!.timeDay(diff.inDays)
        : diff.inHours > 0 ? AppLocalizations.of(context)!.timeHour(diff.inHours) : AppLocalizations.of(context)!.timeNow;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18, backgroundColor: AppColors.surfaceDark,
                child: Text(review.userName[0], style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700, color: AppColors.gold)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.userName, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 2),
                    StarRating(rating: review.rating, size: 12),
                  ],
                ),
              ),
              Text(timeAgo, style: AppTypography.bodyMedium.copyWith(fontSize: 11)),
            ],
          ),
          const SizedBox(height: 10),
          Text(review.comment, style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary, fontSize: 13, height: 1.5)),
        ],
      ),
    );
  }
}
