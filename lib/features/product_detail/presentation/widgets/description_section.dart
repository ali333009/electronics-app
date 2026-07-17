import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import 'package:elct/l10n/app_localizations.dart';
import 'section_title.dart';

class DescriptionSection extends StatelessWidget {
  final String description;
  const DescriptionSection({super.key, required this.description});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(title: AppLocalizations.of(context)!.description),
          const SizedBox(height: 14),
          Text(description, style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary, height: 1.7, fontSize: 14)),
        ],
      ),
    );
  }
}
