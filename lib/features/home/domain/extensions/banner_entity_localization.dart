import 'package:flutter/widgets.dart';
import '../entities/banner_entity.dart';

String _localeValue(BuildContext context, String en, String ar) {
  return Localizations.localeOf(context).languageCode == 'en' ? en : ar;
}

extension BannerEntityLocalization on BannerEntity {
  String displayTitle(BuildContext context) => _localeValue(context, titleEn, titleAr);
  String? displaySubtitle(BuildContext context) => _localeValue(context, subtitleEn ?? '', subtitleAr ?? '');
}
