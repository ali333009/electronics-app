import 'package:flutter/material.dart';
import 'package:elct/core/theme/app_colors.dart';
import 'package:elct/core/theme/app_typography.dart';
import 'package:elct/l10n/app_localizations.dart';

class LoadMoreIndicator extends StatelessWidget {
  final bool isLoadingMore;
  final bool hasMore;
  final bool showWhenEmpty;

  const LoadMoreIndicator({
    super.key,
    required this.isLoadingMore,
    required this.hasMore,
    this.showWhenEmpty = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!showWhenEmpty && !hasMore && !isLoadingMore) return const SizedBox.shrink();

    if (isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.gold,
            ),
          ),
        ),
      );
    }

    if (!hasMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            AppLocalizations.of(context)!.allProductsShown,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
