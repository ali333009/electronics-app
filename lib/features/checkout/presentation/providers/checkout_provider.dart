import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/checkout_repository_impl.dart';
import '../../domain/repositories/i_checkout_repository.dart';

final checkoutRepositoryProvider = Provider<ICheckoutRepository>((ref) {
  return CheckoutRepositoryImpl();
});
