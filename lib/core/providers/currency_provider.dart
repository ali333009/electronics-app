import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/currency.dart';

const _currencyKey = 'selected_currency';

class CurrencyNotifier extends StateNotifier<Currency> {
  CurrencyNotifier() : super(Currency.available.first);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_currencyKey);
    if (code != null) {
      state = Currency.fromCode(code);
    }
  }

  Future<void> setCurrency(Currency currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, currency.code);
    state = currency;
  }
}

final currencyProvider = StateNotifierProvider<CurrencyNotifier, Currency>((ref) {
  return CurrencyNotifier();
});
