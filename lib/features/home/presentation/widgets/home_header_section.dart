import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:elct/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/providers/currency_provider.dart';
import '../../../../core/providers/app_settings_provider.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/router/routes.dart';
import '../../domain/entities/banner_entity.dart';
import 'banner_carousel.dart';

class HomeHeaderSection extends ConsumerWidget {
  final List<BannerEntity> banners;
  final VoidCallback onCurrencyTap;
  final VoidCallback onLanguageTap;

  const HomeHeaderSection({
    super.key,
    required this.banners,
    required this.onCurrencyTap,
    required this.onLanguageTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(currencyProvider);
    return Container(
      color: AppColors.surfaceDark,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: onCurrencyTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.darkCircle,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(currency.symbol, style: AppTypography.captionBold.copyWith(fontWeight: FontWeight.w700, color: AppColors.gold)),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_drop_down, color: AppColors.gold, size: 16),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: onLanguageTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.darkCircle,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(ref.watch(localeProvider).languageCode == 'ar' ? 'عربي' : 'EN', style: AppTypography.captionBold.copyWith(fontWeight: FontWeight.w700, color: AppColors.gold)),
                            const SizedBox(width: 4),
                            const Icon(Icons.language, color: AppColors.gold, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  (Localizations.localeOf(context).languageCode == 'ar'
                          ? ref.watch(appSettingsProvider).valueOrNull?.storeNameAr ?? 'إلكترونيك'
                          : ref.watch(appSettingsProvider).valueOrNull?.storeNameEn ?? 'ELECTRONIC')
                      .toUpperCase(),
                  style: AppTypography.price.copyWith(letterSpacing: 3),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () => context.push(Routes.search),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.darkContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Expanded(child: Text(AppLocalizations.of(context)!.searchHint, style: AppTypography.bodyMedium.copyWith(color: AppColors.textWhiteMuted))),
                    const SizedBox(width: 12),
                    const Icon(Icons.search, color: AppColors.gold, size: 22),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (banners.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: BannerCarousel(banners: banners),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
