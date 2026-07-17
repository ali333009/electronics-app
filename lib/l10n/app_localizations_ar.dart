// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'إلكترونيك';

  @override
  String get appTagline => 'تسوق فاخر بأناقة';

  @override
  String get home => 'الرئيسية';

  @override
  String get categories => 'التصنيفات';

  @override
  String get cart => 'سلة المشتريات';

  @override
  String get favorites => 'المفضلة';

  @override
  String get profile => 'حسابي';

  @override
  String get orders => 'طلباتي';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get search => 'بحث';

  @override
  String get offers => 'العروض';

  @override
  String get fiveStarRating => 'تقييم 5 نجوم';

  @override
  String get goodMorning => 'صباح الخير 👋';

  @override
  String get guest => 'زائر';

  @override
  String get myAccount => 'حسابي';

  @override
  String get searchHint => 'ابحث عن إلكترونيات، ملابس، عطور...';

  @override
  String get browseCategories => 'تصفح الأقسام';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get shopNow => 'تسوق الآن';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get cancel => 'إلغاء';

  @override
  String get submit => 'إرسال';

  @override
  String get delete => 'حذف';

  @override
  String get deleteAll => 'حذف الكل';

  @override
  String get confirm => 'تأكيد';

  @override
  String get save => 'حفظ';

  @override
  String get allProducts => 'جميع المنتجات';

  @override
  String get all => 'الكل';

  @override
  String get noProducts => 'لا توجد منتجات';

  @override
  String get loadingMore => 'جاري تحميل المزيد...';

  @override
  String get allProductsShown => 'تم عرض جميع المنتجات';

  @override
  String errorPrefix(String error) {
    return 'خطأ: $error';
  }

  @override
  String priceFormat(String price) {
    return '$price KWD';
  }

  @override
  String get popularProducts => 'المنتجات الشائعة';

  @override
  String get featuredProducts => 'حصرية المتجر';

  @override
  String get latestProducts => 'جديد المتجر';

  @override
  String get bestSeller => 'الأكثر مبيعاً';

  @override
  String get newLabel => 'جديد';

  @override
  String get exclusive => 'حصري';

  @override
  String discountPercent(int percent) {
    return 'خصم $percent%';
  }

  @override
  String get searchInitialTitle => 'ابحث عن منتج';

  @override
  String get searchInitialSubtitle => 'اكتب كلمة مفتاحية للبحث';

  @override
  String get searchEmptyTitle => 'لا توجد نتائج';

  @override
  String get searchEmptySubtitle => 'حاول بكلمة مفتاحية مختلفة';

  @override
  String productCode(String code) {
    return 'كود: $code';
  }

  @override
  String get inStock => 'متوفر';

  @override
  String get lastPieceAlert => 'آخر قطعة! 🔥';

  @override
  String lowStockAlert(int count) {
    return 'متبقي $count فقط';
  }

  @override
  String stockAvailable(int count) {
    return 'متوفر: $count';
  }

  @override
  String reviewCount(int count) {
    return '($count تقييم)';
  }

  @override
  String get description => 'الوصف';

  @override
  String get specifications => 'المواصفات';

  @override
  String get reviews => 'التقييمات';

  @override
  String get addReview => 'أضف تقييمك';

  @override
  String get writeReviewHint => 'اكتب رأيك في المنتج...';

  @override
  String get selectStarRating => 'اختر عدد النجوم';

  @override
  String get reviewSubmitted => 'تم إضافة تقييمك بنجاح';

  @override
  String get reviewDefaultComment => 'منتج ممتاز';

  @override
  String get loadError => 'تعذر تحميل البيانات';

  @override
  String get addToCart => 'أضف إلى السلة';

  @override
  String addedToCart(int quantity) {
    return 'تمت إضافة $quantity قطع إلى السلة';
  }

  @override
  String get addToWishlist => 'تمت الإضافة للمفضلة';

  @override
  String get removeFromWishlist => 'تمت الإزالة من المفضلة';

  @override
  String get addedToCartToast => 'تمت الإضافة للسلة';

  @override
  String get similarProducts => 'منتجات مشابهة';

  @override
  String get cartTitle => 'سلة التسوق';

  @override
  String get cartEmpty => 'سلتك فارغة';

  @override
  String get cartEmptySubtitle => 'تصفح المنتجات وأضف ما تريد';

  @override
  String get cartNotLoaded => 'لم يتم تحميل السلة بعد.';

  @override
  String cartError(String error) {
    return 'خطأ: $error';
  }

  @override
  String get total => 'الإجمالي';

  @override
  String get subtotal => 'المجموع الفرعي';

  @override
  String get shipping => 'الشحن';

  @override
  String get free => 'مجاناً';

  @override
  String get grandTotal => 'الإجمالي النهائي';

  @override
  String get orderPlaced => 'تم الطلب';

  @override
  String get confirmed => 'تأكيد';

  @override
  String get delivered => 'الاستلام';

  @override
  String get orderDetailProducts => 'المنتجات المطلوبة';

  @override
  String get checkout => 'إتمام الطلب';

  @override
  String quantity(int quantity) {
    return 'الكمية: $quantity';
  }

  @override
  String get itemDeleted => 'تم حذف المنتج من السلة';

  @override
  String get cartCleared => 'تم تفريغ السلة';

  @override
  String get clearCartTitle => 'تفريغ السلة';

  @override
  String get clearCartConfirm => 'هل أنت متأكد من حذف جميع المنتجات؟';

  @override
  String get checkoutTitle => 'إتمام الطلب';

  @override
  String get shippingAddress => 'عنوان الشحن';

  @override
  String get fullName => 'الاسم كامل';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get contactDetails => 'تفاصيل التواصل';

  @override
  String get phoneHint => 'رقم هاتفك';

  @override
  String get address => 'العنوان';

  @override
  String get city => 'المدينة';

  @override
  String get required => 'مطلوب';

  @override
  String get orderSummary => 'ملخص الطلب';

  @override
  String get products => 'المنتجات';

  @override
  String get placingOrder => 'جارٍ تأكيد الطلب...';

  @override
  String get confirmOrder => 'تأكيد وإتمام الطلب';

  @override
  String get confirmOrderTitle => 'تأكيد الطلب';

  @override
  String get confirmOrderMessage => 'هل أنت متأكد من تأكيد هذا الطلب؟';

  @override
  String get orderSuccess => 'تم تقديم طلبك بنجاح!';

  @override
  String orderNumber(String id) {
    return 'طلب #$id';
  }

  @override
  String get trackOrder => 'تتبع طلبك';

  @override
  String get backToHome => 'العودة للرئيسية';

  @override
  String get loginRequired => 'يجب تسجيل الدخول أولاً';

  @override
  String get loginRequiredSubtitle => 'سجّل دخولك للوصول لهذه الميزة';

  @override
  String get removeOutOfStockItems =>
      'يوجد منتجات نفذت من المخزن، يرجى إزالتها أولاً';

  @override
  String get searchInSection => 'ابحث في هذا القسم...';

  @override
  String browseCollection(Object label) {
    return 'تصفح مجموعة $label';
  }

  @override
  String get browseAsGuest => 'تصفح كضيف';

  @override
  String orderFailed(String error) {
    return 'فشل تقديم الطلب: $error';
  }

  @override
  String get myOrders => 'طلباتي';

  @override
  String get ordersEmpty => 'لا توجد طلبات';

  @override
  String get ordersEmptySubtitle => 'قم بشراء منتجاتك الأولى';

  @override
  String get continueShopping => 'مواصلة التسوق';

  @override
  String itemsCount(int count) {
    return '$count منتجات';
  }

  @override
  String get orderDetail => 'تفاصيل الطلب';

  @override
  String get orderNotFound => 'الطلب غير موجود';

  @override
  String get orderStatus => 'حالة الطلب';

  @override
  String get wishlistTitle => 'المفضلة';

  @override
  String get wishlistEmpty => 'المفضلة فارغة';

  @override
  String get wishlistEmptySubtitle => 'أضف منتجاتك المفضلة هنا';

  @override
  String get addToCartFromWishlist => 'تمت الإضافة للسلة';

  @override
  String get profileTitle => 'حسابي';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get myAddresses => 'عناويني';

  @override
  String get language => 'اللغة';

  @override
  String get about => 'عن التطبيق';

  @override
  String get terms => 'الشروط والأحكام';

  @override
  String get contactUs => 'تواصل معنا';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get logoutConfirm => 'هل أنت متأكد من تسجيل الخروج؟';

  @override
  String get logoutTitle => 'تسجيل الخروج';

  @override
  String get accountSection => 'الحساب';

  @override
  String get browseSection => 'التصفح';

  @override
  String get supportSection => 'الدعم';

  @override
  String get statsOrders => 'الطلبات';

  @override
  String get statsWishlist => 'المفضلة';

  @override
  String get statsCart => 'السلة';

  @override
  String get edit => 'تعديل';

  @override
  String get loginTitle => 'مرحباً بعودتك 👋';

  @override
  String get loginSubtitle => 'سجل دخولك لمتابعة التسوق';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get emailRequired => 'البريد الإلكتروني مطلوب';

  @override
  String get emailInvalid => 'البريد الإلكتروني غير صالح';

  @override
  String get password => 'كلمة المرور';

  @override
  String get passwordRequired => 'كلمة المرور مطلوبة';

  @override
  String get passwordMinLength => 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get or => 'أو';

  @override
  String get googleLogin => 'تسجيل الدخول عبر Google';

  @override
  String get continueWithGoogle => 'المتابعة عبر Google';

  @override
  String get orDivider => 'أو';

  @override
  String get googleSignInCancelled => 'تم إلغاء تسجيل الدخول بجوجل';

  @override
  String get phoneVerificationTitle => 'التحقق من رقم الهاتف';

  @override
  String phoneVerificationSubtitle(Object phone) {
    return 'لقد أرسلنا رمز تحقق إلى $phone';
  }

  @override
  String get phoneVerificationBackTitle => 'تأكيد الرجوع';

  @override
  String get phoneVerificationBackConfirm =>
      'هل أنت متأكد من الرجوع؟ سيتم إلغاء عملية التسجيل.';

  @override
  String get otpLabel => 'أدخل الرمز';

  @override
  String get otpHint => 'رمز مكون من 6 أرقام';

  @override
  String get verifyPhone => 'تحقق ومتابعة';

  @override
  String get resendCode => 'إعادة إرسال الرمز';

  @override
  String resendIn(Object seconds) {
    return 'أعد المحاولة بعد $seconds ثانية';
  }

  @override
  String get otpInvalid => 'يرجى إدخال الرمز كاملاً (6 أرقام)';

  @override
  String get phoneVerified => 'تم التحقق من رقم الهاتف بنجاح';

  @override
  String get noAccount => 'ليس لديك حساب؟ ';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get loginError => 'حدث خطأ أثناء تسجيل الدخول';

  @override
  String get emailNotRegistered => 'البريد الإلكتروني غير مسجل';

  @override
  String get wrongPassword => 'كلمة المرور غير صحيحة';

  @override
  String get tooManyAttempts => 'تم تجاوز عدد المحاولات. حاول لاحقاً';

  @override
  String get invalidCredentials => 'البريد الإلكتروني أو كلمة المرور غير صحيحة';

  @override
  String get networkError => 'تحقق من اتصالك بالإنترنت';

  @override
  String get registerTitle => 'إنشاء حساب جديد ✨';

  @override
  String get registerSubtitle => 'انضم إلينا واستمتع بتجربة تسوق فاخرة';

  @override
  String get firstName => 'الاسم الأول';

  @override
  String get lastName => 'اسم العائلة';

  @override
  String get firstNameRequired => 'الاسم الأول مطلوب';

  @override
  String get lastNameRequired => 'اسم العائلة مطلوب';

  @override
  String get fullNameRequired => 'الاسم مطلوب';

  @override
  String get fullNameShort => 'الاسم قصير جداً';

  @override
  String get phoneRequired => 'رقم الهاتف مطلوب';

  @override
  String get phoneInvalid => 'رقم الهاتف غير صالح';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get passwordMismatch => 'كلمة المرور غير متطابقة';

  @override
  String get agreeTerms => 'أوافق على الشروط والأحكام';

  @override
  String get agreeToTerms => 'أوافق على';

  @override
  String get separatorAnd => 'لـ';

  @override
  String get agreeRequired => 'يرجى الموافقة على الشروط والأحكام';

  @override
  String get register => 'إنشاء حساب';

  @override
  String get haveAccount => 'لديك حساب بالفعل؟ ';

  @override
  String get accountCreated => 'تم إنشاء الحساب بنجاح';

  @override
  String get emailInUse => 'البريد الإلكتروني مستخدم بالفعل';

  @override
  String get weakPassword => 'كلمة المرور ضعيفة جداً';

  @override
  String get forgotPasswordTitle => 'نسيت كلمة المرور؟';

  @override
  String get forgotPasswordSubtitle =>
      'أدخل بريدك الإلكتروني وسنرسل لك رابط إعادة تعيين كلمة المرور';

  @override
  String get sendResetLink => 'إرسال رابط إعادة التعيين';

  @override
  String get resetLinkSent => 'تم إرسال رابط إعادة التعيين';

  @override
  String get checkYourEmail =>
      'تحقق من بريدك الإلكتروني واتبع الرابط لإعادة تعيين كلمة المرور';

  @override
  String get passwordResetSuccess => 'تم إعادة تعيين كلمة المرور بنجاح';

  @override
  String get invalidEmail => 'يرجى إدخال بريد إلكتروني صالح';

  @override
  String get setNewPassword => 'تعيين كلمة مرور جديدة';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get passwordUpdated => 'تم تحديث كلمة المرور';

  @override
  String get sendOtp => 'إرسال رمز التحقق';

  @override
  String get verifyOtp => 'تحقق';

  @override
  String get winterSaleTitle => 'خصم الشتاء\nالخرافي';

  @override
  String get winterSaleSubtitle => 'حتى 50% خصم';

  @override
  String get appleDevicesTitle => 'أجهزة أبل\nالجديدة';

  @override
  String get appleDevicesSubtitle => 'تسوق الآن';

  @override
  String get categoryElectronics => 'إلكترونيات';

  @override
  String get categoryFashion => 'أزياء';

  @override
  String get categoryHome => 'المنزل';

  @override
  String get categoryPerfumes => 'عطور';

  @override
  String get categoryWatches => 'ساعات';

  @override
  String get categorySports => 'رياضة';

  @override
  String get bannerSecurity => 'أمان';

  @override
  String get bannerCamera => 'كاميرا';

  @override
  String get bannerPerformance => 'أداء';

  @override
  String get exclusiveCollection => 'مجموعة حصرية';

  @override
  String get seasonCollection => 'تشكيلة المناسبات\nالجديدة';

  @override
  String get infiniteElegance => 'أناقة لا متناهية...';

  @override
  String get moveWithDetails => 'تقدم بكل\nتفاصيلك';

  @override
  String get sectionByCategory => 'تسوق حسب القسم';

  @override
  String get sectionNewArrivals => 'جديد المتجر';

  @override
  String get sectionBestSellers => 'الأكثر مبيعاً';

  @override
  String get sectionExclusive => 'حصرية المتجر';

  @override
  String timeMonth(int count) {
    return 'منذ $count شهر';
  }

  @override
  String timeDay(int count) {
    return 'منذ $count يوم';
  }

  @override
  String timeHour(int count) {
    return 'منذ $count ساعة';
  }

  @override
  String get timeNow => 'الآن';

  @override
  String get defaultUserName => 'مستخدم';

  @override
  String get welcome => 'مرحباً';

  @override
  String get editProfileTitle => 'تعديل الملف الشخصي';

  @override
  String get underDevelopment => 'قيد التطوير';

  @override
  String get noNotifications => 'لا توجد إشعارات';

  @override
  String get myFavorites => 'قائمة المفضلة';

  @override
  String get removeFromList => 'إزالة من القائمة';

  @override
  String get addToCartSuccess => 'تمت إضافة المنتج إلى السلة';

  @override
  String get addToFavorites => 'تمت الإضافة للمفضلة';

  @override
  String get removeFromFavorites => 'تمت الإزالة من المفضلة';

  @override
  String get noFavorites => 'لا توجد منتجات في المفضلة';

  @override
  String loadErrorPrefix(String error) {
    return 'خطأ: $error';
  }

  @override
  String get label => 'تصنيف';

  @override
  String get street => 'الشارع';

  @override
  String get setDefault => 'تعيين كافتراضي';

  @override
  String get addAddress => 'إضافة عنوان';

  @override
  String get addressSaved => 'تم حفظ العنوان';

  @override
  String get deleteAddressConfirmMsg => 'هل أنت متأكد من حذف هذا العنوان؟';

  @override
  String get editProfileSuccess => 'تم حفظ الملف الشخصي';

  @override
  String get noConnection => 'لا يوجد اتصال بالإنترنت';

  @override
  String get noConnectionSubtitle =>
      'يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى';

  @override
  String get connectionRestored => 'تم استعادة الاتصال';

  @override
  String get saveAddressPrompt => 'هل تريد حفظ هذا العنوان؟';

  @override
  String get appInformation => 'معلومات التطبيق';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get returnPolicy => 'سياسة الإرجاع والاستبدال';

  @override
  String get appVersion => 'إصدار التطبيق';

  @override
  String get contactUsSection => 'اتصل بنا';

  @override
  String get keepInTouch => 'ابق على تواصل';

  @override
  String get dangerZone => 'منطقة الخطر';

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get addressLabel => 'العنوان';

  @override
  String get orderPending => 'قيد المعالجة';

  @override
  String get orderCancelled => 'ملغي';

  @override
  String get orderShipped => 'تم الشحن';

  @override
  String get orderDelivered => 'تم التوصيل';

  @override
  String get orderConfirmed => 'مؤكد';

  @override
  String get viewOrderDetail => 'عرض تفاصيل الطلب';

  @override
  String get goShopping => 'الذهاب للتسوق';

  @override
  String get orderedProducts => 'المنتجات المطلوبة';

  @override
  String get invoiceDetails => 'تفاصيل الفاتورة';

  @override
  String get orderNumberCopied => 'تم نسخ رقم الطلب';

  @override
  String get trackerSubtitle => 'تحديثات حالة الشحنة والطلب مباشرة';

  @override
  String get orderCancelledMessage =>
      'تم إلغاء هذا الطلب ولا يمكن تتبع مسار الشحن الخاص به.';

  @override
  String get deliveryLocation => 'موقع التوصيل الجغرافي';

  @override
  String get paymentMethod => 'طريقة الدفع';

  @override
  String get cashOnDelivery => 'الدفع عند الاستلام';

  @override
  String get creditCard => 'بطاقة ائتمان';

  @override
  String get orderStatusPending => 'تم الطلب';

  @override
  String get orderStatusConfirmed => 'مؤكد';

  @override
  String get orderStatusShipped => 'تم الشحن';

  @override
  String get orderStatusDelivered => 'تم التوصيل';

  @override
  String get orderStatusCancelled => 'ملغي';

  @override
  String get editPersonalInfo => 'المعلومات الشخصية';

  @override
  String get accountData => 'بيانات الحساب';

  @override
  String get nameHint => 'اسمك الكامل';

  @override
  String get leaveBlankHint => 'اتركه فارغاً إذا لم تريد تغييره';

  @override
  String get passwordMin6 => 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';

  @override
  String get retypePassword => 'أعد كتابة كلمة المرور';

  @override
  String phoneTooShort(Object max) {
    return 'رقم الهاتف قصير جداً (يجب أن يكون $max أرقام)';
  }

  @override
  String get countryCode => 'رمز الدولة';

  @override
  String get invalidEmailMessage => 'بريد إلكتروني غير صالح';

  @override
  String get noUserLoggedIn => 'لا يوجد مستخدم مسجل دخوله';

  @override
  String get emailVerificationSent =>
      'تم إرسال رابط التحقق إلى البريد الجديد. يرجى تأكيده.';

  @override
  String get changeEmailPasswordRequiresReLogin =>
      'لتغيير البريد أو كلمة المرور، يجب تسجيل الخروج وإعادة الدخول أولاً';

  @override
  String get emailAlreadyInUse => 'هذا البريد الإلكتروني مستخدم بالفعل';

  @override
  String get weakPasswordMessage =>
      'كلمة المرور ضعيفة، الرجاء اختيار كلمة مرور أقوى';

  @override
  String get unexpectedError => 'حدث خطأ غير متوقع';

  @override
  String get deliveryAddress => 'عنوان التوصيل';

  @override
  String get country => 'الدولة';

  @override
  String get governorate => 'المحافظة';

  @override
  String get regionGovernorate => 'المنطقة / المحافظة';

  @override
  String get addressDetails => 'العنوان بالتفصيل';

  @override
  String get selectCountry => 'اختر الدولة';

  @override
  String get selectRegionRequired => 'يرجى اختيار المنطقة / المحافظة';

  @override
  String get selectOption => 'يرجى تحديد الخيار';

  @override
  String get selectGovernorate => 'اختر المحافظة';

  @override
  String get selectRegionGovernorate => 'اختر المنطقة / المحافظة';

  @override
  String get addressRequired => 'حقل العنوان مطلوب';

  @override
  String get currentLocation => 'الموقع الحالي';

  @override
  String get locationInstruction =>
      'يمكنك الضغط على الخريطة لتغيير الموقع الجغرافي بدقة';

  @override
  String get saveAddress => 'حفظ العنوان';

  @override
  String get addressRequiredMsg => 'يرجى اختيار المنطقة / المحافظة';

  @override
  String get addressSavedSuccess => 'تم حفظ العنوان بنجاح';

  @override
  String errorOccurred(Object error) {
    return 'حدث خطأ: $error';
  }

  @override
  String get selectCountryCode => 'اختر رمز الدولة';

  @override
  String get permissionDenied => 'تم رفض إذن الوصول للموقع';

  @override
  String get permissionDeniedForever =>
      'إذن الموقع مرفوض نهائياً من إعدادات الهاتف';

  @override
  String get locationFailed => 'تعذر تحديد الموقع الحالي';

  @override
  String get emptyCartCheckout => 'سلة التسوق فارغة حالياً';

  @override
  String get shippingOption => 'خيار التوصيل';

  @override
  String get promoCode => 'رمز ترويجي / كوبون خصم';

  @override
  String get costSummary => 'ملخص التكلفة';

  @override
  String orderItems(Object count) {
    return 'المنتجات ($count)';
  }

  @override
  String get hideDetails => 'إخفاء التفاصيل';

  @override
  String get showDetails => 'عرض التفاصيل';

  @override
  String get standardDelivery => 'توصيل قياسي للمنزل';

  @override
  String get freeShippingDesc => 'توصيل مجاني لطلباتك فوق 500 د.ك';

  @override
  String get paidShippingDesc => 'توصيل مضمون ومغلف بعناية خلال 2-3 أيام عمل';

  @override
  String get couponHint => 'أدخل كود الخصم (مثال: GOLD10)';

  @override
  String get apply => 'تطبيق';

  @override
  String get applied => 'تم التطبيق';

  @override
  String appliedPromoCode(Object code) {
    return 'كود الخصم المطبق: $code';
  }

  @override
  String get cancelCode => 'إلغاء الكود';

  @override
  String get noAddress => 'لا يوجد عنوان توصيل محفوظ حالياً';

  @override
  String get paymentUnavailable => 'طريقة الدفع هذه غير متوفرة بعد';

  @override
  String get noAddressWarning => 'يرجى إضافة عنوان للتوصيل أولاً';

  @override
  String get quantityUnavailable => 'الكمية المطلوبة غير متوفرة لبعض المنتجات';

  @override
  String get cardPaymentComingSoon =>
      'بوابة الدفع الإلكتروني ستكون متوفرة قريباً';

  @override
  String get walletComingSoon =>
      'الدفع بواسطة المحافظ الرقمية سيكون متوفراً قريباً';

  @override
  String get couponDiscount => 'خصم الكوبون';

  @override
  String get shippingCost => 'تكلفة التوصيل';

  @override
  String get confirmAndOrder => 'تأكيد وإتمام الطلب';

  @override
  String get checkoutUnavailable => 'طريقة الدفع هذه غير متوفرة بعد';

  @override
  String get editAddressLabel => 'تعديل العنوان 📍';

  @override
  String get termsAndConditions => 'الشروط والأحكام';

  @override
  String get privacyPolicyContent =>
      'نحن نلتزم بحماية خصوصيتك وأمان بياناتك الشخصية. يتم جمع البيانات فقط لتحسين تجربتك داخل التطبيق وتسهيل معالجة طلباتك وتوصيلها بأمان.';

  @override
  String get termsContent =>
      'باستخدامك لهذا التطبيق، فإنك توافق على شروط الخدمة الخاصة بنا. جميع المنتجات والمعروضات تخضع للتوفر والأسعار الموضحة بالدينار الكويتي KWD.';

  @override
  String get returnPolicyContent =>
      'يمكنك طلب إرجاع أو استبدال المنتجات المؤهلة خلال 14 يوماً من تاريخ الاستلام، بشرط أن تكون في حالتها الأصلية وغلافها غير المفتوح.';

  @override
  String get customerServiceCall => 'خدمة العملاء (اتصال)';

  @override
  String get emailSupport => 'الدعم الفني عبر البريد';

  @override
  String get backToLogin => 'العودة لتسجيل الدخول';

  @override
  String get close => 'إغلاق';

  @override
  String get welcomeUser => 'مرحباً،';

  @override
  String get deleteAccountTitle => 'حذف الحساب';

  @override
  String get deleteAccountConfirm =>
      'هل أنت متأكد من رغبتك في حذف حسابك نهائياً؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get deleteAccountSecurity =>
      'يرجى تسجيل الخروج وإعادة الدخول لحذف الحساب لأسباب أمنية.';

  @override
  String get deleteLabel => 'حذف';

  @override
  String get firstReview => 'أضف أول تقييم';

  @override
  String get noReviews => 'لا توجد تقييمات بعد';

  @override
  String get outOfStock => 'نفذت الكمية';

  @override
  String stockWarning(Object count) {
    return '⚠ باقي $count قطع فقط';
  }

  @override
  String get comingSoon => 'قريباً';

  @override
  String andOtherProducts(Object count) {
    return 'و $count منتجات أخرى';
  }

  @override
  String productCount(Object count) {
    return 'عدد المنتجات: $count';
  }

  @override
  String get orderDetails => 'عرض تفاصيل الطلب';

  @override
  String get noOrders => 'لا توجد طلبات';

  @override
  String get noOrdersDesc => 'لم تقم بإجراء أي طلبات في هذا القسم بعد';

  @override
  String promoSuccess(int percent) {
    return 'تم تطبيق كود الخصم ($percent%) بنجاح';
  }

  @override
  String get invalidCoupon => 'كود الخصم غير صالح أو منتهي الصلاحية';

  @override
  String get outOfStockItems =>
      'يوجد منتجات نفذت من المخزن، يرجى إزالتها أولاً';

  @override
  String get insufficientStock => 'الكمية المطلوبة غير متوفرة لبعض المنتجات';

  @override
  String get cardUnavailable => 'بوابة الدفع الإلكتروني ستكون متوفرة قريباً';

  @override
  String get walletUnavailable =>
      'الدفع بواسطة المحافظ الرقمية سيكون متوفراً قريباً';

  @override
  String get pleaseAddAddress => 'يرجى إضافة عنوان للتوصيل أولاً';

  @override
  String itemQuantity(Object count) {
    return 'الكمية: $count';
  }

  @override
  String get product => 'منتج';

  @override
  String get appInfo => 'معلومات التطبيق';

  @override
  String get digitalWallet => 'المحفظة الرقمية';

  @override
  String get paymentMethodCodSubtitle => 'ادفع عند استلام طلبك';

  @override
  String get noProductsInSection => 'لا توجد منتجات في هذا القسم';

  @override
  String get exitTitle => 'تأكيد الخروج';

  @override
  String get exitConfirm => 'هل أنت متأكد من الخروج من التطبيق؟';
}
