import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:elct/core/router/routes.dart';
import 'package:elct/features/auth/presentation/providers/auth_provider.dart';
import 'package:elct/core/providers/pending_redirect_provider.dart';
import 'package:elct/features/splash/presentation/screens/splash_screen.dart';

import 'package:elct/features/auth/presentation/screens/login_screen.dart';
import 'package:elct/features/auth/presentation/screens/phone_login_screen.dart';
import 'package:elct/features/auth/presentation/screens/complete_profile_screen.dart';
import 'package:elct/features/auth/presentation/screens/register_screen.dart';
import 'package:elct/features/auth/presentation/screens/phone_verification_screen.dart';
import 'package:elct/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:elct/features/auth/presentation/screens/reset_password_phone_screen.dart';
import 'package:elct/features/auth/presentation/screens/reset_password_otp_screen.dart';
import 'package:elct/features/home/presentation/screens/home_screen.dart';
import 'package:elct/features/categories/presentation/screens/categories_screen.dart';
import 'package:elct/features/wishlist/presentation/screens/wishlist_screen.dart';
import 'package:elct/features/cart/presentation/providers/cart_provider.dart';
import 'package:elct/features/cart/presentation/screens/cart_screen.dart';
import 'package:elct/features/profile/presentation/screens/profile_screen.dart';
import 'package:elct/features/product_detail/presentation/screens/product_detail_screen.dart';
import 'package:elct/features/search/presentation/screens/search_screen.dart';
import 'package:elct/features/checkout/presentation/screens/checkout_screen.dart';
import 'package:elct/features/checkout/presentation/screens/order_success_screen.dart';
import 'package:elct/features/orders/presentation/screens/orders_screen.dart';
import 'package:elct/features/orders/presentation/screens/order_detail_screen.dart';
import 'package:elct/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:elct/features/profile/presentation/screens/addresses_screen.dart';
import 'package:elct/features/campaign/presentation/screens/campaign_screen.dart';
import 'package:elct/core/widgets/app_shell.dart';
import 'package:elct/core/providers/app_settings_provider.dart';
import 'package:elct/core/services/notification_service.dart';

final _protectedRoutes = <String>{
  Routes.checkout,
  Routes.wishlist,
  Routes.orders,
  Routes.editProfile,
  Routes.addresses,
  Routes.orderSuccess,
  Routes.profile,
};

final _tabBranches = [
  StatefulShellBranch(
    routes: [
      GoRoute(
        path: Routes.home,
        pageBuilder: (c, s) => buildNoTransitionPage(child: const HomeScreen()),
      ),
    ],
  ),
  StatefulShellBranch(
    routes: [
      GoRoute(
        path: Routes.categories,
        pageBuilder: (c, s) => buildNoTransitionPage(child: const CategoriesScreen()),
      ),
    ],
  ),
  StatefulShellBranch(
    routes: [
      GoRoute(
        path: Routes.wishlist,
        pageBuilder: (c, s) => buildNoTransitionPage(child: const WishlistScreen()),
      ),
    ],
  ),
  StatefulShellBranch(
    routes: [
      GoRoute(
        path: Routes.cart,
        pageBuilder: (c, s) => buildNoTransitionPage(child: const CartScreen()),
      ),
    ],
  ),
  StatefulShellBranch(
    routes: [
      GoRoute(
        path: Routes.profile,
        pageBuilder: (c, s) => buildNoTransitionPage(child: const ProfileScreen()),
      ),
    ],
  ),
];

