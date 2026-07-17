import 'package:flutter/widgets.dart';
import '../entities/category_entity.dart';

String _localeValue(BuildContext context, String en, String ar) {
  return Localizations.localeOf(context).languageCode == 'en' ? en : ar;
}

extension CategoryEntityLocalization on CategoryEntity {
  String displayName(BuildContext context) => _localeValue(context, nameEn, nameAr);
}
