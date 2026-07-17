import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elct/features/cart/presentation/providers/cart_provider.dart';
import 'package:elct/features/cart/presentation/providers/guest_cart_provider.dart';
import 'package:elct/core/services/notification_service.dart';
import 'package:elct/core/utils/log.dart';

Future<void> mergeGuestCartAndNotify(WidgetRef ref, String userId) async {
  await ref
      .read(guestCartProvider.notifier)
      .mergeToFirestore(ref.read(cartRepositoryProvider), userId);
  try {
    await NotificationService.instance.onUserLogin();
  } catch (e) {
    logDebug('[Auth] Notification init failed: $e');
  }
}
