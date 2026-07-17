import 'package:flutter/material.dart';
import 'package:elct/l10n/app_localizations.dart';
import 'package:elct/core/theme/app_colors.dart';

class CountryCode {
  final String name;
  final String code;
  final String flag;
  final String formatHint;
  final int maxLength;

  const CountryCode({
    required this.name,
    required this.code,
    required this.flag,
    required this.formatHint,
    required this.maxLength,
  });
}

const List<CountryCode> countries = [
  CountryCode(
    name: 'الكويت',
    code: '+965',
    flag: '🇰🇼',
    formatHint: '3xx xxxxxxx',
    maxLength: 8,
  ),
  CountryCode(
    name: 'المملكة العربية السعودية',
    code: '+966',
    flag: '🇸🇦',
    formatHint: '5xxxxxxxx',
    maxLength: 9,
  ),
  CountryCode(
    name: 'الإمارات العربية المتحدة',
    code: '+971',
    flag: '🇦🇪',
    formatHint: '5xxxxxxxx',
    maxLength: 9,
  ),
  CountryCode(
    name: 'قطر',
    code: '+974',
    flag: '🇶🇦',
    formatHint: 'xxxxxxxx',
    maxLength: 8,
  ),
  CountryCode(
    name: 'البحرين',
    code: '+973',
    flag: '🇧🇭',
    formatHint: 'xxxxxxxx',
    maxLength: 8,
  ),
  CountryCode(
    name: 'عمان',
    code: '+968',
    flag: '🇴🇲',
    formatHint: 'xxxxxxxx',
    maxLength: 8,
  ),
  CountryCode(
    name: 'مصر',
    code: '+20',
    flag: '🇪🇬',
    formatHint: '1xxxxxxxxx',
    maxLength: 10,
  ),
];

class CountryPickerPrefix extends StatelessWidget {
  final CountryCode selectedCountry;
  final VoidCallback onTap;

  const CountryPickerPrefix({
    super.key,
    required this.selectedCountry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onTap,
            child: Row(
              children: [
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  selectedCountry.flag,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 6),
                Text(
                  selectedCountry.code,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textDirection: TextDirection.ltr,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(width: 1, height: 24, color: AppColors.border),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}

void showCountryPickerDialog({
  required BuildContext context,
  required CountryCode selectedCountry,
  required List<CountryCode> countries,
  required ValueChanged<CountryCode> onCountrySelected,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (dialogContext) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(dialogContext)!.selectCountryCode,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: countries.length,
                itemBuilder: (context, index) {
                  final country = countries[index];
                  final isSelected = country.code == selectedCountry.code;
                  return ListTile(
                    leading: Text(
                      country.flag,
                      style: const TextStyle(fontSize: 22),
                    ),
                    title: Text(
                      country.name,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected
                            ? AppColors.gold
                            : AppColors.textPrimary,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          country.code,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w600,
                            color: isSelected
                                ? AppColors.gold
                                : AppColors.textSecondary,
                          ),
                          textDirection: TextDirection.ltr,
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.gold,
                            size: 18,
                          ),
                        ],
                      ],
                    ),
                    onTap: () {
                      onCountrySelected(country);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}
