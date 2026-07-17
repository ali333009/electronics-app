import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../core/utils/log.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

/// Background message handler — must be a top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  logDebug('[FCM] Background message: ${message.messageId}');
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  // FirebaseMessaging is not supported on web — guard with kIsWeb
  final FirebaseMessaging? _fcm = kIsWeb ? null : FirebaseMessaging.instance;
  // flutter_local_notifications has no web support
  final FlutterLocalNotificationsPlugin? _localNotifications =
      kIsWeb ? null : FlutterLocalNotificationsPlugin();
  GoRouter? _router;
  Map<String, dynamic>? pendingInitialMessage;

  static const _channelId = 'high_importance_channel';
  static const _channelName = 'إشعارات التطبيق';
  static const _channelDesc = 'إشعارات العروض والطلبات';

  /// Call once in main() before runApp
  Future<void> initialize() async {
    // Web: push notifications not supported in this app
    if (kIsWeb || _fcm == null) return;

    // 1. Register background handler (not supported on Web)
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 2. Request permission moved to onUserLogin() to avoid prompt on fresh install

    // 3. Setup local notifications channel (Android)
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.high,
      playSound: true,
    );

    await _localNotifications
        ?.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    // 4. Init local notifications plugin
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _localNotifications?.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // iOS: allow foreground notifications to display
    await _localNotifications
        ?.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    // 5. Handle foreground messages → show local notification
    FirebaseMessaging.onMessage.listen(_showLocalNotification);

    // 6. Handle notification tap when app is in background (not terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      logDebug('[FCM] Opened from background: ${message.data}');
      _handleNotificationNavigation(message.data);
    });

    // 6b. Handle notification tap when app was terminated
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      logDebug('[FCM] App opened from terminated via notification: ${initialMessage.data}');
      pendingInitialMessage = initialMessage.data;
    }

    // 7. Save FCM token to Firestore for the current user
    await _saveTokenToFirestore();

    // 8. Refresh token when it changes
    _fcm.onTokenRefresh.listen((token) {
      _updateTokenInFirestore(token);
    });

    logDebug('[FCM] NotificationService initialized ✅');
  }

  /// Show a local notification when app is in foreground
  void _showLocalNotification(RemoteMessage message) {
    if (kIsWeb || _localNotifications == null) return;

    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          styleInformation: notification.body != null
              ? BigTextStyleInformation(notification.body!)
              : null,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    if (_router == null || response.payload == null) return;
    try {
      if (response.payload == null) return;
      final data = jsonDecode(response.payload!) as Map<String, dynamic>;
      _handleNotificationNavigation(data);
    } catch (_) {
      logDebug('[FCM] Failed to parse notification payload');
    }
  }

  /// Navigate based on notification data payload (works for all FCM states)
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    if (_router == null) return;
    final type = data['type'] as String?;
    final id = data['id'] as String?;
    logDebug('[FCM] Navigating → type=$type, id=$id');
    switch (type) {
      case 'order':
        if (id != null && id.isNotEmpty) {
          if (_router != null) _router!.push('/orders/$id');
        } else {
          if (_router != null) _router!.push('/orders');
        }
        break;
      case 'product':
        if (id != null && id.isNotEmpty) {
          if (_router != null) _router!.push('/products/$id');
        } else {
          if (_router != null) _router!.push('/products');
        }
        break;
      case 'campaign':
        if (id != null && id.isNotEmpty) {
          if (_router != null) _router!.push('/campaign/$id');
        }
        break;
      default:
        if (_router != null) _router!.go('/');
    }
  }

  /// Called by the router once it is fully initialized to process any pending terminated deep links
  void handlePendingNavigation() {
    if (pendingInitialMessage != null) {
      _handleNotificationNavigation(pendingInitialMessage!);
      pendingInitialMessage = null;
    }
  }

  /// Save FCM token to Firestore under users/{uid}/fcmToken
  Future<void> _saveTokenToFirestore() async {
    if (_fcm == null) return;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Force a fresh token to avoid stale/invalid tokens
      await _fcm.deleteToken();
      final token = await _fcm.getToken();
      if (token == null) return;

      // Use set+merge so it works even if fcmToken field doesn't exist yet
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(
            {'fcmToken': token, 'fcmUpdatedAt': FieldValue.serverTimestamp()},
            SetOptions(merge: true),
          );
      logDebug('[FCM] Token saved successfully: ${token.substring(0, 20)}...');
    } catch (e) {
      logDebug('[FCM] Token save error: $e');
    }
  }

  Future<void> _updateTokenInFirestore(String token) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(
            {'fcmToken': token, 'fcmUpdatedAt': FieldValue.serverTimestamp()},
            SetOptions(merge: true),
          );
      logDebug('[FCM] Token refreshed in Firestore');
    } catch (e) {
      logDebug('[FCM] Token update error: $e');
    }
  }

  /// Call after login to save the token for the newly logged-in user
  Future<void> onUserLogin() async {
    if (kIsWeb || _fcm == null) return;
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );
    logDebug('[FCM] Permission on login: ${settings.authorizationStatus}');
    await _saveTokenToFirestore();
    // Subscribe to 'all' topic to receive broadcast notifications from admin
    await _fcm.subscribeToTopic('all');
    logDebug('[FCM] Subscribed to topic: all');
  }

  /// Call after logout to remove the token
  Future<void> onUserLogout() async {
    if (kIsWeb || _fcm == null) return;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      // Unsubscribe from 'all' topic to stop receiving notifications
      await _fcm.unsubscribeFromTopic('all');
      logDebug('[FCM] Unsubscribed from topic: all');
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'fcmToken': FieldValue.delete()});
      await _fcm.deleteToken();
    } catch (e) {
      logDebug('[FCM] Token delete error: $e');
    }
  }

  /// Set the GoRouter instance for navigation
  set setRouter(GoRouter router) => _router = router;

  /// Get current device FCM token (useful for admin dashboard)
  Future<String?> getToken() async {
    if (kIsWeb || _fcm == null) return null;
    return _fcm.getToken();
  }
}
