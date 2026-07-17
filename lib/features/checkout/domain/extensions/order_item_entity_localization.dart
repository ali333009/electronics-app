import 'package:flutter/widgets.dart';
import '../entities/order_entity.dart';

String _localeValue(BuildContext context, String en, String ar) {
  return Localizations.localeOf(context).languageCode == 'en' ? en : ar;
}

extension OrderItemEntityLocalization on OrderItemEntity {
  String displayName(BuildContext context) => _localeValue(context, nameEn, nameAr);
}
