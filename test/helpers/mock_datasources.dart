import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:elct/features/auth/data/datasources/auth_datasource.dart';
import 'package:elct/features/auth/domain/entities/user_entity.dart';
import 'package:elct/features/home/data/datasources/home_datasource.dart';
import 'package:elct/features/home/data/models/banner_model.dart';
import 'package:elct/features/home/data/models/category_model.dart';
import 'package:elct/features/products/data/datasources/products_datasource.dart';
import 'package:elct/features/products/data/models/product_model.dart';
import 'package:elct/features/cart/data/datasources/cart_datasource.dart';
import 'package:elct/features/cart/data/models/cart_item_model.dart';
import 'package:elct/features/wishlist/data/datasources/wishlist_datasource.dart';
import 'package:elct/features/wishlist/data/models/wishlist_item_model.dart';
import 'package:elct/features/reviews/data/datasources/reviews_datasource.dart';
import 'package:elct/features/reviews/data/models/review_model.dart';
import 'package:elct/features/orders/data/datasources/orders_datasource.dart';
import 'package:elct/features/checkout/data/datasources/checkout_datasource.dart';
import 'package:elct/features/checkout/data/models/order_model.dart';
import 'package:elct/features/checkout/data/models/promo_code_model.dart';
import 'package:elct/features/profile/data/datasources/profile_datasource.dart';
import 'package:elct/features/profile/data/models/address_model.dart';
import 'package:elct/features/products/domain/repositories/i_products_repository.dart';
import 'package:elct/features/products/domain/entities/product_entity.dart';

class MockAuthDatasource implements AuthDatasource {
  UserEntity? signInResult;
  UserEntity? createUserResult;
  bool emailVerified = false;
  String? currentEmail;
  bool throwOnSignIn = false;
  bool throwOnCreate = false;

  @override
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (throwOnSignIn) throw StateError('INVALID_CREDENTIALS');
    return signInResult ?? testUserEntity;
  }

  @override
  Future<UserEntity> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (throwOnCreate) throw StateError('EMAIL_ALREADY_IN_USE');
    return createUserResult ?? testUserEntity;
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {}
  @override
  Future<void> sendVerificationEmail() async {}
  @override
  Future<void> signOut() async {}
  @override
  Future<UserEntity> signInWithGoogle() async => signInResult ?? testUserEntity;
  
  @override
  Future<UserEntity> signInWithApple() async => signInResult ?? testUserEntity;
  
  @override
  void sendOtp({
    required String phoneNumber,
    required void Function(String, int?) onCodeSent,
    required void Function(String) onError,
    void Function(PhoneAuthCredential)? onVerificationCompleted,
  }) {}
  @override
  Future<void> linkPhoneCredential(dynamic credential, {String? phoneNumber}) async {}
  @override
  Future<void> signInWithPhoneCredential(dynamic credential) async {}
  @override
  Future<void> saveUserProfile({
    required String uid,
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String displayName,
    String? photoUrl,
    bool? phoneVerified,
  }) async {}
  @override
  Future<void> deleteCurrentUser({String? password}) async {}
  @override
  Future<void> updateDisplayName(String name) async {}
  @override
  Future<void> verifyBeforeUpdateEmail(String email) async {}
  @override
  Future<void> updatePassword(String password) async {}

  @override
  Future<bool> checkEmailExists(String email) async => false;

  @override
  Future<void> resetPasswordViaPhoneOtp({
    required String verificationId,
    required String smsCode,
    required String newPassword,
  }) async {}
  @override
  String? get currentUserEmail => currentEmail;
  @override
  Stream<UserEntity?> authStateChanges() => Stream.value(null);
  @override
  String? get currentUserUid => null;
  @override
  bool get hasGoogleProvider => false;
  @override
  Future<void> reauthenticateWithCredential(dynamic credential) async {}
  @override
  Future<void> reauthenticateWithGoogle() async {}
  @override
  Future<void> linkPhoneWithOtp({required String verificationId, required String smsCode, String? phoneNumber}) async {}
  @override
  Future<UserEntity> signInWithOtp({required String verificationId, required String smsCode}) async =>
      signInResult ?? testUserEntity;
}

class MockProductsDatasource implements ProductsDatasource {
  List<ProductModel> products = [];
  bool throwOnError = false;

