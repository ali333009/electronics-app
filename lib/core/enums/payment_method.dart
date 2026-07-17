import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

enum PaymentMethod {
  cod,
  card,
  wallet,
}

extension PaymentMethodX on PaymentMethod {
  String get value {
    switch (this) {
      case PaymentMethod.cod:
        return 'cod';
      case PaymentMethod.card:
        return 'card';
      case PaymentMethod.wallet:
        return 'wallet';
    }
  }

  String label(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case PaymentMethod.cod:
        return l10n.cashOnDelivery;
      case PaymentMethod.card:
        return l10n.creditCard;
      case PaymentMethod.wallet:
        return l10n.digitalWallet;
    }
  }

  String subtitle(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case PaymentMethod.cod:
        return l10n.paymentMethodCodSubtitle;
      case PaymentMethod.card:
        return l10n.comingSoon;
      case PaymentMethod.wallet:
        return l10n.comingSoon;
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentMethod.cod:
        return Icons.payments;
      case PaymentMethod.card:
        return Icons.credit_card;
      case PaymentMethod.wallet:
        return Icons.account_balance_wallet;
    }
  }

  bool get isComingSoon {
    switch (this) {
      case PaymentMethod.cod:
        return false;
      case PaymentMethod.card:
        return true;
      case PaymentMethod.wallet:
        return true;
    }
  }
}
