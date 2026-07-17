import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/router/routes.dart';
import '../../domain/entities/banner_entity.dart';

class BannerCarousel extends StatefulWidget {
  final List<BannerEntity> banners;
  final double height;

  const BannerCarousel({super.key, required this.banners, this.height = 200});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  late final PageController _pageCtrl;
  late Timer _timer;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
    _startTimer();
    // Preload all banner images so auto-scroll is instant
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final banner in widget.banners) {
        precacheImage(CachedNetworkImageProvider(banner.imageUrl), context);
      }
    });
  }

  @override
  void didUpdateWidget(BannerCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.banners.length != widget.banners.length) {
      _timer.cancel();
      _current = 0;
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (widget.banners.length < 2) return;
      final next = (_current + 1) % widget.banners.length;
      _pageCtrl.animateToPage(next, duration: const Duration(milliseconds: 500), curve: Curves.easeInOutCubic);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageCtrl,
            onPageChanged: (i) => setState(() => _current = i),
            itemCount: widget.banners.length,
            itemBuilder: (_, i) => _BannerSlide(banner: widget.banners[i], height: widget.height),
          ),
          if (widget.banners.length > 1)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.banners.length, (i) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _current == i ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _current == i ? AppColors.gold : AppColors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}

class _BannerSlide extends StatelessWidget {
  final BannerEntity banner;
  final double height;

  const _BannerSlide({required this.banner, required this.height});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('${Routes.campaign}/${banner.id}'),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: CachedNetworkImage(
          imageUrl: banner.imageUrl,
          fit: BoxFit.cover,
          // Limit to ~screen width × 2x density
          memCacheWidth: 800,
          placeholder: (_, _) => AppShimmer(height: height, borderRadius: AppSpacing.radiusMd),
          errorWidget: (_, _, _) => Container(color: AppColors.surfaceLight, child: const Icon(Icons.image, color: AppColors.textMuted, size: 48)),
        ),
      ),
    );
  }
}
