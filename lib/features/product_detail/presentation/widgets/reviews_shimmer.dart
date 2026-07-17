import 'package:flutter/material.dart';
import 'review_shimmer_row.dart';

class ReviewsShimmer extends StatelessWidget {
  const ReviewsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SizedBox(height: 16),
        ReviewShimmerRow(),
        SizedBox(height: 12),
        ReviewShimmerRow(),
        SizedBox(height: 12),
        ReviewShimmerRow(),
      ],
    );
  }
}
