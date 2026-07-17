import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/products_repository_impl.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/i_products_repository.dart';

final productsRepositoryProvider = Provider<IProductsRepository>((ref) {
  return ProductsRepositoryImpl();
});

final featuredProductsProvider = FutureProvider<List<ProductEntity>>((ref) {
  // Keep alive so navigating home doesn't re-fetch from Firestore
  ref.keepAlive();
  return ref.read(productsRepositoryProvider).getFeaturedProducts();
});

final newProductsProvider = FutureProvider<List<ProductEntity>>((ref) {
  ref.keepAlive();
  return ref.read(productsRepositoryProvider).getNewProducts();
});

final bestSellerProductsProvider = FutureProvider<List<ProductEntity>>((ref) {
  ref.keepAlive();
  return ref.read(productsRepositoryProvider).getBestSellerProducts();
});

final productsByCategoryProvider = FutureProvider.family<List<ProductEntity>, String>((ref, categoryId) {
  ref.keepAlive();
  return ref.read(productsRepositoryProvider).getProductsByCategory(categoryId);
});

final productDetailProvider = FutureProvider.family<ProductEntity, String>((ref, productId) {
  return ref.read(productsRepositoryProvider).getProductById(productId);
});

final firebaseSearchProvider = FutureProvider.family<List<ProductEntity>, String>((ref, query) async {
  if (query.trim().isEmpty) return [];
  
  // Proper Debounce: Wait 500ms, if the user typed another letter, this provider is disposed.
  bool didDispose = false;
  ref.onDispose(() => didDispose = true);
  
  await Future.delayed(const Duration(milliseconds: 500));
  
  if (didDispose) {
    return []; // Request was cancelled because user typed more letters
  }

  return ref.read(productsRepositoryProvider).searchProducts(query, limit: 20);
});
