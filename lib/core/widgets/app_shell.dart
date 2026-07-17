import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:elct/l10n/app_localizations.dart';
import 'package:elct/core/theme/app_colors.dart';
import 'package:elct/core/theme/app_typography.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'app_bottom_nav.dart';
import 'login_required_bottom_sheet.dart';
import '../router/routes.dart';

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final bool isLoggedIn;
  final int cartCount;
  final String whatsappNumber;

  const AppShell({
    super.key,
    required this.navigationShell,
    required this.isLoggedIn,
    required this.cartCount,
    this.whatsappNumber = '',
  });

  @override
  Widget build(BuildContext context) {
    final currentIndex = navigationShell.currentIndex;

    void onTabTap(int index) {
      if (index == currentIndex) return;
      if (!isLoggedIn && (index == 2 || index == 4)) {
        final targetRoute = switch (index) {
          0 => Routes.home,
          1 => Routes.categories,
          2 => Routes.wishlist,
          3 => Routes.cart,
          4 => Routes.profile,
          _ => Routes.home,
        };
        showLoginRequiredSheet(context, redirectPath: targetRoute);
        return;
      }
      navigationShell.goBranch(index);
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (currentIndex != 0) {
          navigationShell.goBranch(0);
        } else {
          HapticFeedback.lightImpact();
          final l10n = AppLocalizations.of(context)!;
          showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                l10n.exitTitle,
                textAlign: TextAlign.center,
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Text(
                l10n.exitConfirm,
                textAlign: TextAlign.center,
                style: AppTypography.bodyLarge.copyWith(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                child: Text(
                  l10n.cancel,
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                child: Text(
                  l10n.confirm,
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ),
              ],
            ),
          ).then((confirmed) {
            if (confirmed == true && context.mounted) {
              SystemNavigator.pop();
            }
          });
        }
      },
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: AppBottomNav(
          currentIndex: currentIndex,
          onTap: onTabTap,
          cartCount: cartCount,
        ),
        floatingActionButton: (whatsappNumber.isNotEmpty && currentIndex == 0)
            ? FloatingActionButton(
                onPressed: () async {
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
                backgroundColor: const Color(0xFF25D366),
                shape: const CircleBorder(),
                elevation: 4,
                child: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.white, size: 28),
              )
            : null,
      ),
    );
  }
}
