import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:elct/core/enums/payment_method.dart';
import 'package:elct/core/firebase/settings_provider.dart';
import 'package:elct/core/widgets/app_toast.dart';
import 'package:elct/core/router/routes.dart';
import 'package:elct/l10n/app_localizations.dart';
import 'package:elct/features/auth/presentation/providers/auth_provider.dart';
import 'package:elct/features/profile/presentation/providers/profile_provider.dart';
import 'package:elct/features/profile/domain/entities/address_entity.dart';
import 'package:elct/features/cart/domain/entities/cart_item_entity.dart';
import 'package:elct/features/cart/presentation/providers/cart_provider.dart';
import 'checkout_provider.dart';
import '../../domain/entities/order_entity.dart';

class CheckoutState {
  final bool isPlacingOrder;
  final bool isApplyingPromo;
  final PaymentMethod selectedPayment;
  final bool showItems;
  final double couponDiscount;
  final String? appliedPromoCode;
  final String? nameError;
  final String? phoneError;
  final String deliveryType; // 'normal' or 'fast'
  final DateTime? deliveryDate;
  final String? deliveryTime;

  const CheckoutState({
    this.isPlacingOrder = false,
    this.isApplyingPromo = false,
    this.selectedPayment = PaymentMethod.cod,
    this.showItems = false,
    this.couponDiscount = 0.0,
    this.appliedPromoCode,
    this.nameError,
    this.phoneError,
    this.deliveryType = 'normal',
    this.deliveryDate,
    this.deliveryTime,
  });

  CheckoutState copyWith({
    bool? isPlacingOrder,
    bool? isApplyingPromo,
    PaymentMethod? selectedPayment,
    bool? showItems,
    double? couponDiscount,
    String? appliedPromoCode,
    String? nameError,
    String? phoneError,
    String? deliveryType,
    DateTime? deliveryDate,
    Object? deliveryTime = _sentinel,
  }) {
    return CheckoutState(
      isPlacingOrder: isPlacingOrder ?? this.isPlacingOrder,
      isApplyingPromo: isApplyingPromo ?? this.isApplyingPromo,
      selectedPayment: selectedPayment ?? this.selectedPayment,
      showItems: showItems ?? this.showItems,
      couponDiscount: couponDiscount ?? this.couponDiscount,
      appliedPromoCode: appliedPromoCode == '' ? null : (appliedPromoCode ?? this.appliedPromoCode),
      nameError: nameError == '' ? null : (nameError ?? this.nameError),
      phoneError: phoneError == '' ? null : (phoneError ?? this.phoneError),
      deliveryType: deliveryType ?? this.deliveryType,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      deliveryTime: deliveryTime == _sentinel ? this.deliveryTime : deliveryTime as String?,
    );
  }
}

const _sentinel = Object();

class CheckoutController extends AutoDisposeNotifier<CheckoutState> {
  late final TextEditingController nameController;
  late final TextEditingController phoneController;
  late final TextEditingController promoController;

  ProviderSubscription? _profileSubscription;
  String? _pendingOrderId;

  @override
  CheckoutState build() {
    nameController = TextEditingController();
    phoneController = TextEditingController();
    promoController = TextEditingController();

    nameController.addListener(() {
      if (state.nameError != null && nameController.text.trim().isNotEmpty) {
        state = state.copyWith(nameError: '');
      }
    });

    phoneController.addListener(() {
      if (state.phoneError != null) {
        final phone = phoneController.text.trim();
        if (phone.isNotEmpty && RegExp(r'^\+?\d{10,15}$').hasMatch(phone)) {
          state = state.copyWith(phoneError: '');
        }
      }
    });

    ref.onDispose(() {
      nameController.dispose();
      phoneController.dispose();
      promoController.dispose();
      _profileSubscription?.close();
    });

    _prefillFromProfile();
    return const CheckoutState();
  }

  void _prefillFromProfile() {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) return;
    
    final cached = ref.read(userProfileProvider(uid));
    if (cached.hasValue) {
      _applyProfileData(cached.value);
    } else {
      // If profile is not loaded yet, apply auth data immediately as a fallback
      _applyProfileData(null);
    }
    
