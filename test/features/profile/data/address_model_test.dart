import 'package:flutter_test/flutter_test.dart';
import 'package:elct/features/profile/data/models/address_model.dart';

void main() {
  group('AddressModel', () {
    test('creates with required fields', () {
      final addr = AddressModel(
        id: 'addr-1',
        label: 'Home',
        city: 'Kuwait City',
        street: 'Main Street',
      );
      expect(addr.isDefault, false);
    });

    test('fromFirestore parses correctly', () {
      final addr = AddressModel.fromFirestore({
        'label': 'Work',
        'city': 'Salmiya',
        'street': 'Street 1',
        'isDefault': true,
      }, id: 'addr-2');
      expect(addr.id, 'addr-2');
      expect(addr.isDefault, true);
    });

    test('fromFirestore parses countryCode from label', () {
      final addr = AddressModel.fromFirestore({
        'label': 'KW,29.3759,47.9774',
        'city': 'Kuwait City',
        'street': 'Street',
      }, id: 'addr-3');
      expect(addr.countryCode, 'KW');
    });

    test('copyWith creates updated copy', () {
      final addr = AddressModel(id: 'a1', label: 'Home', city: 'City', street: 'St');
      final copy = addr.copyWith(label: 'Work', isDefault: true);
      expect(copy.label, 'Work');
      expect(copy.isDefault, true);
      expect(copy.id, 'a1');
    });
  });
}
