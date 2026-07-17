import 'package:flutter/widgets.dart';
import '../entities/product_entity.dart';

String _localeValue(BuildContext context, String en, String ar) {
  return Localizations.localeOf(context).languageCode == 'en' ? en : ar;
}

extension ProductEntityLocalization on ProductEntity {
  String displayName(BuildContext context) => _localeValue(context, nameEn, nameAr);
  String displayDescription(BuildContext context) => _localeValue(context, descriptionEn, descriptionAr);
}