  @override
  Future<List<ProductModel>> getProducts({
    int limit = 20,
    String? startAfterId,
  }) async {
    if (throwOnError) throw Exception('error');
    return products.take(limit).toList();
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(
    String categoryId, {
    String? startAfterId,
    int limit = 11,
  }) async {
    if (throwOnError) throw Exception('error');
    return products
        .where((p) => p.categoryId == categoryId)
        .take(limit)
        .toList();
  }

  @override
  Future<List<ProductModel>> getFeaturedProducts() async {
    if (throwOnError) return [];
    return products.where((p) => p.isFeatured == true).toList();
  }

  @override
  Future<List<ProductModel>> getNewProducts() async {
    if (throwOnError) return [];
    return products.where((p) => p.isNew == true).toList();
  }

  @override
  Future<List<ProductModel>> getBestSellerProducts() async {
    if (throwOnError) return [];
    return products.where((p) => p.isBestSeller == true).toList();
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    if (throwOnError) throw Exception('error');
    return products.firstWhere((p) => p.id == id);
  }

  @override
  Future<List<ProductModel>> searchProducts(
    String query, {
    String? startAfterId,
    int limit = 11,
  }) async {
    if (throwOnError) throw Exception('error');
    return products.take(limit).toList();
  }

  @override
  Future<List<ProductModel>> getProductsByIds(List<String> ids) async {
    if (throwOnError) throw Exception('error');
    return products.where((p) => ids.contains(p.id)).toList();
  }
}

class MockHomeDatasource implements HomeDatasource {
  List<BannerModel> banners = [];
  List<BannerModel> middleBanners = [];
  BannerModel? bottomBanner;
  List<CategoryModel> categories = [];
  bool throwOnError = false;

  @override
  Future<List<BannerModel>> getBanners({String zone = 'header'}) async {
    if (throwOnError) throw Exception('error');
    return zone == 'header' ? banners : middleBanners;
  }

  @override
  Future<BannerModel?> getBottomBanner() async {
    if (throwOnError) throw Exception('error');
    return bottomBanner;
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    if (throwOnError) throw Exception('error');
    return categories;
  }

  @override
  Future<BannerModel?> getBannerById(String id) async => null;
}

class MockCartDatasource implements CartDatasource {
  List<CartItemModel> items = [];
  CartItemModel? existingItem;
  bool throwOnError = false;

  @override
  Stream<List<CartItemModel>> watchCart(String userId) {
    return Stream.value(items);
  }

  @override
  Future<void> addItem(CartItemModel item) async {
    if (throwOnError) throw Exception('error');
    items.add(item);
  }

  @override
  Future<void> updateQuantity(
    String userId,
    String itemId,
    int quantity,
  ) async {
    if (throwOnError) throw Exception('error');
    final idx = items.indexWhere((i) => i.id == itemId);
    if (idx >= 0) {
      items[idx] = CartItemModel(
        id: items[idx].id,
        userId: items[idx].userId,
        productId: items[idx].productId,
        nameAr: items[idx].nameAr,
        nameEn: items[idx].nameEn,
        image: items[idx].image,
        price: items[idx].price,
        originalPrice: items[idx].originalPrice,
        discountPercent: items[idx].discountPercent,
        quantity: quantity,
        stockQuantity: items[idx].stockQuantity,
        isAvailable: items[idx].isAvailable,
      );
    }
  }

  @override
  Future<void> removeItem(String userId, String itemId) async {
    if (throwOnError) throw Exception('error');
    items.removeWhere((i) => i.id == itemId);
  }

  @override
  Future<void> clearCart(String userId) async {
    items.clear();
  }

  @override
  Future<void> mergeGuestCart(
    String userId,
    List<CartItemModel> guestItems,
  ) async {
    items.addAll(guestItems);
  }

  @override
  Future<void> updateOptions(String userId, String itemId, Map<String, String> selectedOptions) async {
    if (throwOnError) throw Exception('error');
    final idx = items.indexWhere((i) => i.id == itemId);
    if (idx >= 0) {
      items[idx] = CartItemModel(
        id: items[idx].id,
        userId: items[idx].userId,
        productId: items[idx].productId,
        nameAr: items[idx].nameAr,
        nameEn: items[idx].nameEn,
        image: items[idx].image,
        price: items[idx].price,
        originalPrice: items[idx].originalPrice,
        discountPercent: items[idx].discountPercent,
        quantity: items[idx].quantity,
        stockQuantity: items[idx].stockQuantity,
        isAvailable: items[idx].isAvailable,
        selectedOptions: selectedOptions,
      );
    }
  }

  @override
  Future<CartItemModel?> getItemByProductId(
    String userId,
    String productId,
  ) async {
    return existingItem ??
        items.cast<CartItemModel?>().firstWhere(
          (i) => i?.productId == productId,
          orElse: () => null,
        );
  }
}

class MockWishlistDatasource implements WishlistDatasource {
  List<WishlistItemModel> items = [];
  bool throwOnError = false;

  @override
  Stream<List<WishlistItemModel>> watchWishlist(String userId) =>
      Stream.value(items);

