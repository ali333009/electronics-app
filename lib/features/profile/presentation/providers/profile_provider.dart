import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../data/models/address_model.dart';
import '../../domain/repositories/i_profile_repository.dart';

final _profileRepositoryProvider = Provider<IProfileRepository>((ref) {
  return ProfileRepositoryImpl();
});

final userProfileProvider = FutureProvider.autoDispose.family<Map<String, dynamic>?, String>((ref, uid) async {
  return ref.read(_profileRepositoryProvider).getUserData(uid);
});

final addressesProvider = StreamProvider.autoDispose.family<List<AddressModel>, String>((ref, uid) {
  return ref.read(_profileRepositoryProvider).watchAddresses(uid);
});

final addressRepositoryProvider = Provider<IProfileRepository>((ref) {
  return ref.read(_profileRepositoryProvider);
});
