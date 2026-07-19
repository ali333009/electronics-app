import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'core/utils/log.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'l10n/app_localizations.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'app_router.dart';
import 'core/firebase/firestore_config.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/currency_provider.dart';
import 'core/services/notification_service.dart';
import 'core/widgets/app_lifecycle_observer.dart';
import 'core/widgets/connectivity_banner.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // firebase_crashlytics is NOT supported on web — guard every call
  if (!kIsWeb) {
    FlutterError.onError = (details) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
      FlutterError.presentError(details);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    runZonedGuarded(
      () async { await _runApp(); },
      (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      },
    );
  } else {
    // On web: run directly — no Crashlytics, no zone guard
    await _runApp();
  }
}

Future<void> _runApp() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  try {
    if (kIsWeb) {
      await FirebaseAppCheck.instance.activate(
        providerWeb: ReCaptchaV3Provider('6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI'),
      );
    } else {
      await FirebaseAppCheck.instance.activate(
        providerAndroid: kDebugMode
            ? AndroidDebugProvider()
            : AndroidPlayIntegrityProvider(),
        providerApple: kDebugMode
            ? AppleDebugProvider()
            : AppleAppAttestProvider(),
      );
    }
  } catch (e) {
    logDebug('[Main] AppCheck activation failed: $e');
  }

  await configureFirestore();

  // SystemChrome APIs are not available on web
  if (!kIsWeb) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF1A1A1A),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  final container = ProviderContainer();
  await container.read(localeProvider.notifier).init();
  await container.read(currencyProvider.notifier).init();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const ElectronicApp(),
    ),
  );

  unawaited(_initializeOnlineServices());
}

Future<void> _initializeOnlineServices() async {
  try {
    await GoogleSignIn.instance.initialize();
  } catch (e) {
    logDebug('[Main] GoogleSignIn init failed: $e');
  }

  // firebase_crashlytics is NOT supported on web
  if (!kIsWeb) {
    FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);
  }

  try {
    await FirebaseAnalytics.instance.logAppOpen();
  } catch (e) {
    logDebug('[Main] Analytics logAppOpen failed: $e');
  }

  try {
    await NotificationService.instance.initialize();
  } catch (e) {
    logDebug('[Main] Notification init failed: $e');
  }
}

/// iOS-style bouncing scroll physics for all platforms.
class _AppScrollBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
}

class ElectronicApp extends ConsumerWidget {
  const ElectronicApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);

    final isRtl = locale.languageCode == 'ar';

    return MaterialApp.router(
      title: 'Electronic',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      scrollBehavior: _AppScrollBehavior(),
      builder: (context, child) {
        // Clamp textScaleFactor to [0.85, 1.1] so iOS "Large Text"
        // accessibility setting doesn't break the layout.
        final mq = MediaQuery.of(context);
        final safeMq = mq.copyWith(
          textScaler: TextScaler.linear(
            mq.textScaler.scale(1.0).clamp(0.85, 1.1),
          ),
        );
        return MediaQuery(
          data: safeMq,
          child: Directionality(
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            child: Stack(
              children: [
                AppLifecycleObserver(child: child ?? const SizedBox.shrink()),
                const ConnectivityBanner(),
              ],
            ),
          ),
        );
      },
    );
  }
}
