class Currency {
  final String code;
  final String name;
  final String nameEn;
  final String symbol;
  final double rate;
  final String flag;

  const Currency({
    required this.code,
    required this.name,
    required this.nameEn,
    required this.symbol,
    required this.rate,
    required this.flag,
  });

  static const List<Currency> available = [
    Currency(code: 'KWD', name: 'دينار كويتي', nameEn: 'Kuwaiti Dinar', symbol: 'KD', rate: 1.0, flag: '🇰🇼'),
    Currency(code: 'AED', name: 'درهم إماراتي', nameEn: 'UAE Dirham', symbol: 'AED', rate: 12.10, flag: '🇦🇪'),
    Currency(code: 'BHD', name: 'دينار بحريني', nameEn: 'Bahraini Dinar', symbol: 'BD', rate: 1.22, flag: '🇧🇭'),
    Currency(code: 'QAR', name: 'ريال قطري', nameEn: 'Qatari Riyal', symbol: 'QR', rate: 13.19, flag: '🇶🇦'),
    Currency(code: 'OMR', name: 'ريال عماني', nameEn: 'Omani Riyal', symbol: 'OMR', rate: 1.39, flag: '🇴🇲'),
    Currency(code: 'SAR', name: 'ريال سعودي', nameEn: 'Saudi Riyal', symbol: 'SR', rate: 12.38, flag: '🇸🇦'),
    Currency(code: 'USD', name: 'دولار أمريكي', nameEn: 'US Dollar', symbol: r'$', rate: 3.30, flag: '🇺🇸'),
    Currency(code: 'IQD', name: 'دينار عراقي', nameEn: 'Iraqi Dinar', symbol: 'IQD', rate: 4285.0, flag: '🇮🇶'),
  ];

  Currency get defaultCurrency => available.first;

  static Currency fromCode(String code) {
    return available.firstWhere((c) => c.code == code, orElse: () => available.first);
  }
}
