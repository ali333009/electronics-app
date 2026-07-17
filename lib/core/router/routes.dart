class Routes {
  static const String splash = '/splash';
  static const String login = '/auth/login';
  static const String phoneLogin = '/auth/phone-login';
  static const String completeProfile = '/auth/complete-profile';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPasswordPhone = '/auth/reset-password-phone';
  static const String resetPasswordOtp = '/auth/reset-password-otp';
  static const String home = '/home';
  static const String categories = '/categories';
  static const String products = '/products';
  static const String search = '/search';
  static const String wishlist = '/wishlist';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderSuccess = '/order-success';
  static const String orders = '/orders';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String addresses = '/profile/addresses';
  static const String campaign = '/campaign';
  static const String phoneVerification = '/phone-verification';

  /// Returns `true` if [redirect] is an internal path safe for post-login redirect.
  static bool isSafeRedirect(String? redirect) {
    if (redirect == null || redirect.isEmpty) return false;
    if (redirect.contains('://')) return false;
    if (!redirect.startsWith('/')) return false;
    if (redirect.startsWith('/auth/')) return false;
    return true;
  }
}
