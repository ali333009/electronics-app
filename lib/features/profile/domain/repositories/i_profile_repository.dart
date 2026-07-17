import '../../data/models/address_model.dart';

abstract class IProfileRepository {
  Future<Map<String, dynamic>?> getUserData(String uid);
  Future<void> updateProfile(String uid, {String? displayName, String? firstName, String? lastName, String? phoneNumber});
  Stream<List<AddressModel>> watchAddresses(String uid);
  Future<void> addAddress(String uid, AddressModel address);
  Future<void> updateAddress(String uid, AddressModel address);
  Future<void> deleteAddress(String uid, String addressId);
  Future<void> setDefaultAddress(String uid, String addressId);
}
