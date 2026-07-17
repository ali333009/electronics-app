import '../../domain/entities/address_entity.dart';

class AddressModel implements AddressEntity {
  @override final String id;
  @override final String label;
  @override final String city;
  @override final String street;
  @override final bool isDefault;
  final String? countryCode;
  @override final double? latitude;
  @override final double? longitude;

  const AddressModel({
    required this.id,
    required this.label,
    required this.city,
    required this.street,
    this.isDefault = false,
    this.countryCode,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toFirestore() => {
    'label': label,
    'city': city,
    'street': street,
    'isDefault': isDefault,
    'countryCode': countryCode,
    'latitude': latitude,
    'longitude': longitude,
  };

  factory AddressModel.fromFirestore(Map<String, dynamic> data, {required String id}) {
    String? countryCode;
    double? lat;
    double? lng;

    if (data['countryCode'] != null) {
      countryCode = data['countryCode'] as String;
      lat = (data['latitude'] as num?)?.toDouble();
      lng = (data['longitude'] as num?)?.toDouble();
    } else {
      final labelRaw = (data['label'] ?? '');
      if (labelRaw.contains(',')) {
        final parts = labelRaw.split(',');
        if (parts.length >= 3) {
          countryCode = parts[0];
          lat = double.tryParse(parts[1]);
          lng = double.tryParse(parts[2]);
        } else if (parts.length == 2) {
          lat = double.tryParse(parts[0]);
          lng = double.tryParse(parts[1]);
        }
      }
    }

    return AddressModel(
      id: id,
      label: (data['label'] ?? ''),
      city: (data['city'] ?? ''),
      street: (data['street'] ?? ''),
      isDefault: data['isDefault'] == true || data['isDefault'] == 'true',
      countryCode: countryCode,
      latitude: lat,
      longitude: lng,
    );
  }

  AddressModel copyWith({
    String? id,
    String? label,
    String? city,
    String? street,
    bool? isDefault,
    String? countryCode,
    double? latitude,
    double? longitude,
  }) {
    return AddressModel(
      id: id ?? this.id,
      label: label ?? this.label,
      city: city ?? this.city,
      street: street ?? this.street,
      isDefault: isDefault ?? this.isDefault,
      countryCode: countryCode ?? this.countryCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
