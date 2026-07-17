import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elct/l10n/app_localizations.dart';
import 'package:elct/core/network/connectivity_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class ConnectivityBanner extends ConsumerWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isConnected = ref.watch(connectivityProvider).valueOrNull ?? true;
    if (isConnected) return const SizedBox.shrink();

    return Positioned.fill(
      child: AbsorbPointer(
        child: Material(
          color: Colors.white,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.wifi_off_rounded,
                    size: 80,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppLocalizations.of(context)!.noConnection,
                    style: AppTypography.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(context)!.noConnectionSubtitle,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
