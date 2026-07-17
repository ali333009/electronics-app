class AddressEntity {
  final String id;
  final String label;
  final String city;
  final String street;
  final bool isDefault;
  final double? latitude;
  final double? longitude;

  const AddressEntity({
    required this.id,
    required this.label,
    required this.city,
    required this.street,
    this.isDefault = false,
    this.latitude,
    this.longitude,
  });
}
