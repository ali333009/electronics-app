import 'package:flutter/material.dart';
import 'package:elct/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';

import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/login_required_bottom_sheet.dart';
import '../../../reviews/domain/entities/review_entity.dart';
import '../../../reviews/data/models/review_model.dart';
import 'review_card.dart';
import 'star_rating.dart';

class ReviewsContent extends StatefulWidget {
  final List<ReviewEntity> reviews;
  final String productId;
  final String? userId;
  final String? userName;
  final Future<void> Function(ReviewModel) onAddReview;

  const ReviewsContent({super.key, required this.reviews, required this.productId, this.userId, this.userName, required this.onAddReview});

  @override
  State<ReviewsContent> createState() => _ReviewsContentState();
}

class _ReviewsContentState extends State<ReviewsContent> {
  bool _isAddReviewExpanded = false;
  bool _showAllReviews = false;
  double _rating = 0.0;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.reviews.isEmpty) {
      return _buildEmptyState(context);
    }

    final avgRating = widget.reviews.map((r) => r.rating).reduce((a, b) => a + b) / widget.reviews.length;
    final distribution = List.generate(5, (i) {
      final star = 5 - i;
      return widget.reviews.where((r) => r.rating >= star && r.rating < star + 1).length;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDistributionBox(context, avgRating, distribution),
        const SizedBox(height: 16),
        _buildReviewsBox(context),
        const SizedBox(height: 16),
        _buildAddReviewBox(context),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),
        Icon(Icons.rate_review_outlined, size: 64, color: AppColors.textMuted.withValues(alpha: 0.5)),
        const SizedBox(height: AppSpacing.md),
        Text(AppLocalizations.of(context)!.noReviews, style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: AppSpacing.lg),
        _buildAddReviewBox(context),
      ],
    );
  }

  Widget _buildDistributionBox(BuildContext context, double avgRating, List<int> distribution) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Text(avgRating.toStringAsFixed(1), style: const TextStyle(fontFamily: 'Cairo', fontSize: 36, fontWeight: FontWeight.w800, color: AppColors.textDark)),
              const SizedBox(height: 4),
              StarRating(rating: avgRating, size: 16),
              const SizedBox(height: 4),
              Text(AppLocalizations.of(context)!.reviewCount(widget.reviews.length), style: AppTypography.bodyMedium.copyWith(fontSize: 12)),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              children: List.generate(5, (i) {
                final star = 5 - i;
                final pct = widget.reviews.isEmpty ? 0.0 : distribution[i] / widget.reviews.length;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Text('$star', style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textMuted)),
                      const SizedBox(width: 4),
                      const Icon(Icons.star, size: 12, color: AppColors.gold),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: pct, backgroundColor: AppColors.divider,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold), minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(width: 32, child: Text('${(pct * 100).round()}%', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textMuted))),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsBox(BuildContext context) {
    final displayedReviews = _showAllReviews ? widget.reviews : widget.reviews.take(3).toList();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...displayedReviews.map((review) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ReviewCard(review: review),
          )),
          if (widget.reviews.length > 3)
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => setState(() => _showAllReviews = !_showAllReviews),
                child: Text(
                  _showAllReviews ? "إخفاء التقييمات" : '${AppLocalizations.of(context)!.viewAll} (${AppLocalizations.of(context)!.reviewCount(widget.reviews.length)})',
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.gold),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddReviewBox(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: _isAddReviewExpanded,
          onExpansionChanged: (v) {
            if (widget.userId == null) {
              showLoginRequiredSheet(context, redirectPath: '/products/${widget.productId}');
              return;
            }
            setState(() => _isAddReviewExpanded = v);
          },
          title: Text(AppLocalizations.of(context)!.addReview, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
          leading: const Icon(Icons.rate_review, color: AppColors.gold),
          children: [
            if (widget.userId != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context)!.selectStarRating, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 4,
                      children: List.generate(5, (i) {
                        final star = i + 1;
                        return GestureDetector(
                          onTap: () => setState(() => _rating = star.toDouble()),
                          child: Icon(star <= _rating ? Icons.star : Icons.star_border, color: AppColors.gold, size: 36),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _commentController,
                      maxLines: 4,
                      maxLength: 500,
                      textDirection: Directionality.of(context),
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.writeReviewHint,
                        hintStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textMuted),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.gold)),
                        filled: true, fillColor: AppColors.backgroundLight,
                      ),
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: AppColors.textDark,
                          disabledBackgroundColor: AppColors.divider,
                          disabledForegroundColor: AppColors.textMuted,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: _rating > 0
                            ? () async {
                                final review = ReviewModel(
                                  id: 'user_${DateTime.now().millisecondsSinceEpoch}',
                                  productId: widget.productId,
                                  userId: widget.userId!,
                                  userName: widget.userName ?? AppLocalizations.of(context)!.defaultUserName,
                                  rating: _rating,
                                  comment: _commentController.text.trim().isEmpty ? AppLocalizations.of(context)!.reviewDefaultComment : _commentController.text.trim(),
                                  date: DateTime.now(),
                                );
                                await widget.onAddReview(review);
                                if (!context.mounted) return;
                                setState(() {
                                  _isAddReviewExpanded = false;
                                  _rating = 0.0;
                                  _commentController.clear();
                                });
                                AppToast.show(context, AppLocalizations.of(context)!.reviewSubmitted, icon: Icons.star);
                              }
                            : null,
                        child: Text(AppLocalizations.of(context)!.confirm, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
