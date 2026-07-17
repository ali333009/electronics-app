import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';


class ImageHeader extends StatefulWidget {
  final String productId;
  final List<String> images;

  const ImageHeader({
    super.key,
    required this.productId,
    required this.images,
  });

  @override
  State<ImageHeader> createState() => _ImageHeaderState();
}

class _ImageHeaderState extends State<ImageHeader> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(() {
      if (!mounted) return;
      final page = _pageController.page;
      if (page != null && page.round() != _currentPage) {
        setState(() => _currentPage = page.round());
      }
    });

    // Preload all product images into cache for instant swipe
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final url in widget.images) {
        precacheImage(CachedNetworkImageProvider(url), context);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (widget.images.isNotEmpty)
            PageView(
              controller: _pageController,
              children: widget.images.asMap().entries.map((e) =>
                e.key == 0
                    ? Hero(tag: 'product_${widget.productId}', child: CachedNetworkImage(
                        imageUrl: e.value,
                        fit: BoxFit.cover,
                        memCacheWidth: 800,
                        placeholder: (_, _) => Container(color: AppColors.surfaceCard, child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold))),
                        errorWidget: (_, _, _) => Container(color: AppColors.surfaceCard, child: const Icon(Icons.image_outlined, size: 80, color: AppColors.textMuted)),
                      ))
                    : CachedNetworkImage(
                        imageUrl: e.value,
                        fit: BoxFit.cover,
                        memCacheWidth: 800,
                        placeholder: (_, _) => Container(color: AppColors.surfaceCard, child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold))),
                        errorWidget: (_, _, _) => Container(color: AppColors.surfaceCard, child: const Icon(Icons.image_outlined, size: 80, color: AppColors.textMuted)),
                      ),
              ).toList(),
            )
          else
            Container(color: AppColors.surfaceCard, child: const Icon(Icons.image_outlined, size: 80, color: AppColors.textMuted)),

          if (widget.images.length > 1)
            Positioned(
              bottom: 12, left: 0, right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.images.length, (i) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _currentPage ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _currentPage ? AppColors.gold : AppColors.white.withValues(alpha: 0.5),
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
