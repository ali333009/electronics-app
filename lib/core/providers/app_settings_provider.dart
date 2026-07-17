import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppSettings {
  final String storeNameAr;
  final String storeNameEn;
  final String currency;
  final String email;
  final num freeShippingThreshold;
  final String instagram;
  final String youtube;
  final String snapchat;
  final String facebook;
  final String phone;
  final num shippingFee;
  final String tiktok;
  final String twitter;
  final String whatsapp;
  final List<String> enabledCurrencies;
  
  AppSettings({
    this.storeNameAr = 'إلكترونيك',
    this.storeNameEn = 'ELECTRONIC',
    this.currency = 'د.ك',
    this.email = '',
    this.freeShippingThreshold = 10,
    this.instagram = '',
    this.youtube = '',
    this.snapchat = '',
    this.facebook = '',
    this.phone = '',
    this.shippingFee = 30,
    this.tiktok = '',
    this.twitter = '',
    this.whatsapp = '',
    this.enabledCurrencies = const <String>[],
  });
  
  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      storeNameAr: map['storeNameAr'] as String? ?? 'إلكترونيك',
      storeNameEn: map['storeNameEn'] as String? ?? 'ELECTRONIC',
      currency: map['currency'] as String? ?? 'د.ك',
      email: map['email'] as String? ?? '',
      freeShippingThreshold: map['freeShippingThreshold'] as num? ?? 10,
      instagram: map['instagram'] as String? ?? '',
      youtube: map['youtube'] as String? ?? '',
      snapchat: map['snapchat'] as String? ?? '',
      facebook: map['facebook'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      shippingFee: map['shippingFee'] as num? ?? 30,
      tiktok: map['tiktok'] as String? ?? '',
      twitter: map['twitter'] as String? ?? '',
      whatsapp: map['whatsapp'] as String? ?? '',
      enabledCurrencies: (map['enabledCurrencies'] as List<dynamic>?)?.cast<String>() ??
          ['KWD','AED','BHD','QAR','OMR','SAR','USD','IQD'],
    );
  }
}

final appSettingsProvider = StreamProvider<AppSettings>((ref) {
  return FirebaseFirestore.instance
      .collection('_meta')
      .doc('store_config')
      .snapshots()
      .map((snapshot) {
    if (snapshot.exists && snapshot.data() != null) {
      return AppSettings.fromMap(snapshot.data()!);
    }
    return AppSettings();
  });
});
