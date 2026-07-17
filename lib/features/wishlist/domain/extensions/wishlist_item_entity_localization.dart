import 'package:flutter/widgets.dart';
import '../entities/wishlist_item_entity.dart';

String _localeValue(BuildContext context, String en, String ar) {
  return Localizations.localeOf(context).languageCode == 'en' ? en : ar;
}

extension WishlistItemEntityLocalization on WishlistItemEntity {
  String displayName(BuildContext context) => _localeValue(context, nameEn, nameAr);
}
