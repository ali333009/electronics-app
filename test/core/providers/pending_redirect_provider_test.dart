import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elct/core/providers/pending_redirect_provider.dart';

void main() {
  group('pendingRedirectProvider', () {
    test('starts with null', () {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());
      expect(container.read(pendingRedirectProvider), null);
    });

    test('can be set and read', () {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());
      container.read(pendingRedirectProvider.notifier).state = '/cart';
      expect(container.read(pendingRedirectProvider), '/cart');
    });
  });
}
