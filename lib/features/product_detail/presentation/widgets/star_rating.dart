import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final double size;
  const StarRating({super.key, required this.rating, this.size = 14});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < rating.floor();
        final half = !filled && i < rating.ceil();
        return Icon(filled ? Icons.star : half ? Icons.star_half : Icons.star_border, color: AppColors.gold, size: size);
      }),
    );
  }
}
