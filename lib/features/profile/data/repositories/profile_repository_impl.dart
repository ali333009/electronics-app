import '../../domain/repositories/i_profile_repository.dart';
import '../datasources/profile_datasource.dart';
import '../models/address_model.dart';

class ProfileRepositoryImpl implements IProfileRepository {
  final ProfileDatasource _datasource;

  ProfileRepositoryImpl({ProfileDatasource? datasource})
    : _datasource = datasource ?? ProfileDatasource();

  @override
  Future<Map<String, dynamic>?> getUserData(String uid) =>
      _datasource.getUserData(uid);

  @override
  Future<void> updateProfile(String uid, {String? displayName, String? firstName, String? lastName, String? phoneNumber}) =>
      _datasource.updateProfile(uid, displayName: displayName, firstName: firstName, lastName: lastName, phoneNumber: phoneNumber);

  @override
  Stream<List<AddressModel>> watchAddresses(String uid) =>
      _datasource.watchAddresses(uid);

  @override
  Future<void> addAddress(String uid, AddressModel address) =>
      _datasource.addAddress(uid, address);

  @override
  Future<void> updateAddress(String uid, AddressModel address) =>
      _datasource.updateAddress(uid, address);

  @override
  Future<void> deleteAddress(String uid, String addressId) =>
      _datasource.deleteAddress(uid, addressId);

  @override
  Future<void> setDefaultAddress(String uid, String addressId) =>
      _datasource.setDefaultAddress(uid, addressId);
}