final routerProvider = Provider<GoRouter>((ref) {
  final goRouter = GoRouter(
    initialLocation: Routes.splash,
    debugLogDiagnostics: false,
    observers: [
      FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
    ],
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final user = authState.valueOrNull;
      final isLoggedIn = user != null;
      final location = state.matchedLocation;

      // Never block the splash screen — it handles its own navigation
      if (location == Routes.splash) return null;

      final isProtected = _protectedRoutes.any((r) => location == r || location.startsWith('$r/'));
      if (!isLoggedIn && isProtected) {
        return '${Routes.login}?redirect=${Uri.encodeComponent(location)}';
      }

      final isAuthRoute = location.startsWith('/auth');
      if (isLoggedIn && location == Routes.phoneVerification) return null;
      if (isLoggedIn && isAuthRoute) {
        final pending = ref.read(pendingRedirectProvider);
        if (pending != null) {
          ref.read(pendingRedirectProvider.notifier).state = null;
          return pending;
        }
        final redirectTo = state.uri.queryParameters['redirect'];
        return (Routes.isSafeRedirect(redirectTo)) ? redirectTo! : Routes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: Routes.splash,
        pageBuilder: (c, s) => buildPageWithFade(child: const SplashScreen()),
      ),
      GoRoute(
        path: Routes.login,
        pageBuilder: (c, s) => buildPageWithFade(child: const LoginScreen()),
      ),
      GoRoute(
        path: Routes.phoneLogin,
        pageBuilder: (c, s) => buildPageWithSlide(child: const PhoneLoginScreen()),
      ),
      GoRoute(
        path: Routes.completeProfile,
        pageBuilder: (c, s) {
          final phone = s.extra as String? ?? '';
          return buildPageWithSlide(child: CompleteProfileScreen(phoneNumber: phone));
        },
      ),
      GoRoute(
        path: Routes.register,
        pageBuilder: (c, s) =>
            buildPageWithSlide(child: const RegisterScreen()),
      ),
      GoRoute(
        path: Routes.forgotPassword,
        pageBuilder: (c, s) =>
            buildPageWithSlide(child: const ForgotPasswordScreen()),
      ),
      GoRoute(
        path: Routes.resetPasswordPhone,
        pageBuilder: (c, s) =>
            buildPageWithSlide(child: const ResetPasswordPhoneScreen()),
      ),
      GoRoute(
        path: Routes.resetPasswordOtp,
        pageBuilder: (c, s) {
          final extra = s.extra as Map<String, dynamic>? ?? {};
          return buildPageWithSlide(
            child: ResetPasswordOtpScreen(
              verificationId: extra['verificationId'] as String? ?? '',
              phone: extra['phone'] as String? ?? '',
            ),
          );
        },
      ),
      GoRoute(
        path: Routes.phoneVerification,
        pageBuilder: (c, s) => buildPageWithSlide(
          child: PhoneVerificationScreen(phoneNumber: s.extra as String?),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return Consumer(builder: (context, ref, _) {
            final userId = ref.watch(currentUserIdProvider);
            final cartCount = ref.watch(cartCountProvider);
            final settingsAsync = ref.watch(appSettingsProvider);
            final whatsapp = settingsAsync.valueOrNull?.whatsapp ?? '';
            
            return AppShell(
              navigationShell: navigationShell,
              isLoggedIn: userId != null,
              cartCount: cartCount,
              whatsappNumber: whatsapp,
            );
          });
        },
        branches: _tabBranches,
      ),
      GoRoute(
        path: '${Routes.products}/:id',
        pageBuilder: (c, s) => buildPageWithSlide(
          child:
              ProductDetailScreen(productId: s.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: Routes.search,
        pageBuilder: (c, s) =>
            buildPageWithFade(child: const SearchScreen()),
      ),
      GoRoute(
        path: Routes.checkout,
        pageBuilder: (c, s) =>
            buildPageWithSlide(child: const CheckoutScreen()),
      ),
      GoRoute(
        path: '${Routes.orderSuccess}/:orderId',
        pageBuilder: (c, s) => buildPageWithScale(
          child: OrderSuccessScreen(
              orderId: s.pathParameters['orderId']!),
        ),
      ),
      GoRoute(
        path: Routes.orders,
        pageBuilder: (c, s) =>
            buildPageWithSlide(child: const OrdersScreen()),
      ),
      GoRoute(
        path: '${Routes.orders}/:orderId',
        pageBuilder: (c, s) => buildPageWithSlide(
          child: OrderDetailScreen(
              orderId: s.pathParameters['orderId']!),
        ),
      ),
      GoRoute(
        path: Routes.editProfile,
        pageBuilder: (c, s) =>
            buildPageWithSlide(child: const EditProfileScreen()),
      ),
      GoRoute(
        path: Routes.addresses,
        pageBuilder: (c, s) =>
            buildPageWithSlide(child: const AddressesScreen()),
      ),
      GoRoute(
        path: '${Routes.campaign}/:bannerId',
        pageBuilder: (c, s) => buildPageWithSlide(
          child: CampaignScreen(bannerId: s.pathParameters['bannerId']!),
        ),
      ),
    ],
  );

  NotificationService.instance.setRouter = goRouter;
  
  WidgetsBinding.instance.addPostFrameCallback((_) {
    NotificationService.instance.handlePendingNavigation();
  });

  ref.listen(authStateProvider, (prev, next) {
    final prevUid = prev?.valueOrNull?.uid;
    final nextUid = next.valueOrNull?.uid;
    if (prevUid != nextUid) {
      goRouter.refresh();
    }
  });

  return goRouter;
});

CustomTransitionPage buildPageWithFade({required Widget child}) =>
    CustomTransitionPage(
      child: child,
      transitionsBuilder: (c, anim, secondaryAnim, child) =>
          FadeTransition(opacity: anim, child: child),
    );

CustomTransitionPage buildPageWithSlide({required Widget child}) =>
    CustomTransitionPage(
      child: child,
      transitionDuration: const Duration(milliseconds: 350),
      transitionsBuilder: (c, anim, secondaryAnim, child) {
        final tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeInOutCubic));
        return SlideTransition(position: anim.drive(tween), child: child);
      },
    );

CustomTransitionPage buildPageWithScale({required Widget child}) =>
    CustomTransitionPage(
      child: child,
      transitionsBuilder: (c, anim, secondaryAnim, child) =>
          ScaleTransition(
        scale: Tween(begin: 0.9, end: 1.0)
            .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutBack)),
        child: FadeTransition(opacity: anim, child: child),
      ),
    );

NoTransitionPage buildNoTransitionPage({required Widget child}) =>
    NoTransitionPage(child: child);
