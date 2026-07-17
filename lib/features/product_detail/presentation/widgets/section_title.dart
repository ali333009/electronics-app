import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 4, height: 20, decoration: const BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.all(Radius.circular(2)))),
        const SizedBox(width: 10),
        Text(title, style: AppTypography.titleLarge.copyWith(fontSize: 17, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
