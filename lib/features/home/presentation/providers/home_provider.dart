import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../products/presentation/providers/products_provider.dart';
import '../../../products/domain/repositories/i_products_repository.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../domain/entities/home_data_entity.dart';

final iProductsRepositoryProvider = Provider<IProductsRepository>((ref) {
  return ref.read(productsRepositoryProvider);
});

final homeRepositoryProvider = Provider<HomeRepositoryImpl>((ref) {
  return HomeRepositoryImpl(
    productsRepo: ref.read(iProductsRepositoryProvider),
  );
});

final homeDataProvider = FutureProvider.autoDispose<HomeDataEntity>((ref) {
  final link = ref.keepAlive();
  final timer = Timer(const Duration(minutes: 5), () {
    link.close();
  });
  ref.onDispose(() => timer.cancel());
  return ref.read(homeRepositoryProvider).getHomeData();
});
