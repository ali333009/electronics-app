import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:elct/l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';
import '../providers/pending_redirect_provider.dart';
import 'app_button.dart';
import '../router/routes.dart';

void showLoginRequiredSheet(BuildContext context, {required String redirectPath}) {
    final t = AppLocalizations.of(context);
    if (t == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _LoginRequiredBottomSheet(redirectPath: redirectPath),
    );
  }

class _LoginRequiredBottomSheet extends StatelessWidget {
  final String redirectPath;

  const _LoginRequiredBottomSheet({required this.redirectPath});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lock_outline, color: AppColors.gold, size: 28),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            loc.loginRequired,
            style: AppTypography.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            loc.loginRequiredSubtitle,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              text: loc.login,
              onPressed: () {
                ProviderScope.containerOf(context, listen: false)
                    .read(pendingRedirectProvider.notifier)
                    .state = redirectPath;
                Navigator.pop(context);
                context.push(Routes.login);
              },
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              text: loc.createAccount,
              isOutlined: true,
              onPressed: () {
                ProviderScope.containerOf(context, listen: false)
                    .read(pendingRedirectProvider.notifier)
                    .state = redirectPath;
                Navigator.pop(context);
                context.push(Routes.register);
              },
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              loc.browseAsGuest,
              style: AppTypography.bodyLarge.copyWith(
                fontSize: 14,
                color: AppColors.textMuted,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}