    _profileSubscription = ref.listen(userProfileProvider(uid), (_, next) {
      if (next.hasValue) {
        _applyProfileData(next.value);
      }
    });
  }

  void _applyProfileData(Map<String, dynamic>? data) {
    final authUser = ref.read(authStateProvider).valueOrNull;

    String? profileName;
    String? phoneNumber;

    if (data != null) {
      final displayName = (data['displayName'] as String?)?.trim();
      final firstName = (data['firstName'] as String?)?.trim();
      final lastName = (data['lastName'] as String?)?.trim();
      profileName = displayName != null && displayName.isNotEmpty
          ? displayName
          : [firstName, lastName].where((part) => part != null && part.isNotEmpty).join(' ');
      phoneNumber = data['phoneNumber'] as String?;
    }

    // Use profile name first, then fallback to Firebase Auth display name
    final finalName = (profileName != null && profileName.isNotEmpty)
        ? profileName
        : authUser?.displayName;

    // Use profile phone first, then fallback to Firebase Auth phone number
    final finalPhone = (phoneNumber != null && phoneNumber.isNotEmpty)
        ? phoneNumber
        : authUser?.phoneNumber;

    if (nameController.text.isEmpty && finalName != null && finalName.isNotEmpty) {
      nameController.text = finalName;
    }
    if (phoneController.text.isEmpty && finalPhone != null && finalPhone.isNotEmpty) {
      phoneController.text = _cleanEgyptianPhone(finalPhone);
    }
  }

  String _cleanEgyptianPhone(String phone) {
    String clean = phone.replaceAll(RegExp(r'[\s\-()]'), '');
    if (clean.startsWith('+20')) {
      clean = '0${clean.substring(3)}';
    } else if (clean.startsWith('0020')) {
      clean = '0${clean.substring(4)}';
    } else if (clean.startsWith('20') && clean.length > 10) {
      clean = '0${clean.substring(2)}';
    }
    clean = clean.replaceAll(RegExp(r'\D'), '');
    return clean;
  }

  void toggleItems() => state = state.copyWith(showItems: !state.showItems);
  
  void setPaymentMethod(PaymentMethod method) => state = state.copyWith(selectedPayment: method);

  void setDeliveryType(String type) => state = state.copyWith(deliveryType: type);

  void setDeliveryDate(DateTime date) => state = state.copyWith(deliveryDate: date);

  void setDeliveryTime(String time) => state = state.copyWith(deliveryTime: time);

  bool validateFields(BuildContext context) {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    bool isValid = true;
    String? nameErr;
    String? phoneErr;

    if (name.isEmpty) {
      nameErr = AppLocalizations.of(context)!.fullNameRequired;
      isValid = false;
    }
    if (phone.isEmpty) {
      phoneErr = AppLocalizations.of(context)!.phoneRequired;
      isValid = false;
    } else if (!RegExp(r'^\+?\d{10,15}$').hasMatch(phone)) {
      phoneErr = AppLocalizations.of(context)!.phoneInvalid;
      isValid = false;
    }

    state = state.copyWith(nameError: nameErr ?? '', phoneError: phoneErr ?? '');
    if (!isValid && context.mounted) {
      AppToast.show(context, AppLocalizations.of(context)!.required, icon: Icons.error_outline);
    }
    return isValid;
  }

  Future<void> applyPromoCode(BuildContext context, double subtotal) async {
    final code = promoController.text.trim().toUpperCase();
    if (code.isEmpty) return;
    if (state.isApplyingPromo) return;

    state = state.copyWith(isApplyingPromo: true);
    try {
      final repo = ref.read(checkoutRepositoryProvider);
      final promo = await repo.validatePromoCode(code);
      if (promo == null) {
        if (context.mounted) AppToast.show(context, AppLocalizations.of(context)!.invalidCoupon, icon: Icons.error_outline_rounded);
        return;
      }
      state = state.copyWith(
        couponDiscount: subtotal * (promo.discountPercent / 100),
        appliedPromoCode: code,
      );
      if (context.mounted) {
        AppToast.show(context, AppLocalizations.of(context)!.promoSuccess(promo.discountPercent.toInt()), icon: Icons.celebration_rounded);
      }
    } catch (e) {
      if (context.mounted) AppToast.show(context, AppLocalizations.of(context)!.invalidCoupon, icon: Icons.error_outline_rounded);
    } finally {
      state = state.copyWith(isApplyingPromo: false);
    }
  }

  void clearPromoCode() {
    state = state.copyWith(couponDiscount: 0.0, appliedPromoCode: '');
    promoController.clear();
  }

  Future<void> placeOrder(
    BuildContext context,
    AddressEntity address,
    List<CartItemEntity> items,
  ) async {
    if (!_validateOrder(context)) return;

    state = state.copyWith(isPlacingOrder: true);
    final t = AppLocalizations.of(context)!;

    try {
      final userId = ref.read(currentUserIdProvider);
      if (userId == null) throw StateError('USER_NULL');

      if (!context.mounted) return;
      if (!await _processPayment(context, state.selectedPayment)) return;

      final (subtotal, shipping, total, shippingAddress, orderItems) =
          await _calculateOrder(address, items);

      final order = await _createOrderRecord(
        userId, subtotal, shipping, total, shippingAddress, orderItems,
      );

      if (context.mounted) context.go('${Routes.orderSuccess}/${order.id}');

      await _clearCart(userId);
    } catch (e) {
      if (context.mounted) _handleOrderError(e, t, context);
    } finally {
      state = state.copyWith(isPlacingOrder: false);
    }
  }

  bool _validateOrder(BuildContext context) {
    if (!validateFields(context)) return false;

    if (state.selectedPayment.isComingSoon) {
      AppToast.show(
        context,
        AppLocalizations.of(context)!.checkoutUnavailable,
        icon: Icons.warning_amber_rounded,
      );
      return false;
    }

    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          AppToast.show(context, AppLocalizations.of(context)!.loginRequired, icon: Icons.warning);
        }
      });
      return false;
    }
    return true;
  }

  Future<(double, double, double, Map<String, dynamic>, List<Map<String, dynamic>>)>
      _calculateOrder(AddressEntity address, List<CartItemEntity> items) async {
    final subtotal = items.fold(0.0, (sum, item) => sum + item.totalPrice);
    final settings = await ref.read(shippingSettingsProvider.future);
    final shipping = state.deliveryType == 'fast'
        ? settings.fastCostForSubtotal(subtotal)
        : settings.costForSubtotal(subtotal);
    final total = (subtotal - state.couponDiscount) + shipping;

    final shippingAddress = {
      'name': nameController.text.trim(),
      'phone': phoneController.text.trim(),
      'address': address.street,
      'city': address.city,
      'label': address.label,
      'latitude': address.latitude,
      'longitude': address.longitude,
    };

    final orderItems = items.map((item) => {
      'productId': item.productId,
      'nameAr': item.nameAr,
      'nameEn': item.nameEn,
      'image': item.image,
      'price': item.price,
      'quantity': item.quantity,
      'selectedOptions': item.selectedOptions,
    }).toList();

    return (subtotal, shipping, total, shippingAddress, orderItems);
  }

  Future<OrderEntity> _createOrderRecord(
    String userId,
    double subtotal,
    double shipping,
    double total,
    Map<String, dynamic> shippingAddress,
    List<Map<String, dynamic>> orderItems,
  ) async {
    if (_pendingOrderId == null) {
      final now = DateTime.now().millisecondsSinceEpoch.toString();
      final randomPart = Random().nextInt(9999).toString().padLeft(4, '0');
      _pendingOrderId = '${now.substring(now.length - 4)}$randomPart';
    }

    return ref.read(checkoutRepositoryProvider).placeOrder(
      orderId: _pendingOrderId!,
      userId: userId,
      items: orderItems,
      subtotal: subtotal,
      shipping: shipping,
      total: total,
      shippingAddress: shippingAddress,
      paymentMethod: state.selectedPayment.value,
      promoCode: state.appliedPromoCode,
      deliveryType: state.deliveryType,
      deliveryDate: state.deliveryDate?.toIso8601String(),
      deliveryTime: state.deliveryTime,
    );
  }

  Future<void> _clearCart(String userId) async {
    _pendingOrderId = null;
    try {
      await ref.read(cartRepositoryProvider).clearCart(userId);
    } catch (_) {}
  }

  void _handleOrderError(Object e, AppLocalizations t, BuildContext context) {
    final msg = e.toString();
    String userMsg =
        (msg.contains('promoNotFound') || msg.contains('promoExpiredOrUsed'))
        ? t.invalidCoupon
        : t.orderFailed(msg.replaceFirst('Exception: ', ''));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) AppToast.show(context, userMsg);
    });
  }

  Future<bool> _processPayment(BuildContext context, PaymentMethod method) async {
    switch (method) {
      case PaymentMethod.cod:
        return true;
      case PaymentMethod.card:
        if (context.mounted) AppToast.show(context, AppLocalizations.of(context)!.cardUnavailable, icon: Icons.credit_card);
        return false;
      case PaymentMethod.wallet:
        if (context.mounted) AppToast.show(context, AppLocalizations.of(context)!.walletUnavailable, icon: Icons.account_balance_wallet);
        return false;
    }
  }
}

final checkoutControllerProvider = AutoDisposeNotifierProvider<CheckoutController, CheckoutState>(
  () => CheckoutController(),
);
