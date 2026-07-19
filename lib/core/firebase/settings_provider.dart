import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShippingSettings {
  final double freeShippingThreshold;
  final double shippingCost;
  final double fastShippingCost;
  final int availableDaysCount;
  final String normalDescriptionAr;
  final String normalDescriptionEn;
  final String expressDescriptionAr;
  final String expressDescriptionEn;
  final List<String> expressTimeSlots;

  const ShippingSettings({
    this.freeShippingThreshold = 500,
    this.shippingCost = 30,
    this.fastShippingCost = 60,
    this.availableDaysCount = 3,
    this.normalDescriptionAr = 'توصيل خلال 3-5 أيام',
    this.normalDescriptionEn = 'Delivery within 3-5 days',
    this.expressDescriptionAr = 'توصيل خلال 24 ساعة',
    this.expressDescriptionEn = 'Delivery within 24 hours',
    this.expressTimeSlots = const [],
  });

  factory ShippingSettings.fromFirestore(Map<String, dynamic>? data) {
    if (data == null) return ShippingSettings();
    return ShippingSettings(
      freeShippingThreshold: _readDouble(data['freeShippingThreshold'], 500),
      shippingCost: _readDouble(data['shippingCost'] ?? data['shippingFee'], 30),
      fastShippingCost: _readDouble(data['fastShippingCost'] ?? data['fastShippingFee'], 60),
      availableDaysCount: (data['availableDaysCount'] as num?)?.toInt() ?? 3,
      normalDescriptionAr: (data['normalDescriptionAr'] as String?) ?? (data['normalDescription'] as String?) ?? 'توصيل خلال 3-5 أيام',
      normalDescriptionEn: (data['normalDescriptionEn'] as String?) ?? 'Delivery within 3-5 days',
      expressDescriptionAr: (data['expressDescriptionAr'] as String?) ?? (data['expressDescription'] as String?) ?? 'توصيل خلال 24 ساعة',
      expressDescriptionEn: (data['expressDescriptionEn'] as String?) ?? 'Delivery within 24 hours',
      expressTimeSlots: (data['expressTimeSlots'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  String localizedNormalDescription(Locale locale) =>
      locale.languageCode == 'en' ? normalDescriptionEn : normalDescriptionAr;

  String localizedExpressDescription(Locale locale) =>
      locale.languageCode == 'en' ? expressDescriptionEn : expressDescriptionAr;

  bool get isAlwaysFree => shippingCost <= 0 || freeShippingThreshold <= 0;

  double costForSubtotal(double subtotal) {
    if (isAlwaysFree || subtotal >= freeShippingThreshold) return 0;
    return shippingCost;
  }

  double fastCostForSubtotal(double subtotal) {
    return fastShippingCost;
  }

  static double _readDouble(Object? value, double fallback) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }

  Map<String, dynamic> toFirestore() => {
    'freeShippingThreshold': freeShippingThreshold,
    'shippingCost': shippingCost,
    'fastShippingCost': fastShippingCost,
  };
}

final shippingSettingsProvider = StreamProvider<ShippingSettings>((ref) {
  return FirebaseFirestore.instance
      .collection('settings')
      .doc('shipping')
      .snapshots()
      .map((doc) => ShippingSettings.fromFirestore(doc.data()));
});
