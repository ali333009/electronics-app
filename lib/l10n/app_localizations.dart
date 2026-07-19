import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Electronic'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Luxury Shopping with Style'**
  String get appTagline;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @cart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get orders;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @offers.
  ///
  /// In en, this message translates to:
  /// **'Offers'**
  String get offers;

  /// No description provided for @fiveStarRating.
  ///
  /// In en, this message translates to:
  /// **'Top Rated'**
  String get fiveStarRating;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning 👋'**
  String get goodMorning;

  /// No description provided for @guest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guest;

  /// No description provided for @myAccount.
  ///
  /// In en, this message translates to:
  /// **'My Account'**
  String get myAccount;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search electronics, fashion, perfumes...'**
  String get searchHint;

  /// No description provided for @browseCategories.
  ///
  /// In en, this message translates to:
  /// **'Browse categories'**
  String get browseCategories;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @shopNow.
  ///
  /// In en, this message translates to:
  /// **'Shop Now'**
  String get shopNow;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete All'**
  String get deleteAll;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @allProducts.
  ///
  /// In en, this message translates to:
  /// **'All Products'**
  String get allProducts;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @noProducts.
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get noProducts;

  /// No description provided for @loadingMore.
  ///
  /// In en, this message translates to:
  /// **'Loading more...'**
  String get loadingMore;

  /// No description provided for @allProductsShown.
  ///
  /// In en, this message translates to:
  /// **'All products shown'**
  String get allProductsShown;

  /// No description provided for @errorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorPrefix(String error);

  /// No description provided for @priceFormat.
  ///
  /// In en, this message translates to:
  /// **'{price} KWD'**
  String priceFormat(String price);

  /// No description provided for @popularProducts.
  ///
  /// In en, this message translates to:
  /// **'Popular Products'**
  String get popularProducts;

  /// No description provided for @featuredProducts.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get featuredProducts;

  /// No description provided for @latestProducts.
  ///
  /// In en, this message translates to:
  /// **'New Arrivals'**
  String get latestProducts;

  /// No description provided for @bestSeller.
  ///
  /// In en, this message translates to:
  /// **'Best Seller'**
  String get bestSeller;

  /// No description provided for @newLabel.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newLabel;

  /// No description provided for @exclusive.
  ///
  /// In en, this message translates to:
  /// **'Exclusive'**
  String get exclusive;

  /// No description provided for @discountPercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}% OFF'**
  String discountPercent(int percent);

  /// No description provided for @searchInitialTitle.
  ///
  /// In en, this message translates to:
  /// **'Search for a product'**
  String get searchInitialTitle;

  /// No description provided for @searchInitialSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Type a keyword to search'**
  String get searchInitialSubtitle;

  /// No description provided for @searchEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get searchEmptyTitle;

  /// No description provided for @searchEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try a different keyword'**
  String get searchEmptySubtitle;

  /// No description provided for @productCode.
  ///
  /// In en, this message translates to:
  /// **'Code: {code}'**
  String productCode(String code);

  /// No description provided for @inStock.
  ///
  /// In en, this message translates to:
  /// **'In Stock'**
  String get inStock;

  /// No description provided for @lastPieceAlert.
  ///
  /// In en, this message translates to:
  /// **'Last piece! 🔥'**
  String get lastPieceAlert;

  /// No description provided for @lowStockAlert.
  ///
  /// In en, this message translates to:
  /// **'Only {count} left'**
  String lowStockAlert(int count);

  /// No description provided for @stockAvailable.
  ///
  /// In en, this message translates to:
  /// **'In stock: {count}'**
  String stockAvailable(int count);

  /// No description provided for @reviewCount.
  ///
  /// In en, this message translates to:
  /// **'({count} reviews)'**
  String reviewCount(int count);

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @specifications.
  ///
  /// In en, this message translates to:
  /// **'Specifications'**
  String get specifications;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @addReview.
  ///
  /// In en, this message translates to:
  /// **'Add Your Review'**
  String get addReview;

  /// No description provided for @writeReviewHint.
  ///
  /// In en, this message translates to:
  /// **'Write your review...'**
  String get writeReviewHint;

  /// No description provided for @selectStarRating.
  ///
  /// In en, this message translates to:
  /// **'Select star rating'**
  String get selectStarRating;

  /// No description provided for @reviewSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Review submitted successfully'**
  String get reviewSubmitted;

  /// No description provided for @reviewDefaultComment.
  ///
  /// In en, this message translates to:
  /// **'Great product'**
  String get reviewDefaultComment;

  /// No description provided for @loadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load data'**
  String get loadError;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get addToCart;

  /// No description provided for @addedToCart.
  ///
  /// In en, this message translates to:
  /// **'Added {quantity} item(s) to cart'**
  String addedToCart(int quantity);

  /// No description provided for @addToWishlist.
  ///
  /// In en, this message translates to:
  /// **'Added to favorites'**
  String get addToWishlist;

  /// No description provided for @removeFromWishlist.
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites'**
  String get removeFromWishlist;

  /// No description provided for @addedToCartToast.
  ///
  /// In en, this message translates to:
  /// **'Added to cart'**
  String get addedToCartToast;

  /// No description provided for @similarProducts.
  ///
  /// In en, this message translates to:
  /// **'Similar Products'**
  String get similarProducts;

  /// No description provided for @cartTitle.
  ///
  /// In en, this message translates to:
  /// **'Shopping Cart'**
  String get cartTitle;

  /// No description provided for @cartEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cartEmpty;

  /// No description provided for @cartEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse products and add what you like'**
  String get cartEmptySubtitle;

  /// No description provided for @cartNotLoaded.
  ///
  /// In en, this message translates to:
  /// **'Cart not loaded yet.'**
  String get cartNotLoaded;

  /// No description provided for @cartError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String cartError(String error);

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @shipping.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get shipping;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @grandTotal.
  ///
  /// In en, this message translates to:
  /// **'Grand Total'**
  String get grandTotal;

  /// No description provided for @orderPlaced.
  ///
  /// In en, this message translates to:
  /// **'Order Placed'**
  String get orderPlaced;

  /// No description provided for @confirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get confirmed;

  /// No description provided for @delivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get delivered;

  /// No description provided for @orderDetailProducts.
  ///
  /// In en, this message translates to:
  /// **'Ordered Products'**
  String get orderDetailProducts;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Qty: {quantity}'**
  String quantity(int quantity);

  /// No description provided for @itemDeleted.
  ///
  /// In en, this message translates to:
  /// **'Item removed from cart'**
  String get itemDeleted;

  /// No description provided for @cartCleared.
  ///
  /// In en, this message translates to:
  /// **'Cart cleared'**
  String get cartCleared;

  /// No description provided for @clearCartTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear Cart'**
  String get clearCartTitle;

  /// No description provided for @clearCartConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove all items?'**
  String get clearCartConfirm;

  /// No description provided for @checkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkoutTitle;

  /// No description provided for @shippingAddress.
  ///
  /// In en, this message translates to:
  /// **'Shipping Address'**
  String get shippingAddress;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @contactDetails.
  ///
  /// In en, this message translates to:
  /// **'Contact Details'**
  String get contactDetails;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'Your phone number'**
  String get phoneHint;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @orderSummary.
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get orderSummary;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @placingOrder.
  ///
  /// In en, this message translates to:
  /// **'Placing order...'**
  String get placingOrder;

  /// No description provided for @confirmOrder.
  ///
  /// In en, this message translates to:
  /// **'Confirm & Place Order'**
  String get confirmOrder;

  /// No description provided for @confirmOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Order'**
  String get confirmOrderTitle;

  /// No description provided for @confirmOrderMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to confirm this order?'**
  String get confirmOrderMessage;

  /// No description provided for @orderSuccess.
  ///
  /// In en, this message translates to:
  /// **'Order placed successfully!'**
  String get orderSuccess;

  /// No description provided for @orderNumber.
  ///
  /// In en, this message translates to:
  /// **'Order #{id}'**
  String orderNumber(String id);

  /// No description provided for @trackOrder.
  ///
  /// In en, this message translates to:
  /// **'Track Order'**
  String get trackOrder;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @loginRequired.
  ///
  /// In en, this message translates to:
  /// **'You must login first'**
  String get loginRequired;

  /// No description provided for @loginRequiredSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log in to access this feature'**
  String get loginRequiredSubtitle;

  /// No description provided for @removeOutOfStockItems.
  ///
  /// In en, this message translates to:
  /// **'Some items are out of stock, please remove them first'**
  String get removeOutOfStockItems;

  /// No description provided for @searchInSection.
  ///
  /// In en, this message translates to:
  /// **'Search in this section...'**
  String get searchInSection;

  /// No description provided for @browseCollection.
  ///
  /// In en, this message translates to:
  /// **'Browse {label}'**
  String browseCollection(Object label);

  /// No description provided for @browseAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Browse as Guest'**
  String get browseAsGuest;

  /// No description provided for @orderFailed.
  ///
  /// In en, this message translates to:
  /// **'Order failed: {error}'**
  String orderFailed(String error);

  /// No description provided for @myOrders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get myOrders;

  /// No description provided for @ordersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get ordersEmpty;

  /// No description provided for @ordersEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start shopping for your first order'**
  String get ordersEmptySubtitle;

  /// No description provided for @continueShopping.
  ///
  /// In en, this message translates to:
  /// **'Continue Shopping'**
  String get continueShopping;

  /// No description provided for @itemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String itemsCount(int count);

  /// No description provided for @orderDetail.
  ///
  /// In en, this message translates to:
  /// **'Order Detail'**
  String get orderDetail;

  /// No description provided for @orderNotFound.
  ///
  /// In en, this message translates to:
  /// **'Order not found'**
  String get orderNotFound;

  /// No description provided for @orderStatus.
  ///
  /// In en, this message translates to:
  /// **'Order Status'**
  String get orderStatus;

  /// No description provided for @wishlistTitle.
  ///
  /// In en, this message translates to:
  /// **'My Favorites'**
  String get wishlistTitle;

  /// No description provided for @wishlistEmpty.
  ///
  /// In en, this message translates to:
  /// **'Favorites is empty'**
  String get wishlistEmpty;

  /// No description provided for @wishlistEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add your favorite products here'**
  String get wishlistEmptySubtitle;

  /// No description provided for @addToCartFromWishlist.
  ///
  /// In en, this message translates to:
  /// **'Added to cart'**
  String get addToCartFromWishlist;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'My Account'**
  String get profileTitle;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @myAddresses.
  ///
  /// In en, this message translates to:
  /// **'My Addresses'**
  String get myAddresses;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get about;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get terms;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirm;

  /// No description provided for @logoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutTitle;

  /// No description provided for @accountSection.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountSection;

  /// No description provided for @browseSection.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get browseSection;

  /// No description provided for @supportSection.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get supportSection;

  /// No description provided for @statsOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get statsOrders;

  /// No description provided for @statsWishlist.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get statsWishlist;

  /// No description provided for @statsCart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get statsCart;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back 👋'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue shopping'**
  String get loginSubtitle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get emailInvalid;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordMinLength;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// No description provided for @googleLogin.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get googleLogin;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @orDivider.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get orDivider;

  /// No description provided for @googleSignInCancelled.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in was cancelled'**
  String get googleSignInCancelled;

  /// No description provided for @phoneVerificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Phone Verification'**
  String get phoneVerificationTitle;

  /// No description provided for @phoneVerificationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification code to {phone}'**
  String phoneVerificationSubtitle(Object phone);

  /// No description provided for @phoneVerificationBackTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Go Back'**
  String get phoneVerificationBackTitle;

  /// No description provided for @phoneVerificationBackConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to go back? Registration will be cancelled.'**
  String get phoneVerificationBackConfirm;

  /// No description provided for @otpLabel.
  ///
  /// In en, this message translates to:
  /// **'Enter Code'**
  String get otpLabel;

  /// No description provided for @otpHint.
  ///
  /// In en, this message translates to:
  /// **'6-digit code'**
  String get otpHint;

  /// No description provided for @verifyPhone.
  ///
  /// In en, this message translates to:
  /// **'Verify & Continue'**
  String get verifyPhone;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get resendCode;

  /// No description provided for @resendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String resendIn(Object seconds);

  /// No description provided for @otpInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter the full 6-digit code'**
  String get otpInvalid;

  /// No description provided for @phoneVerified.
  ///
  /// In en, this message translates to:
  /// **'Phone verified successfully'**
  String get phoneVerified;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get noAccount;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @loginError.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginError;

  /// No description provided for @emailNotRegistered.
  ///
  /// In en, this message translates to:
  /// **'Email not registered'**
  String get emailNotRegistered;

  /// No description provided for @wrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Wrong password'**
  String get wrongPassword;

  /// No description provided for @tooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again later.'**
  String get tooManyAttempts;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password'**
  String get invalidCredentials;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Check your internet connection'**
  String get networkError;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create New Account ✨'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join us and enjoy a premium shopping experience'**
  String get registerSubtitle;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @firstNameRequired.
  ///
  /// In en, this message translates to:
  /// **'First name is required'**
  String get firstNameRequired;

  /// No description provided for @lastNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Last name is required'**
  String get lastNameRequired;

  /// No description provided for @fullNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get fullNameRequired;

  /// No description provided for @fullNameShort.
  ///
  /// In en, this message translates to:
  /// **'Name is too short'**
  String get fullNameShort;

  /// No description provided for @phoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneRequired;

  /// No description provided for @phoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number'**
  String get phoneInvalid;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMismatch;

  /// No description provided for @agreeTerms.
  ///
  /// In en, this message translates to:
  /// **'I agree to the Terms & Conditions'**
  String get agreeTerms;

  /// No description provided for @agreeToTerms.
  ///
  /// In en, this message translates to:
  /// **'I agree to the'**
  String get agreeToTerms;

  /// No description provided for @separatorAnd.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get separatorAnd;

  /// No description provided for @agreeRequired.
  ///
  /// In en, this message translates to:
  /// **'You must agree to the terms'**
  String get agreeRequired;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get register;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get haveAccount;

  /// No description provided for @accountCreated.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully'**
  String get accountCreated;

  /// No description provided for @emailInUse.
  ///
  /// In en, this message translates to:
  /// **'Email already in use'**
  String get emailInUse;

  /// No description provided for @weakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak'**
  String get weakPassword;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we\'ll send you a password reset link'**
  String get forgotPasswordSubtitle;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'Reset link sent'**
  String get resetLinkSent;

  /// No description provided for @checkYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Check your email and follow the link to reset your password'**
  String get checkYourEmail;

  /// No description provided for @passwordResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password reset successful'**
  String get passwordResetSuccess;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get invalidEmail;

  /// No description provided for @setNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Set New Password'**
  String get setNewPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @passwordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated'**
  String get passwordUpdated;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send Verification Code'**
  String get sendOtp;

  /// No description provided for @verifyOtp.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verifyOtp;

  /// No description provided for @winterSaleTitle.
  ///
  /// In en, this message translates to:
  /// **'Winter Sale\nMega Discount'**
  String get winterSaleTitle;

  /// No description provided for @winterSaleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Up to 50% off'**
  String get winterSaleSubtitle;

  /// No description provided for @appleDevicesTitle.
  ///
  /// In en, this message translates to:
  /// **'New Apple\nDevices'**
  String get appleDevicesTitle;

  /// No description provided for @appleDevicesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Shop now'**
  String get appleDevicesSubtitle;

  /// No description provided for @categoryElectronics.
  ///
  /// In en, this message translates to:
  /// **'Electronics'**
  String get categoryElectronics;

  /// No description provided for @categoryFashion.
  ///
  /// In en, this message translates to:
  /// **'Fashion'**
  String get categoryFashion;

  /// No description provided for @categoryHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get categoryHome;

  /// No description provided for @categoryPerfumes.
  ///
  /// In en, this message translates to:
  /// **'Perfumes'**
  String get categoryPerfumes;

  /// No description provided for @categoryWatches.
  ///
  /// In en, this message translates to:
  /// **'Watches'**
  String get categoryWatches;

  /// No description provided for @categorySports.
  ///
  /// In en, this message translates to:
  /// **'Sports'**
  String get categorySports;

  /// No description provided for @bannerSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get bannerSecurity;

  /// No description provided for @bannerCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get bannerCamera;

  /// No description provided for @bannerPerformance.
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get bannerPerformance;

  /// No description provided for @exclusiveCollection.
  ///
  /// In en, this message translates to:
  /// **'Exclusive Collection'**
  String get exclusiveCollection;

  /// No description provided for @seasonCollection.
  ///
  /// In en, this message translates to:
  /// **'Season\'s\nNew Collection'**
  String get seasonCollection;

  /// No description provided for @infiniteElegance.
  ///
  /// In en, this message translates to:
  /// **'Infinite elegance...'**
  String get infiniteElegance;

  /// No description provided for @moveWithDetails.
  ///
  /// In en, this message translates to:
  /// **'Move with\nevery detail'**
  String get moveWithDetails;

  /// No description provided for @sectionByCategory.
  ///
  /// In en, this message translates to:
  /// **'Shop by Category'**
  String get sectionByCategory;

  /// No description provided for @sectionNewArrivals.
  ///
  /// In en, this message translates to:
  /// **'New Arrivals'**
  String get sectionNewArrivals;

  /// No description provided for @sectionBestSellers.
  ///
  /// In en, this message translates to:
  /// **'Best Sellers'**
  String get sectionBestSellers;

  /// No description provided for @sectionExclusive.
  ///
  /// In en, this message translates to:
  /// **'Exclusive'**
  String get sectionExclusive;

  /// No description provided for @timeMonth.
  ///
  /// In en, this message translates to:
  /// **'{count} month(s) ago'**
  String timeMonth(int count);

  /// No description provided for @timeDay.
  ///
  /// In en, this message translates to:
  /// **'{count} day(s) ago'**
  String timeDay(int count);

  /// No description provided for @timeHour.
  ///
  /// In en, this message translates to:
  /// **'{count} hour(s) ago'**
  String timeHour(int count);

  /// No description provided for @timeNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get timeNow;

  /// No description provided for @defaultUserName.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get defaultUserName;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfileTitle;

  /// No description provided for @underDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Under Development'**
  String get underDevelopment;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @myFavorites.
  ///
  /// In en, this message translates to:
  /// **'My Favorites'**
  String get myFavorites;

  /// No description provided for @removeFromList.
  ///
  /// In en, this message translates to:
  /// **'Remove from list'**
  String get removeFromList;

  /// No description provided for @addToCartSuccess.
  ///
  /// In en, this message translates to:
  /// **'Product added to cart'**
  String get addToCartSuccess;

  /// No description provided for @addToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Added to favorites'**
  String get addToFavorites;

  /// No description provided for @removeFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites'**
  String get removeFromFavorites;

  /// No description provided for @noFavorites.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get noFavorites;

  /// No description provided for @loadErrorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String loadErrorPrefix(String error);

  /// No description provided for @label.
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get label;

  /// No description provided for @street.
  ///
  /// In en, this message translates to:
  /// **'Street'**
  String get street;

  /// No description provided for @setDefault.
  ///
  /// In en, this message translates to:
  /// **'Set as default'**
  String get setDefault;

  /// No description provided for @addAddress.
  ///
  /// In en, this message translates to:
  /// **'Add Address'**
  String get addAddress;

  /// No description provided for @addressSaved.
  ///
  /// In en, this message translates to:
  /// **'Address saved'**
  String get addressSaved;

  /// No description provided for @deleteAddressConfirmMsg.
  ///
  /// In en, this message translates to:
  /// **'Delete this address?'**
  String get deleteAddressConfirmMsg;

  /// No description provided for @editProfileSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile saved'**
  String get editProfileSuccess;

  /// No description provided for @noConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noConnection;

  /// No description provided for @noConnectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection and try again'**
  String get noConnectionSubtitle;

  /// No description provided for @connectionRestored.
  ///
  /// In en, this message translates to:
  /// **'Connection restored'**
  String get connectionRestored;

  /// No description provided for @saveAddressPrompt.
  ///
  /// In en, this message translates to:
  /// **'Would you like to save this address?'**
  String get saveAddressPrompt;

  /// No description provided for @appInformation.
  ///
  /// In en, this message translates to:
  /// **'App Information'**
  String get appInformation;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @returnPolicy.
  ///
  /// In en, this message translates to:
  /// **'Return Policy'**
  String get returnPolicy;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @contactUsSection.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUsSection;

  /// No description provided for @keepInTouch.
  ///
  /// In en, this message translates to:
  /// **'Keep in Touch'**
  String get keepInTouch;

  /// No description provided for @dangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get dangerZone;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressLabel;

  /// No description provided for @orderPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get orderPending;

  /// No description provided for @orderCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get orderCancelled;

  /// No description provided for @orderShipped.
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get orderShipped;

  /// No description provided for @orderDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get orderDelivered;

  /// No description provided for @orderConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get orderConfirmed;

  /// No description provided for @viewOrderDetail.
  ///
  /// In en, this message translates to:
  /// **'View Order Details'**
  String get viewOrderDetail;

  /// No description provided for @goShopping.
  ///
  /// In en, this message translates to:
  /// **'Go Shopping'**
  String get goShopping;

  /// No description provided for @orderedProducts.
  ///
  /// In en, this message translates to:
  /// **'Ordered Products'**
  String get orderedProducts;

  /// No description provided for @invoiceDetails.
  ///
  /// In en, this message translates to:
  /// **'Invoice Details'**
  String get invoiceDetails;

  /// No description provided for @orderNumberCopied.
  ///
  /// In en, this message translates to:
  /// **'Order number copied'**
  String get orderNumberCopied;

  /// No description provided for @trackerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track your shipment and order status'**
  String get trackerSubtitle;

  /// No description provided for @orderCancelledMessage.
  ///
  /// In en, this message translates to:
  /// **'This order has been cancelled and cannot be tracked.'**
  String get orderCancelledMessage;

  /// No description provided for @deliveryLocation.
  ///
  /// In en, this message translates to:
  /// **'Delivery Location'**
  String get deliveryLocation;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @cashOnDelivery.
  ///
  /// In en, this message translates to:
  /// **'Cash on Delivery'**
  String get cashOnDelivery;

  /// No description provided for @creditCard.
  ///
  /// In en, this message translates to:
  /// **'Credit Card'**
  String get creditCard;

  /// No description provided for @orderStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Order Placed'**
  String get orderStatusPending;

  /// No description provided for @orderStatusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get orderStatusConfirmed;

  /// No description provided for @orderStatusShipped.
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get orderStatusShipped;

  /// No description provided for @orderStatusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get orderStatusDelivered;

  /// No description provided for @orderStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get orderStatusCancelled;

  /// No description provided for @editPersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get editPersonalInfo;

  /// No description provided for @accountData.
  ///
  /// In en, this message translates to:
  /// **'Account Data'**
  String get accountData;

  /// No description provided for @nameHint.
  ///
  /// In en, this message translates to:
  /// **'Your full name'**
  String get nameHint;

  /// No description provided for @leaveBlankHint.
  ///
  /// In en, this message translates to:
  /// **'Leave blank if you don\'t want to change'**
  String get leaveBlankHint;

  /// No description provided for @passwordMin6.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMin6;

  /// No description provided for @retypePassword.
  ///
  /// In en, this message translates to:
  /// **'Retype password'**
  String get retypePassword;

  /// No description provided for @phoneTooShort.
  ///
  /// In en, this message translates to:
  /// **'Phone number is too short (must be {max} digits)'**
  String phoneTooShort(Object max);

  /// No description provided for @countryCode.
  ///
  /// In en, this message translates to:
  /// **'Country Code'**
  String get countryCode;

  /// No description provided for @invalidEmailMessage.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get invalidEmailMessage;

  /// No description provided for @noUserLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'No user is logged in'**
  String get noUserLoggedIn;

  /// No description provided for @emailVerificationSent.
  ///
  /// In en, this message translates to:
  /// **'Verification link sent to your new email. Please confirm it.'**
  String get emailVerificationSent;

  /// No description provided for @changeEmailPasswordRequiresReLogin.
  ///
  /// In en, this message translates to:
  /// **'To change email or password, please log out and log in again first'**
  String get changeEmailPasswordRequiresReLogin;

  /// No description provided for @emailAlreadyInUse.
  ///
  /// In en, this message translates to:
  /// **'This email is already in use'**
  String get emailAlreadyInUse;

  /// No description provided for @weakPasswordMessage.
  ///
  /// In en, this message translates to:
  /// **'Weak password, please choose a stronger password'**
  String get weakPasswordMessage;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred'**
  String get unexpectedError;

  /// No description provided for @deliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Delivery Address'**
  String get deliveryAddress;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @governorate.
  ///
  /// In en, this message translates to:
  /// **'Governorate'**
  String get governorate;

  /// No description provided for @regionGovernorate.
  ///
  /// In en, this message translates to:
  /// **'Region / Governorate'**
  String get regionGovernorate;

  /// No description provided for @addressDetails.
  ///
  /// In en, this message translates to:
  /// **'Address Details'**
  String get addressDetails;

  /// No description provided for @selectCountry.
  ///
  /// In en, this message translates to:
  /// **'Select Country'**
  String get selectCountry;

  /// No description provided for @selectRegionRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select region / governorate'**
  String get selectRegionRequired;

  /// No description provided for @selectOption.
  ///
  /// In en, this message translates to:
  /// **'Please select an option'**
  String get selectOption;

  /// No description provided for @selectGovernorate.
  ///
  /// In en, this message translates to:
  /// **'Select Governorate'**
  String get selectGovernorate;

  /// No description provided for @selectRegionGovernorate.
  ///
  /// In en, this message translates to:
  /// **'Select Region / Governorate'**
  String get selectRegionGovernorate;

  /// No description provided for @addressRequired.
  ///
  /// In en, this message translates to:
  /// **'Address field is required'**
  String get addressRequired;

  /// No description provided for @currentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current Location'**
  String get currentLocation;

  /// No description provided for @locationInstruction.
  ///
  /// In en, this message translates to:
  /// **'Tap on the map to change the geographical location'**
  String get locationInstruction;

  /// No description provided for @saveAddress.
  ///
  /// In en, this message translates to:
  /// **'Save Address'**
  String get saveAddress;

  /// No description provided for @addressRequiredMsg.
  ///
  /// In en, this message translates to:
  /// **'Please select region / governorate'**
  String get addressRequiredMsg;

  /// No description provided for @addressSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Address saved successfully'**
  String get addressSavedSuccess;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorOccurred(Object error);

  /// No description provided for @selectCountryCode.
  ///
  /// In en, this message translates to:
  /// **'Select Country Code'**
  String get selectCountryCode;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied'**
  String get permissionDenied;

  /// No description provided for @permissionDeniedForever.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied forever from device settings'**
  String get permissionDeniedForever;

  /// No description provided for @locationFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not determine current location'**
  String get locationFailed;

  /// No description provided for @emptyCartCheckout.
  ///
  /// In en, this message translates to:
  /// **'Your cart is currently empty'**
  String get emptyCartCheckout;

  /// No description provided for @shippingOption.
  ///
  /// In en, this message translates to:
  /// **'Shipping Option'**
  String get shippingOption;

  /// No description provided for @promoCode.
  ///
  /// In en, this message translates to:
  /// **'Promo Code / Coupon'**
  String get promoCode;

  /// No description provided for @costSummary.
  ///
  /// In en, this message translates to:
  /// **'Cost Summary'**
  String get costSummary;

  /// No description provided for @orderItems.
  ///
  /// In en, this message translates to:
  /// **'Items ({count})'**
  String orderItems(Object count);

  /// No description provided for @hideDetails.
  ///
  /// In en, this message translates to:
  /// **'Hide Details'**
  String get hideDetails;

  /// No description provided for @showDetails.
  ///
  /// In en, this message translates to:
  /// **'Show Details'**
  String get showDetails;

  /// No description provided for @standardDelivery.
  ///
  /// In en, this message translates to:
  /// **'Standard Home Delivery'**
  String get standardDelivery;

  /// No description provided for @freeShippingDesc.
  ///
  /// In en, this message translates to:
  /// **'Free shipping on orders over 500 KWD'**
  String get freeShippingDesc;

  /// No description provided for @paidShippingDesc.
  ///
  /// In en, this message translates to:
  /// **'Secure and carefully packaged delivery within 2-3 business days'**
  String get paidShippingDesc;

  /// No description provided for @couponHint.
  ///
  /// In en, this message translates to:
  /// **'Enter coupon code (e.g. GOLD10)'**
  String get couponHint;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @applied.
  ///
  /// In en, this message translates to:
  /// **'Applied'**
  String get applied;

  /// No description provided for @appliedPromoCode.
  ///
  /// In en, this message translates to:
  /// **'Applied code: {code}'**
  String appliedPromoCode(Object code);

  /// No description provided for @cancelCode.
  ///
  /// In en, this message translates to:
  /// **'Cancel Code'**
  String get cancelCode;

  /// No description provided for @noAddress.
  ///
  /// In en, this message translates to:
  /// **'No saved delivery address'**
  String get noAddress;

  /// No description provided for @paymentUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This payment method is not available yet'**
  String get paymentUnavailable;

  /// No description provided for @noAddressWarning.
  ///
  /// In en, this message translates to:
  /// **'Please add a delivery address first'**
  String get noAddressWarning;

  /// No description provided for @quantityUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Requested quantity not available for some products'**
  String get quantityUnavailable;

  /// No description provided for @cardPaymentComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Online payment gateway will be available soon'**
  String get cardPaymentComingSoon;

  /// No description provided for @walletComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Digital wallet payment will be available soon'**
  String get walletComingSoon;

  /// No description provided for @couponDiscount.
  ///
  /// In en, this message translates to:
  /// **'Coupon Discount'**
  String get couponDiscount;

  /// No description provided for @shippingCost.
  ///
  /// In en, this message translates to:
  /// **'Shipping Cost'**
  String get shippingCost;

  /// No description provided for @confirmAndOrder.
  ///
  /// In en, this message translates to:
  /// **'Confirm & Place Order'**
  String get confirmAndOrder;

  /// No description provided for @checkoutUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This payment method is not available yet'**
  String get checkoutUnavailable;

  /// No description provided for @editAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Edit Address 📍'**
  String get editAddressLabel;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsAndConditions;

  /// No description provided for @privacyPolicyContent.
  ///
  /// In en, this message translates to:
  /// **'We are committed to protecting your privacy and personal data security. Data is only collected to enhance your experience and process your orders safely.'**
  String get privacyPolicyContent;

  /// No description provided for @termsContent.
  ///
  /// In en, this message translates to:
  /// **'By using this app, you agree to our terms of service. All products are subject to availability and the prices listed are in KWD.'**
  String get termsContent;

  /// No description provided for @returnPolicyContent.
  ///
  /// In en, this message translates to:
  /// **'You can request returns or exchanges for eligible products within 14 days of receipt, provided they are in their original condition and unopened packaging.'**
  String get returnPolicyContent;

  /// No description provided for @customerServiceCall.
  ///
  /// In en, this message translates to:
  /// **'Customer Service (Call)'**
  String get customerServiceCall;

  /// No description provided for @emailSupport.
  ///
  /// In en, this message translates to:
  /// **'Email Support'**
  String get emailSupport;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @welcomeUser.
  ///
  /// In en, this message translates to:
  /// **'Welcome,'**
  String get welcomeUser;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete your account? This action cannot be undone.'**
  String get deleteAccountConfirm;

  /// No description provided for @deleteAccountSecurity.
  ///
  /// In en, this message translates to:
  /// **'Please log out and log back in to delete your account for security reasons.'**
  String get deleteAccountSecurity;

  /// No description provided for @deleteLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteLabel;

  /// No description provided for @firstReview.
  ///
  /// In en, this message translates to:
  /// **'Add first review'**
  String get firstReview;

  /// No description provided for @noReviews.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get noReviews;

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get outOfStock;

  /// No description provided for @stockWarning.
  ///
  /// In en, this message translates to:
  /// **'⚠ Only {count} left'**
  String stockWarning(Object count);

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// No description provided for @andOtherProducts.
  ///
  /// In en, this message translates to:
  /// **'and {count} other products'**
  String andOtherProducts(Object count);

  /// No description provided for @productCount.
  ///
  /// In en, this message translates to:
  /// **'Products: {count}'**
  String productCount(Object count);

  /// No description provided for @orderDetails.
  ///
  /// In en, this message translates to:
  /// **'View Order Details'**
  String get orderDetails;

  /// No description provided for @noOrders.
  ///
  /// In en, this message translates to:
  /// **'No Orders'**
  String get noOrders;

  /// No description provided for @noOrdersDesc.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t placed any orders in this section yet'**
  String get noOrdersDesc;

  /// No description provided for @promoSuccess.
  ///
  /// In en, this message translates to:
  /// **'Coupon ({percent}%) applied successfully'**
  String promoSuccess(int percent);

  /// No description provided for @invalidCoupon.
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired coupon code'**
  String get invalidCoupon;

  /// No description provided for @outOfStockItems.
  ///
  /// In en, this message translates to:
  /// **'Some items are out of stock, please remove them first'**
  String get outOfStockItems;

  /// No description provided for @insufficientStock.
  ///
  /// In en, this message translates to:
  /// **'Requested quantity is not available for some items'**
  String get insufficientStock;

  /// No description provided for @cardUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Online payment gateway will be available soon'**
  String get cardUnavailable;

  /// No description provided for @walletUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Digital wallet payment will be available soon'**
  String get walletUnavailable;

  /// No description provided for @pleaseAddAddress.
  ///
  /// In en, this message translates to:
  /// **'Please add a delivery address first'**
  String get pleaseAddAddress;

  /// No description provided for @itemQuantity.
  ///
  /// In en, this message translates to:
  /// **'Qty: {count}'**
  String itemQuantity(Object count);

  /// No description provided for @product.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get product;

  /// No description provided for @appInfo.
  ///
  /// In en, this message translates to:
  /// **'App Info'**
  String get appInfo;

  /// No description provided for @digitalWallet.
  ///
  /// In en, this message translates to:
  /// **'Digital Wallet'**
  String get digitalWallet;

  /// No description provided for @paymentMethodCodSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pay when you receive your order'**
  String get paymentMethodCodSubtitle;

  /// No description provided for @noProductsInSection.
  ///
  /// In en, this message translates to:
  /// **'No products in this section'**
  String get noProductsInSection;

  /// No description provided for @exitTitle.
  ///
  /// In en, this message translates to:
  /// **'Exit Confirmation'**
  String get exitTitle;

  /// No description provided for @exitConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to exit the app?'**
  String get exitConfirm;

  /// No description provided for @standardDeliveryLabel.
  ///
  /// In en, this message translates to:
  /// **'Standard Delivery'**
  String get standardDeliveryLabel;

  /// No description provided for @freeShippingLabel.
  ///
  /// In en, this message translates to:
  /// **'Free shipping 🎉'**
  String get freeShippingLabel;

  /// No description provided for @expressDeliveryLabel.
  ///
  /// In en, this message translates to:
  /// **'Express Delivery ⚡'**
  String get expressDeliveryLabel;

  /// No description provided for @freeShippingThreshold.
  ///
  /// In en, this message translates to:
  /// **'Only {price} left for free shipping 🚚'**
  String freeShippingThreshold(String price);

  /// No description provided for @preferredDeliveryTime.
  ///
  /// In en, this message translates to:
  /// **'Preferred Delivery Time'**
  String get preferredDeliveryTime;

  /// No description provided for @chooseDate.
  ///
  /// In en, this message translates to:
  /// **'Choose date'**
  String get chooseDate;

  /// No description provided for @phoneLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Phone Login'**
  String get phoneLoginTitle;

  /// No description provided for @phoneLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number to receive a verification code'**
  String get phoneLoginSubtitle;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneLabel;

  /// No description provided for @phoneHintExample.
  ///
  /// In en, this message translates to:
  /// **'Example: 66123456'**
  String get phoneHintExample;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get welcomeTitle;

  /// No description provided for @completeProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please complete your information so we can deliver your orders successfully'**
  String get completeProfileSubtitle;

  /// No description provided for @optionalHint.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optionalHint;

  /// No description provided for @saveAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Save & Continue'**
  String get saveAndContinue;

  /// No description provided for @otpEnterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter verification code'**
  String get otpEnterCode;

  /// No description provided for @otpSentTo.
  ///
  /// In en, this message translates to:
  /// **'A 6-digit code has been sent to\n{phone}'**
  String otpSentTo(String phone);

  /// No description provided for @resendFailed.
  ///
  /// In en, this message translates to:
  /// **'Resend failed. Try again.'**
  String get resendFailed;

  /// No description provided for @otpCodeRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter the full 6-digit code'**
  String get otpCodeRequired;

  /// No description provided for @passwordMin8.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordMin8;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordChangedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully!\nYou can now log in with your new password.'**
  String get passwordChangedSuccess;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @enterVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Enter Verification Code'**
  String get enterVerificationCode;

  /// No description provided for @resendInSeconds.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String resendInSeconds(int seconds);

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPasswordLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordLabel;

  /// No description provided for @invalidPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number. Check country code and number.'**
  String get invalidPhoneNumber;

  /// No description provided for @tooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again later.'**
  String get tooManyRequests;

  /// No description provided for @connectionError.
  ///
  /// In en, this message translates to:
  /// **'Connection error.'**
  String get connectionError;

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Check the number and try again.'**
  String get genericError;

  /// No description provided for @enterValidPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get enterValidPhone;

  /// No description provided for @sendVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Send Verification Code'**
  String get sendVerificationCode;

  /// No description provided for @loginWithPhone.
  ///
  /// In en, this message translates to:
  /// **'Login with Phone (OTP)'**
  String get loginWithPhone;

  /// No description provided for @signInWithApple.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple'**
  String get signInWithApple;

  /// No description provided for @orderStatusPlaced.
  ///
  /// In en, this message translates to:
  /// **'Order Placed'**
  String get orderStatusPlaced;

  /// No description provided for @orderStatusProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get orderStatusProcessing;

  /// No description provided for @orderStatusDeliveredLabel.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get orderStatusDeliveredLabel;

  /// No description provided for @orderStatusCancelledLabel.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get orderStatusCancelledLabel;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterOrderPlaced.
  ///
  /// In en, this message translates to:
  /// **'Order Placed'**
  String get filterOrderPlaced;

  /// No description provided for @filterProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get filterProcessing;

  /// No description provided for @filterDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get filterDelivered;

  /// No description provided for @filterCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get filterCancelled;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @selectCurrency.
  ///
  /// In en, this message translates to:
  /// **'Select Currency'**
  String get selectCurrency;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @arabicSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabicSubtitle;

  /// No description provided for @englishSubtitle.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get englishSubtitle;

  /// No description provided for @popularProductsTitle.
  ///
  /// In en, this message translates to:
  /// **'Popular Products'**
  String get popularProductsTitle;

  /// No description provided for @selectOptionFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select {option} first'**
  String selectOptionFirst(String option);

  /// No description provided for @hideReviews.
  ///
  /// In en, this message translates to:
  /// **'Hide Reviews'**
  String get hideReviews;

  /// No description provided for @priceChangedError.
  ///
  /// In en, this message translates to:
  /// **'Some product prices have changed. Please re-add them to cart.'**
  String get priceChangedError;

  /// No description provided for @googleSignInRequired.
  ///
  /// In en, this message translates to:
  /// **'You previously signed up with Google. Please sign in with Google.'**
  String get googleSignInRequired;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
