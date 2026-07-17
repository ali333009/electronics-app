import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../products/domain/entities/product_entity.dart';
import 'package:elct/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../../core/providers/currency_provider.dart';
import '../../../../core/providers/app_settings_provider.dart';

class BottomBar extends ConsumerStatefulWidget {
  final ProductEntity product;
  final int quantity;
  final int stockQuantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final Future<void> Function() onAddToCart;

  const BottomBar({
    super.key,
    required this.product,
    required this.quantity,
    required this.stockQuantity,
    required this.onDecrement,
    required this.onIncrement,
    required this.onAddToCart,
  });

  @override
  ConsumerState<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends ConsumerState<BottomBar>
    with SingleTickerProviderStateMixin {
  bool _isAddingToCart = false;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -4.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -4.0, end: 4.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 4.0, end: -4.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -4.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _handleAddToCart() async {
    if (_isAddingToCart) return;
    setState(() => _isAddingToCart = true);
    try {
      await widget.onAddToCart();
    } finally {
      if (mounted) setState(() => _isAddingToCart = false);
    }
  }

  void _handleIncrementAtMax() {
    HapticFeedback.lightImpact();
    _shakeController.forward(from: 0);
  }

  /// Returns stock badge color and label based on remaining quantity
  (Color color, String label) _stockBadge(BuildContext context, int stock) {
    final l10n = AppLocalizations.of(context)!;
    if (stock == 1) {
      return (AppColors.error, l10n.lastPieceAlert);
    } else if (stock <= 5) {
      return (const Color(0xFFE07B00), l10n.lowStockAlert(stock));
    } else {
      return (AppColors.textSecondary, l10n.stockAvailable(stock));
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(currencyProvider);
    final total = widget.product.price * widget.quantity;
    final isOutOfStock = widget.stockQuantity == 0;
    final atMax = widget.quantity >= widget.stockQuantity;
    final (stockColor, stockLabel) = isOutOfStock
        ? (AppColors.error, AppLocalizations.of(context)!.outOfStock)
        : _stockBadge(context, widget.stockQuantity);
    final whatsappNumber = ref.watch(appSettingsProvider).valueOrNull?.whatsapp ?? '';

    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Stock badge row
          if (!isOutOfStock)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, anim) =>
                        FadeTransition(opacity: anim, child: child),
                    child: Container(
                      key: ValueKey(widget.stockQuantity),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: stockColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: stockColor.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.stockQuantity == 1
                                ? Icons.local_fire_department_rounded
                                : Icons.inventory_2_outlined,
                            size: 13,
                            color: stockColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            stockLabel,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: stockColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Main row: [whatsapp + qty] [add to cart]
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Right side: whatsapp + qty selector (compact) ──
              if (whatsappNumber.isNotEmpty)
                GestureDetector(
                  onTap: () async {
                    String cleanNumber = whatsappNumber.replaceAll(RegExp(r'[^\d+]'), '');
                    if (!cleanNumber.startsWith('+') && !cleanNumber.startsWith('00')) {
                      cleanNumber = '+965$cleanNumber';
                    }
                    if (cleanNumber.startsWith('00')) {
                      cleanNumber = '+${cleanNumber.substring(2)}';
                    }
                    final url = Uri.parse('https://wa.me/${cleanNumber.replaceAll('+', '')}');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF25D366),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: FaIcon(FontAwesomeIcons.whatsapp, color: Colors.white, size: 19),
                    ),
                  ),
                ),
              if (whatsappNumber.isNotEmpty) const SizedBox(width: 8),
              if (!isOutOfStock)
                AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) => Transform.translate(
                    offset: Offset(_shakeAnimation.value, 0),
                    child: child,
                  ),
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      border: Border.all(color: AppColors.divider),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _QtyBtn(
                          icon: Icons.remove,
                          onTap: widget.onDecrement,
                        ),
                        Container(
                          constraints: const BoxConstraints(minWidth: 28),
                          alignment: Alignment.center,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            transitionBuilder: (child, anim) =>
                                ScaleTransition(scale: anim, child: child),
                            child: Text(
                              '${widget.quantity}',
                              key: ValueKey(widget.quantity),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        _QtyBtn(
                          icon: Icons.add,
                          onTap: atMax ? _handleIncrementAtMax : widget.onIncrement,
                          disabled: atMax,
                        ),
                      ],
                    ),
                  ),
                ),
              if (isOutOfStock) const SizedBox(width: 8),

              const Spacer(),

              // ── Left side: Add to Cart (prominent) ──
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isOutOfStock || _isAddingToCart
                        ? null
                        : _handleAddToCart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isOutOfStock
                          ? AppColors.textMuted
                          : _isAddingToCart
                              ? AppColors.gold.withValues(alpha: 0.7)
                              : AppColors.gold,
                      foregroundColor: AppColors.textDark,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: _isAddingToCart
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.shopping_cart_outlined, size: 17),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  isOutOfStock
                                      ? AppLocalizations.of(context)!.outOfStock
                                      : AppLocalizations.of(context)!.addToCart,
                                  style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (!isOutOfStock) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    total.formatPrice(currency),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool disabled;

  const _QtyBtn({
    required this.icon,
    required this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: disabled ? null : onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          size: 16,
          color: disabled ? AppColors.textMuted.withValues(alpha: 0.4) : AppColors.textPrimary,
        ),
      ),
    );
  }
}