  @override
  Future<void> addItem(WishlistItemModel item) async {
    if (throwOnError) throw Exception('error');
    items.add(item);
  }

  @override
  Future<void> removeItem(String userId, String productId) async {
    if (throwOnError) throw Exception('error');
    items.removeWhere((i) => i.productId == productId);
  }

  @override
  Future<bool> isInWishlist(String userId, String productId) async {
    if (throwOnError) throw Exception('error');
    return items.any((i) => i.productId == productId);
  }
}

class MockOrdersDatasource implements OrdersDatasource {
  List<OrderModel> orders = [];
  bool throwOnError = false;

  @override
  Stream<List<OrderModel>> watchOrders(String userId) => Stream.value(orders);

  @override
  Future<List<OrderModel>> getUserOrders(String userId) async {
    if (throwOnError) throw Exception('error');
    return orders;
  }

  @override
  Future<OrderModel> getOrder(String orderId, String userId) async {
    if (throwOnError) throw Exception('error');
    return orders.firstWhere((o) => o.id == orderId);
  }
}

class MockCheckoutDatasource implements CheckoutDatasource {
  String createdOrderId = 'order-new';
  PromoCodeModel? promoCode;
  OrderModel? savedOrder;
  bool throwOnError = false;

  @override
  Future<String> createOrder(OrderModel order, {String? promoCode}) async {
    if (throwOnError) throw Exception('error');
    savedOrder = OrderModel(
      id: createdOrderId,
      userId: order.userId,
      items: order.items,
      subtotal: order.subtotal,
      shipping: order.shipping,
      total: order.total,
      status: order.status,
      shippingAddress: order.shippingAddress,
      paymentMethod: order.paymentMethod,
      discount: order.discount,
      promoCode: order.promoCode,
      createdAt: order.createdAt,
    );
    return createdOrderId;
  }

  @override
  Future<PromoCodeModel?> validatePromoCode(String code) async => promoCode;

  @override
  Future<OrderModel> getOrder(String orderId, String userId) async {
    return savedOrder ??
        OrderModel(
          id: orderId,
          userId: '',
          items: [],
          subtotal: 0,
          total: 0,
          shippingAddress: {},
        );
  }
}

class MockReviewsDatasource implements ReviewsDatasource {
  List<ReviewModel> reviews = [];
  bool throwOnError = false;

  @override
  Future<List<ReviewModel>> getReviews(String productId) async {
    if (throwOnError) throw Exception('error');
    return reviews;
  }

  @override
  Future<void> addReview(ReviewModel review) async {
    if (throwOnError) throw Exception('error');
    reviews.add(review);
  }
}

class MockProfileDatasource implements ProfileDatasource {
  Map<String, dynamic>? userData;
  List<AddressModel> addresses = [];
  bool throwOnError = false;

  @override
  Future<Map<String, dynamic>?> getUserData(String uid) async => userData;

  @override
  Future<void> updateProfile(
    String uid, {
    String? displayName,
    String? firstName,
    String? lastName,
    String? phoneNumber,
  }) async {}

  @override
  Stream<List<AddressModel>> watchAddresses(String uid) =>
      Stream.value(addresses);

  @override
  Future<void> addAddress(String uid, AddressModel address) async {
    addresses.add(address);
  }

  @override
  Future<void> updateAddress(String uid, AddressModel address) async {}

  @override
  Future<void> deleteAddress(String uid, String addressId) async {}

  @override
  Future<void> setDefaultAddress(String uid, String addressId) async {}
}

class MockProductsRepository implements IProductsRepository {
  List<ProductEntity> products;
  MockProductsRepository(this.products);

  @override
  Future<List<ProductEntity>> getProducts({
    int limit = 20,
    String? startAfterId,
  }) async => products.take(limit).toList();

  @override
  Future<List<ProductEntity>> getProductsByCategory(
    String categoryId, {
    String? startAfterId,
    int limit = 11,
  }) async => products.take(limit).toList();

  @override
  Future<List<ProductEntity>> getFeaturedProducts() async => products;

  @override
  Future<List<ProductEntity>> getNewProducts() async => products;

  @override
  Future<List<ProductEntity>> getBestSellerProducts() async => products;

  @override
  Future<ProductEntity> getProductById(String id) async => products.first;

  @override
  Future<List<ProductEntity>> searchProducts(
    String query, {
    String? startAfterId,
    int limit = 11,
  }) async => products.take(limit).toList();

  @override
  Future<List<ProductEntity>> getProductsByIds(List<String> ids) async {
    return products.where((p) => ids.contains(p.id)).toList();
  }
}

final testUserEntity = UserEntity(uid: 'user-1', email: 'test@test.com');
