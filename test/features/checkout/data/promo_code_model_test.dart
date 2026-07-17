import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elct/features/checkout/data/models/promo_code_model.dart';

void main() {
  group('PromoCodeModel', () {
    test('parses fromFirestore correctly', () {
      final model = PromoCodeModel.fromFirestore({
        'code': 'SAVE20',
        'discountPercent': 20.0,
        'maxUses': 100,
        'currentUses': 5,
        'isActive': true,
      });
      expect(model.code, 'SAVE20');
      expect(model.discountPercent, 20.0);
      expect(model.isUnlimited, false);
    });

    test('isUnlimited returns true when maxUses is 0', () {
      final model = PromoCodeModel.fromFirestore({
        'code': 'FREE',
        'discountPercent': 100.0,
        'maxUses': 0,
      });
      expect(model.isUnlimited, true);
    });

    test('isValid returns false when expired', () {
      final model = PromoCodeModel.fromFirestore({
        'code': 'EXPIRED',
        'discountPercent': 10.0,
        'expiresAt': Timestamp.fromDate(DateTime(2020, 1, 1)),
        'isActive': true,
      });
      expect(model.isValid, false);
    });

    test('isValid returns false when maxUses reached', () {
      final model = PromoCodeModel.fromFirestore({
        'code': 'USED',
        'discountPercent': 10.0,
        'maxUses': 10,
        'currentUses': 10,
        'isActive': true,
      });
      expect(model.isValid, false);
    });

    test('isValid returns false when inactive', () {
      final model = PromoCodeModel.fromFirestore({
        'code': 'INACTIVE',
        'discountPercent': 10.0,
        'isActive': false,
      });
      expect(model.isValid, false);
    });

    test('isValid returns true for active valid promo', () {
      final model = PromoCodeModel.fromFirestore({
        'code': 'VALID',
        'discountPercent': 15.0,
        'maxUses': 100,
        'currentUses': 5,
        'isActive': true,
      });
      expect(model.isValid, true);
    });
  });
}
