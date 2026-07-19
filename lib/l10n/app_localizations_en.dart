// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Electronic';

  @override
  String get appTagline => 'Luxury Shopping with Style';

  @override
  String get home => 'Home';

  @override
  String get categories => 'Categories';

  @override
  String get cart => 'Cart';

  @override
  String get favorites => 'Favorites';

  @override
  String get profile => 'Profile';

  @override
  String get orders => 'My Orders';

  @override
  String get notifications => 'Notifications';

  @override
  String get search => 'Search';

  @override
  String get offers => 'Offers';

  @override
  String get fiveStarRating => 'Top Rated';

  @override
  String get goodMorning => 'Good morning 👋';

  @override
  String get guest => 'Guest';

  @override
  String get myAccount => 'My Account';

  @override
  String get searchHint => 'Search electronics, fashion, perfumes...';

  @override
  String get browseCategories => 'Browse categories';

  @override
  String get viewAll => 'View All';

  @override
  String get shopNow => 'Shop Now';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get submit => 'Submit';

  @override
  String get delete => 'Delete';

  @override
  String get deleteAll => 'Delete All';

  @override
  String get confirm => 'Confirm';

  @override
  String get save => 'Save';

  @override
  String get allProducts => 'All Products';

  @override
  String get all => 'All';

  @override
  String get noProducts => 'No products found';

  @override
  String get loadingMore => 'Loading more...';

  @override
  String get allProductsShown => 'All products shown';

  @override
  String errorPrefix(String error) {
    return 'Error: $error';
  }

  @override
  String priceFormat(String price) {
    return '$price KWD';
  }

  @override
  String get popularProducts => 'Popular Products';

  @override
  String get featuredProducts => 'Featured';

  @override
  String get latestProducts => 'New Arrivals';

  @override
  String get bestSeller => 'Best Seller';

  @override
  String get newLabel => 'New';

  @override
  String get exclusive => 'Exclusive';

  @override
  String discountPercent(int percent) {
    return '$percent% OFF';
  }

  @override
  String get searchInitialTitle => 'Search for a product';

  @override
  String get searchInitialSubtitle => 'Type a keyword to search';

  @override
  String get searchEmptyTitle => 'No results found';

  @override
  String get searchEmptySubtitle => 'Try a different keyword';

  @override
  String productCode(String code) {
    return 'Code: $code';
  }

  @override
  String get inStock => 'In Stock';

  @override
  String get lastPieceAlert => 'Last piece! 🔥';

  @override
  String lowStockAlert(int count) {
    return 'Only $count left';
  }

  @override
  String stockAvailable(int count) {
    return 'In stock: $count';
  }

  @override
  String reviewCount(int count) {
    return '($count reviews)';
  }

  @override
  String get description => 'Description';

  @override
  String get specifications => 'Specifications';

  @override
  String get reviews => 'Reviews';

  @override
  String get addReview => 'Add Your Review';

  @override
  String get writeReviewHint => 'Write your review...';

  @override
  String get selectStarRating => 'Select star rating';

  @override
  String get reviewSubmitted => 'Review submitted successfully';

  @override
  String get reviewDefaultComment => 'Great product';

  @override
  String get loadError => 'Failed to load data';

  @override
  String get addToCart => 'Add to Cart';

  @override
  String addedToCart(int quantity) {
    return 'Added $quantity item(s) to cart';
  }

  @override
  String get addToWishlist => 'Added to favorites';

  @override
  String get removeFromWishlist => 'Removed from favorites';

  @override
  String get addedToCartToast => 'Added to cart';

  @override
  String get similarProducts => 'Similar Products';

  @override
  String get cartTitle => 'Shopping Cart';

  @override
  String get cartEmpty => 'Your cart is empty';

  @override
  String get cartEmptySubtitle => 'Browse products and add what you like';

  @override
  String get cartNotLoaded => 'Cart not loaded yet.';

  @override
  String cartError(String error) {
    return 'Error: $error';
  }

  @override
  String get total => 'Total';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get shipping => 'Shipping';

  @override
  String get free => 'Free';

  @override
  String get grandTotal => 'Grand Total';

  @override
  String get orderPlaced => 'Order Placed';

  @override
  String get confirmed => 'Confirmed';

  @override
  String get delivered => 'Delivered';

  @override
  String get orderDetailProducts => 'Ordered Products';

  @override
  String get checkout => 'Checkout';

  @override
  String quantity(int quantity) {
    return 'Qty: $quantity';
  }

  @override
  String get itemDeleted => 'Item removed from cart';

  @override
  String get cartCleared => 'Cart cleared';

  @override
  String get clearCartTitle => 'Clear Cart';

  @override
  String get clearCartConfirm => 'Are you sure you want to remove all items?';

  @override
  String get checkoutTitle => 'Checkout';

  @override
  String get shippingAddress => 'Shipping Address';

  @override
  String get fullName => 'Full Name';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get contactDetails => 'Contact Details';

  @override
  String get phoneHint => 'Your phone number';

  @override
  String get address => 'Address';

  @override
  String get city => 'City';

  @override
  String get required => 'Required';

  @override
  String get orderSummary => 'Order Summary';

  @override
  String get products => 'Products';

  @override
  String get placingOrder => 'Placing order...';

  @override
  String get confirmOrder => 'Confirm & Place Order';

  @override
  String get confirmOrderTitle => 'Confirm Order';

  @override
  String get confirmOrderMessage =>
      'Are you sure you want to confirm this order?';

  @override
  String get orderSuccess => 'Order placed successfully!';

  @override
  String orderNumber(String id) {
    return 'Order #$id';
  }

  @override
  String get trackOrder => 'Track Order';

  @override
  String get backToHome => 'Back to Home';

  @override
  String get loginRequired => 'You must login first';

  @override
  String get loginRequiredSubtitle => 'Log in to access this feature';

  @override
  String get removeOutOfStockItems =>
      'Some items are out of stock, please remove them first';

  @override
  String get searchInSection => 'Search in this section...';

  @override
  String browseCollection(Object label) {
    return 'Browse $label';
  }

  @override
  String get browseAsGuest => 'Browse as Guest';

  @override
  String orderFailed(String error) {
    return 'Order failed: $error';
  }

  @override
  String get myOrders => 'My Orders';

  @override
  String get ordersEmpty => 'No orders yet';

  @override
  String get ordersEmptySubtitle => 'Start shopping for your first order';

  @override
  String get continueShopping => 'Continue Shopping';

  @override
  String itemsCount(int count) {
    return '$count items';
  }

  @override
  String get orderDetail => 'Order Detail';

  @override
  String get orderNotFound => 'Order not found';

  @override
  String get orderStatus => 'Order Status';

  @override
  String get wishlistTitle => 'My Favorites';

  @override
  String get wishlistEmpty => 'Favorites is empty';

  @override
  String get wishlistEmptySubtitle => 'Add your favorite products here';

  @override
  String get addToCartFromWishlist => 'Added to cart';

  @override
  String get profileTitle => 'My Account';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get myAddresses => 'My Addresses';

  @override
  String get language => 'Language';

  @override
  String get about => 'About App';

  @override
  String get terms => 'Terms & Conditions';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirm => 'Are you sure you want to logout?';

  @override
  String get logoutTitle => 'Logout';

  @override
  String get accountSection => 'Account';

  @override
  String get browseSection => 'Browse';

  @override
  String get supportSection => 'Support';

  @override
  String get statsOrders => 'Orders';

  @override
  String get statsWishlist => 'Wishlist';

  @override
  String get statsCart => 'Cart';

  @override
  String get edit => 'Edit';

  @override
  String get loginTitle => 'Welcome Back 👋';

  @override
  String get loginSubtitle => 'Sign in to continue shopping';

  @override
  String get email => 'Email';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get emailInvalid => 'Invalid email';

  @override
  String get password => 'Password';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get passwordMinLength => 'Password must be at least 8 characters';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get login => 'Login';

  @override
  String get or => 'OR';

  @override
  String get googleLogin => 'Sign in with Google';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get orDivider => 'or';

  @override
  String get googleSignInCancelled => 'Google sign-in was cancelled';

  @override
  String get phoneVerificationTitle => 'Phone Verification';

  @override
  String phoneVerificationSubtitle(Object phone) {
    return 'We sent a verification code to $phone';
  }

  @override
  String get phoneVerificationBackTitle => 'Confirm Go Back';

  @override
  String get phoneVerificationBackConfirm =>
      'Are you sure you want to go back? Registration will be cancelled.';

  @override
  String get otpLabel => 'Enter Code';

  @override
  String get otpHint => '6-digit code';

  @override
  String get verifyPhone => 'Verify & Continue';

  @override
  String get resendCode => 'Resend Code';

  @override
  String resendIn(Object seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get otpInvalid => 'Please enter the full 6-digit code';

  @override
  String get phoneVerified => 'Phone verified successfully';

  @override
  String get noAccount => 'Don\'t have an account? ';

  @override
  String get createAccount => 'Create Account';

  @override
  String get loginError => 'Login failed';

  @override
  String get emailNotRegistered => 'Email not registered';

  @override
  String get wrongPassword => 'Wrong password';

  @override
  String get tooManyAttempts => 'Too many attempts. Try again later.';

  @override
  String get invalidCredentials => 'Invalid email or password';

  @override
  String get networkError => 'Check your internet connection';

  @override
  String get registerTitle => 'Create New Account ✨';

  @override
  String get registerSubtitle =>
      'Join us and enjoy a premium shopping experience';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get firstNameRequired => 'First name is required';

  @override
  String get lastNameRequired => 'Last name is required';

  @override
  String get fullNameRequired => 'Name is required';

  @override
  String get fullNameShort => 'Name is too short';

  @override
  String get phoneRequired => 'Phone number is required';

  @override
  String get phoneInvalid => 'Invalid phone number';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get passwordMismatch => 'Passwords do not match';

  @override
  String get agreeTerms => 'I agree to the Terms & Conditions';

  @override
  String get agreeToTerms => 'I agree to the';

  @override
  String get separatorAnd => 'and';

  @override
  String get agreeRequired => 'You must agree to the terms';

  @override
  String get register => 'Create Account';

  @override
  String get haveAccount => 'Already have an account? ';

  @override
  String get accountCreated => 'Account created successfully';

  @override
  String get emailInUse => 'Email already in use';

  @override
  String get weakPassword => 'Password is too weak';

  @override
  String get forgotPasswordTitle => 'Forgot Password?';

  @override
  String get forgotPasswordSubtitle =>
      'Enter your email and we\'ll send you a password reset link';

  @override
  String get sendResetLink => 'Send Reset Link';

  @override
  String get resetLinkSent => 'Reset link sent';

  @override
  String get checkYourEmail =>
      'Check your email and follow the link to reset your password';

  @override
  String get passwordResetSuccess => 'Password reset successful';

  @override
  String get invalidEmail => 'Please enter a valid email';

  @override
  String get setNewPassword => 'Set New Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get passwordUpdated => 'Password updated';

  @override
  String get sendOtp => 'Send Verification Code';

  @override
  String get verifyOtp => 'Verify';

  @override
  String get winterSaleTitle => 'Winter Sale\nMega Discount';

  @override
  String get winterSaleSubtitle => 'Up to 50% off';

  @override
  String get appleDevicesTitle => 'New Apple\nDevices';

  @override
  String get appleDevicesSubtitle => 'Shop now';

  @override
  String get categoryElectronics => 'Electronics';

  @override
  String get categoryFashion => 'Fashion';

  @override
  String get categoryHome => 'Home';

  @override
  String get categoryPerfumes => 'Perfumes';

  @override
  String get categoryWatches => 'Watches';

  @override
  String get categorySports => 'Sports';

  @override
  String get bannerSecurity => 'Security';

  @override
  String get bannerCamera => 'Camera';

  @override
  String get bannerPerformance => 'Performance';

  @override
  String get exclusiveCollection => 'Exclusive Collection';

  @override
  String get seasonCollection => 'Season\'s\nNew Collection';

  @override
  String get infiniteElegance => 'Infinite elegance...';

  @override
  String get moveWithDetails => 'Move with\nevery detail';

  @override
  String get sectionByCategory => 'Shop by Category';

  @override
  String get sectionNewArrivals => 'New Arrivals';

  @override
  String get sectionBestSellers => 'Best Sellers';

  @override
  String get sectionExclusive => 'Exclusive';

  @override
  String timeMonth(int count) {
    return '$count month(s) ago';
  }

  @override
  String timeDay(int count) {
    return '$count day(s) ago';
  }

  @override
  String timeHour(int count) {
    return '$count hour(s) ago';
  }

  @override
  String get timeNow => 'Just now';

  @override
  String get defaultUserName => 'User';

  @override
  String get welcome => 'Welcome';

  @override
  String get editProfileTitle => 'Edit Profile';

  @override
  String get underDevelopment => 'Under Development';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get myFavorites => 'My Favorites';

  @override
  String get removeFromList => 'Remove from list';

  @override
  String get addToCartSuccess => 'Product added to cart';

  @override
  String get addToFavorites => 'Added to favorites';

  @override
  String get removeFromFavorites => 'Removed from favorites';

  @override
  String get noFavorites => 'No favorites yet';

  @override
  String loadErrorPrefix(String error) {
    return 'Error: $error';
  }

  @override
  String get label => 'Label';

  @override
  String get street => 'Street';

  @override
  String get setDefault => 'Set as default';

  @override
  String get addAddress => 'Add Address';

  @override
  String get addressSaved => 'Address saved';

  @override
  String get deleteAddressConfirmMsg => 'Delete this address?';

  @override
  String get editProfileSuccess => 'Profile saved';

  @override
  String get noConnection => 'No internet connection';

  @override
  String get noConnectionSubtitle =>
      'Please check your internet connection and try again';

  @override
  String get connectionRestored => 'Connection restored';

  @override
  String get saveAddressPrompt => 'Would you like to save this address?';

  @override
  String get appInformation => 'App Information';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get returnPolicy => 'Return Policy';

  @override
  String get appVersion => 'App Version';

  @override
  String get contactUsSection => 'Contact Us';

  @override
  String get keepInTouch => 'Keep in Touch';

  @override
  String get dangerZone => 'Danger Zone';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get addressLabel => 'Address';

  @override
  String get orderPending => 'Pending';

  @override
  String get orderCancelled => 'Cancelled';

  @override
  String get orderShipped => 'Shipped';

  @override
  String get orderDelivered => 'Delivered';

  @override
  String get orderConfirmed => 'Confirmed';

  @override
  String get viewOrderDetail => 'View Order Details';

  @override
  String get goShopping => 'Go Shopping';

  @override
  String get orderedProducts => 'Ordered Products';

  @override
  String get invoiceDetails => 'Invoice Details';

  @override
  String get orderNumberCopied => 'Order number copied';

  @override
  String get trackerSubtitle => 'Track your shipment and order status';

  @override
  String get orderCancelledMessage =>
      'This order has been cancelled and cannot be tracked.';

  @override
  String get deliveryLocation => 'Delivery Location';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get cashOnDelivery => 'Cash on Delivery';

  @override
  String get creditCard => 'Credit Card';

  @override
  String get orderStatusPending => 'Order Placed';

  @override
  String get orderStatusConfirmed => 'Confirmed';

  @override
  String get orderStatusShipped => 'Shipped';

  @override
  String get orderStatusDelivered => 'Delivered';

  @override
  String get orderStatusCancelled => 'Cancelled';

  @override
  String get editPersonalInfo => 'Personal Information';

  @override
  String get accountData => 'Account Data';

  @override
  String get nameHint => 'Your full name';

  @override
  String get leaveBlankHint => 'Leave blank if you don\'t want to change';

  @override
  String get passwordMin6 => 'Password must be at least 6 characters';

  @override
  String get retypePassword => 'Retype password';

  @override
  String phoneTooShort(Object max) {
    return 'Phone number is too short (must be $max digits)';
  }

  @override
  String get countryCode => 'Country Code';

  @override
  String get invalidEmailMessage => 'Invalid email address';

  @override
  String get noUserLoggedIn => 'No user is logged in';

  @override
  String get emailVerificationSent =>
      'Verification link sent to your new email. Please confirm it.';

  @override
  String get changeEmailPasswordRequiresReLogin =>
      'To change email or password, please log out and log in again first';

  @override
  String get emailAlreadyInUse => 'This email is already in use';

  @override
  String get weakPasswordMessage =>
      'Weak password, please choose a stronger password';

  @override
  String get unexpectedError => 'An unexpected error occurred';

  @override
  String get deliveryAddress => 'Delivery Address';

  @override
  String get country => 'Country';

  @override
  String get governorate => 'Governorate';

  @override
  String get regionGovernorate => 'Region / Governorate';

  @override
  String get addressDetails => 'Address Details';

  @override
  String get selectCountry => 'Select Country';

  @override
  String get selectRegionRequired => 'Please select region / governorate';

  @override
  String get selectOption => 'Please select an option';

  @override
  String get selectGovernorate => 'Select Governorate';

  @override
  String get selectRegionGovernorate => 'Select Region / Governorate';

  @override
  String get addressRequired => 'Address field is required';

  @override
  String get currentLocation => 'Current Location';

  @override
  String get locationInstruction =>
      'Tap on the map to change the geographical location';

  @override
  String get saveAddress => 'Save Address';

  @override
  String get addressRequiredMsg => 'Please select region / governorate';

  @override
  String get addressSavedSuccess => 'Address saved successfully';

  @override
  String errorOccurred(Object error) {
    return 'Error: $error';
  }

  @override
  String get selectCountryCode => 'Select Country Code';

  @override
  String get permissionDenied => 'Location permission denied';

  @override
  String get permissionDeniedForever =>
      'Location permission denied forever from device settings';

  @override
  String get locationFailed => 'Could not determine current location';

  @override
  String get emptyCartCheckout => 'Your cart is currently empty';

  @override
  String get shippingOption => 'Shipping Option';

  @override
  String get promoCode => 'Promo Code / Coupon';

  @override
  String get costSummary => 'Cost Summary';

  @override
  String orderItems(Object count) {
    return 'Items ($count)';
  }

  @override
  String get hideDetails => 'Hide Details';

  @override
  String get showDetails => 'Show Details';

  @override
  String get standardDelivery => 'Standard Home Delivery';

  @override
  String get freeShippingDesc => 'Free shipping on orders over 500 KWD';

  @override
  String get paidShippingDesc =>
      'Secure and carefully packaged delivery within 2-3 business days';

  @override
  String get couponHint => 'Enter coupon code (e.g. GOLD10)';

  @override
  String get apply => 'Apply';

  @override
  String get applied => 'Applied';

  @override
  String appliedPromoCode(Object code) {
    return 'Applied code: $code';
  }

  @override
  String get cancelCode => 'Cancel Code';

  @override
  String get noAddress => 'No saved delivery address';

  @override
  String get paymentUnavailable => 'This payment method is not available yet';

  @override
  String get noAddressWarning => 'Please add a delivery address first';

  @override
  String get quantityUnavailable =>
      'Requested quantity not available for some products';

  @override
  String get cardPaymentComingSoon =>
      'Online payment gateway will be available soon';

  @override
  String get walletComingSoon =>
      'Digital wallet payment will be available soon';

  @override
  String get couponDiscount => 'Coupon Discount';

  @override
  String get shippingCost => 'Shipping Cost';

  @override
  String get confirmAndOrder => 'Confirm & Place Order';

  @override
  String get checkoutUnavailable => 'This payment method is not available yet';

  @override
  String get editAddressLabel => 'Edit Address 📍';

  @override
  String get termsAndConditions => 'Terms & Conditions';

  @override
  String get privacyPolicyContent =>
      'We are committed to protecting your privacy and personal data security. Data is only collected to enhance your experience and process your orders safely.';

  @override
  String get termsContent =>
      'By using this app, you agree to our terms of service. All products are subject to availability and the prices listed are in KWD.';

  @override
  String get returnPolicyContent =>
      'You can request returns or exchanges for eligible products within 14 days of receipt, provided they are in their original condition and unopened packaging.';

  @override
  String get customerServiceCall => 'Customer Service (Call)';

  @override
  String get emailSupport => 'Email Support';

  @override
  String get backToLogin => 'Back to Login';

  @override
  String get close => 'Close';

  @override
  String get welcomeUser => 'Welcome,';

  @override
  String get deleteAccountTitle => 'Delete Account';

  @override
  String get deleteAccountConfirm =>
      'Are you sure you want to permanently delete your account? This action cannot be undone.';

  @override
  String get deleteAccountSecurity =>
      'Please log out and log back in to delete your account for security reasons.';

  @override
  String get deleteLabel => 'Delete';

  @override
  String get firstReview => 'Add first review';

  @override
  String get noReviews => 'No reviews yet';

  @override
  String get outOfStock => 'Out of Stock';

  @override
  String stockWarning(Object count) {
    return '⚠ Only $count left';
  }

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String andOtherProducts(Object count) {
    return 'and $count other products';
  }

  @override
  String productCount(Object count) {
    return 'Products: $count';
  }

  @override
  String get orderDetails => 'View Order Details';

  @override
  String get noOrders => 'No Orders';

  @override
  String get noOrdersDesc =>
      'You haven\'t placed any orders in this section yet';

  @override
  String promoSuccess(int percent) {
    return 'Coupon ($percent%) applied successfully';
  }

  @override
  String get invalidCoupon => 'Invalid or expired coupon code';

  @override
  String get outOfStockItems =>
      'Some items are out of stock, please remove them first';

  @override
  String get insufficientStock =>
      'Requested quantity is not available for some items';

  @override
  String get cardUnavailable => 'Online payment gateway will be available soon';

  @override
  String get walletUnavailable =>
      'Digital wallet payment will be available soon';

  @override
  String get pleaseAddAddress => 'Please add a delivery address first';

  @override
  String itemQuantity(Object count) {
    return 'Qty: $count';
  }

  @override
  String get product => 'Product';

  @override
  String get appInfo => 'App Info';

  @override
  String get digitalWallet => 'Digital Wallet';

  @override
  String get paymentMethodCodSubtitle => 'Pay when you receive your order';

  @override
  String get noProductsInSection => 'No products in this section';

  @override
  String get exitTitle => 'Exit Confirmation';

  @override
  String get exitConfirm => 'Are you sure you want to exit the app?';

  @override
  String get standardDeliveryLabel => 'Standard Delivery';

  @override
  String get freeShippingLabel => 'Free shipping 🎉';

  @override
  String get expressDeliveryLabel => 'Express Delivery ⚡';

  @override
  String freeShippingThreshold(String price) {
    return 'Only $price left for free shipping 🚚';
  }

  @override
  String get preferredDeliveryTime => 'Preferred Delivery Time';

  @override
  String get chooseDate => 'Choose date';

  @override
  String get phoneLoginTitle => 'Phone Login';

  @override
  String get phoneLoginSubtitle =>
      'Enter your phone number to receive a verification code';

  @override
  String get phoneLabel => 'Phone Number';

  @override
  String get phoneHintExample => 'Example: 66123456';

  @override
  String get continueButton => 'Continue';

  @override
  String get welcomeTitle => 'Welcome!';

  @override
  String get completeProfileSubtitle =>
      'Please complete your information so we can deliver your orders successfully';

  @override
  String get optionalHint => 'Optional';

  @override
  String get saveAndContinue => 'Save & Continue';

  @override
  String get otpEnterCode => 'Enter verification code';

  @override
  String otpSentTo(String phone) {
    return 'A 6-digit code has been sent to\n$phone';
  }

  @override
  String get resendFailed => 'Resend failed. Try again.';

  @override
  String get otpCodeRequired => 'Please enter the full 6-digit code';

  @override
  String get passwordMin8 => 'Password must be at least 8 characters';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get passwordChangedSuccess =>
      'Password changed successfully!\nYou can now log in with your new password.';

  @override
  String get changePassword => 'Change Password';

  @override
  String get enterVerificationCode => 'Enter Verification Code';

  @override
  String resendInSeconds(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get newPasswordLabel => 'New Password';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get invalidPhoneNumber =>
      'Invalid phone number. Check country code and number.';

  @override
  String get tooManyRequests => 'Too many attempts. Try again later.';

  @override
  String get connectionError => 'Connection error.';

  @override
  String get genericError =>
      'An error occurred. Check the number and try again.';

  @override
  String get enterValidPhone => 'Enter a valid phone number';

  @override
  String get sendVerificationCode => 'Send Verification Code';

  @override
  String get loginWithPhone => 'Login with Phone (OTP)';

  @override
  String get signInWithApple => 'Sign in with Apple';

  @override
  String get orderStatusPlaced => 'Order Placed';

  @override
  String get orderStatusProcessing => 'Processing';

  @override
  String get orderStatusDeliveredLabel => 'Delivered';

  @override
  String get orderStatusCancelledLabel => 'Cancelled';

  @override
  String get filterAll => 'All';

  @override
  String get filterOrderPlaced => 'Order Placed';

  @override
  String get filterProcessing => 'Processing';

  @override
  String get filterDelivered => 'Delivered';

  @override
  String get filterCancelled => 'Cancelled';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get selectCurrency => 'Select Currency';

  @override
  String get arabic => 'Arabic';

  @override
  String get arabicSubtitle => 'Arabic';

  @override
  String get englishSubtitle => 'English';

  @override
  String get popularProductsTitle => 'Popular Products';

  @override
  String selectOptionFirst(String option) {
    return 'Please select $option first';
  }

  @override
  String get hideReviews => 'Hide Reviews';

  @override
  String get priceChangedError =>
      'Some product prices have changed. Please re-add them to cart.';

  @override
  String get googleSignInRequired =>
      'You previously signed up with Google. Please sign in with Google.';
}
