import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../products/presentation/providers/products_provider.dart';
import 'package:elct/l10n/app_localizations.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_shimmer.dart';
import 'section_title.dart';
import 'similar_product_card.dart';

class SimilarProductsSectionV2 extends ConsumerWidget {
  final String categoryId;
  final String currentProductId;

  const SimilarProductsSectionV2({super.key, required this.categoryId, required this.currentProductId});

  @override
  Widget build(BuildContext context, WidgetRef widgetRef) {
    final similarAsync = widgetRef.watch(productsByCategoryProvider(categoryId));
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(title: AppLocalizations.of(context)!.similarProducts),
          const SizedBox(height: 14),
          similarAsync.when(
            loading: () => SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                itemBuilder: (_, _) => const Padding(padding: EdgeInsetsDirectional.only(start: 12), child: AppShimmer(width: 160, height: 220, borderRadius: 12)),
              ),
            ),
            error: (_, _) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(child: Text(AppLocalizations.of(context)!.loadError, style: AppTypography.bodyMedium)),
            ),
            data: (products) {
              final filtered = products.where((p) => p.id != currentProductId).take(10).toList();
              if (filtered.isEmpty) return const SizedBox.shrink();
              return SizedBox(
                height: 240,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (_, i) => SimilarProductCard(
                    product: filtered[i],
                    onTap: () => context.push('${Routes.products}/${filtered[i].id}'),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
