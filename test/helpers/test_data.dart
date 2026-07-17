import 'package:elct/features/products/domain/entities/product_entity.dart';
import 'package:elct/features/cart/domain/entities/cart_item_entity.dart';
import 'package:elct/features/wishlist/domain/entities/wishlist_item_entity.dart';
import 'package:elct/features/auth/domain/entities/user_entity.dart';
import 'package:elct/features/home/domain/entities/banner_entity.dart';
import 'package:elct/features/home/domain/entities/category_entity.dart';
import 'package:elct/features/home/domain/entities/home_data_entity.dart';
import 'package:elct/features/reviews/domain/entities/review_entity.dart';
import 'package:elct/features/checkout/domain/entities/order_entity.dart';
import 'package:elct/features/checkout/domain/entities/promo_code_entity.dart';

final testProduct = ProductEntity(
  id: 'prod-1',
  nameAr: 'منتج تجريبي',
  nameEn: 'Test Product',
  descriptionAr: 'وصف تجريبي',
  descriptionEn: 'Test description',
  categoryId: 'cat-1',
  price: 100.0,
  originalPrice: 150.0,
  discountPercent: 33,
  images: ['https://example.com/img.jpg'],
  rating: 4.5,
  reviewCount: 10,
  stockQuantity: 50,
  isExclusive: true,
  isBestSeller: true,
  isNew: true,
  specs: {'color': 'red'},
  tags: ['electronics'],
);

final testProduct2 = ProductEntity(
  id: 'prod-2',
  nameAr: 'منتج تجريبي 2',
  nameEn: 'Test Product 2',
  descriptionAr: 'وصف تجريبي 2',
  descriptionEn: 'Test description 2',
  categoryId: 'cat-1',
  price: 200.0,
  images: [],
  stockQuantity: 0,
);

final testCartItem = CartItemEntity(
  id: 'cart-1',
  productId: 'prod-1',
  nameAr: 'منتج تجريبي',
  nameEn: 'Test Product',
  image: 'https://example.com/img.jpg',
  price: 100.0,
  originalPrice: 150.0,
  discountPercent: 33,
  quantity: 2,
  stockQuantity: 50,
  isAvailable: true,
);

final testWishlistItem = WishlistItemEntity(
  id: 'wish-1',
  productId: 'prod-1',
  nameAr: 'منتج تجريبي',
  nameEn: 'Test Product',
  image: 'https://example.com/img.jpg',
  price: 100.0,
  originalPrice: 150.0,
  discountPercent: 33,
  rating: 4.5,
  reviewCount: 10,
);

final testUser = UserEntity(
  uid: 'user-1',
  email: 'test@test.com',
  displayName: 'Test User',
  firstName: 'Test',
  lastName: 'User',
  phoneNumber: '+96550000000',
  isAdmin: false,
  photoUrl: 'https://example.com/avatar.jpg',
  phoneVerified: true,
);

final testAdmin = UserEntity(
  uid: 'admin-1',
  email: 'admin@test.com',
  displayName: 'Admin User',
  firstName: 'Admin',
  lastName: 'User',
  isAdmin: true,
);

final testBanner = BannerEntity(
  id: 'banner-1',
  imageUrl: 'https://example.com/banner.jpg',
  titleAr: 'عرض',
  titleEn: 'Offer',
  subtitleAr: 'خصم كبير',
  subtitleEn: 'Big discount',
  targetType: 'category',
  targetId: 'cat-1',
  order: 1,
  zone: 'header',
);

final testCategory = CategoryEntity(
  id: 'cat-1',
  nameAr: 'إلكترونيات',
  nameEn: 'Electronics',
  imageUrl: 'https://example.com/cat.jpg',
  order: 1,
);

final testHomeData = HomeDataEntity(
  banners: [testBanner],
  middleBanners: [],
  bottomBanner: null,
  categories: [testCategory],
  featuredProducts: [testProduct],
  newProducts: [testProduct2],
  bestSellers: [testProduct],
);

final testReview = ReviewEntity(
  id: 'rev-1',
  productId: 'prod-1',
  userId: 'user-1',
  userName: 'Test User',
  rating: 4.5,
  comment: 'Great product!',
  date: DateTime(2025, 1, 1),
);

final testOrderItem = OrderItemEntity(
  productId: 'prod-1',
  nameAr: 'منتج تجريبي',
  nameEn: 'Test Product',
  image: 'https://example.com/img.jpg',
  price: 100.0,
  quantity: 2,
);

final testShippingAddress = ShippingAddressEntity(
  name: 'Test User',
  phone: '+96550000000',
  address: 'Test Street',
  city: 'Kuwait City',
  label: 'Home',
);

final testOrder = OrderEntity(
  id: 'order-1',
  items: [testOrderItem],
  subtotal: 200.0,
  shipping: 5.0,
  total: 205.0,
  status: OrderStatus.pending,
  shippingAddress: testShippingAddress,
  paymentMethod: 'cod',
  createdAt: DateTime(2025, 1, 1),
);

final testPromoCode = PromoCodeEntity(
  code: 'SAVE20',
  discountPercent: 20.0,
);
