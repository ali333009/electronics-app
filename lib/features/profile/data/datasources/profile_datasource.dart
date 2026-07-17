import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/address_model.dart';

class ProfileDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data();
  }

  Future<void> updateProfile(String uid, {String? displayName, String? firstName, String? lastName, String? phoneNumber}) async {
    final data = <String, dynamic>{};
    if (firstName != null && firstName.isNotEmpty) data['firstName'] = firstName;
    if (lastName != null && lastName.isNotEmpty) data['lastName'] = lastName;
    if (displayName != null && displayName.isNotEmpty) data['displayName'] = displayName;
    if (phoneNumber != null && phoneNumber.isNotEmpty) data['phoneNumber'] = phoneNumber;
    if (data.isEmpty) return;
    await _firestore.collection('users').doc(uid).set(data, SetOptions(merge: true));
  }

  CollectionReference _addressesRef(String uid) =>
      _firestore.collection('users').doc(uid).collection('addresses');

  Stream<List<AddressModel>> watchAddresses(String uid) {
    return _addressesRef(uid)
        .orderBy('isDefault', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AddressModel.fromFirestore(doc.data() as Map<String, dynamic>, id: doc.id))
            .toList());
  }

  Future<void> addAddress(String uid, AddressModel address) async {
    final ref = _addressesRef(uid).doc();
    final data = address.toFirestore();
    data['id'] = ref.id;
    if (address.isDefault) {
      await _resetDefaults(uid);
    }
    await ref.set(data);
  }

  Future<void> updateAddress(String uid, AddressModel address) async {
    if (address.isDefault) {
      await _resetDefaults(uid);
    }
    await _addressesRef(uid).doc(address.id).update(address.toFirestore());
  }

  Future<void> deleteAddress(String uid, String addressId) async {
    await _addressesRef(uid).doc(addressId).delete();
  }

  Future<void> setDefaultAddress(String uid, String addressId) async {
    await _resetDefaults(uid);
    await _addressesRef(uid).doc(addressId).update({'isDefault': true});
  }

  Future<void> _resetDefaults(String uid) async {
    final snapshot = await _addressesRef(uid).where('isDefault', isEqualTo: true).get();
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'isDefault': false});
    }
    await batch.commit();
  }
}
