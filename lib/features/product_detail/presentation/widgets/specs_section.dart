import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import 'package:elct/l10n/app_localizations.dart';
import 'section_title.dart';

class SpecsSection extends StatelessWidget {
  final Map<String, String> specs;
  const SpecsSection({super.key, required this.specs});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(title: AppLocalizations.of(context)!.specifications),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd - 1),
              child: Column(
                children: specs.entries.toList().asMap().entries.map((entry) {
                  final i = entry.key;
                  final spec = entry.value;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(color: i.isEven ? AppColors.surfaceCard : AppColors.surfaceLight),
                    child: Row(
                      children: [
                        Expanded(flex: 2, child: Text(spec.key, style: AppTypography.bodyMedium.copyWith(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary))),
                        Container(width: 1, height: 20, color: AppColors.divider),
                        const SizedBox(width: 16),
                        Expanded(flex: 3, child: Text(spec.value, style: AppTypography.bodyLarge.copyWith(fontSize: 13, fontWeight: FontWeight.w600))),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
