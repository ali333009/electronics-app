import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final int cartCount;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.cartCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navItems.length, (index) {
              final isSelected = index == currentIndex;
              return GestureDetector(
                onTap: () => onTap(index),
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 56,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      index == 3 && cartCount > 0
                          ? Badge(
                              label: Text(cartCount.toString(), style: const TextStyle(fontSize: 10, color: Colors.white)),
                              child: Icon(
                                _navItems[index],
                                color: isSelected ? AppColors.gold : AppColors.textMuted,
                                size: 24,
                              ).animate(target: isSelected ? 1 : 0).scale(
                                begin: const Offset(1, 1),
                                end: const Offset(1.15, 1.15),
                                duration: 200.ms,
                                curve: Curves.easeOut,
                              ),
                            )
                          : Icon(
                              _navItems[index],
                              color: isSelected ? AppColors.gold : AppColors.textMuted,
                              size: 24,
                            ).animate(target: isSelected ? 1 : 0).scale(
                              begin: const Offset(1, 1),
                              end: const Offset(1.15, 1.15),
                              duration: 200.ms,
                              curve: Curves.easeOut,
                            ),
                      const SizedBox(height: 4),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isSelected ? 20 : 0,
                        height: 3,
                        decoration: BoxDecoration(
                          color: AppColors.gold,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

const _navItems = [
  Icons.home_outlined,
  Icons.category_outlined,
  Icons.favorite_outline,
  Icons.shopping_cart_outlined,
  Icons.person_outline,
];
