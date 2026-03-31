import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  static NotificationService get instance => _instance;

  NotificationService._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize Firebase Messaging and Local Notifications
  Future<void> initialize({String? userToken}) async {
    if (_initialized) return;

    try {
      // Request permission for iOS
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      debugPrint('📱 Notification permission: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // Initialize local notifications
        await _initializeLocalNotifications();

        // Get FCM token
        final token = await _firebaseMessaging.getToken();
        debugPrint('📱 FCM Token: $token');

        // Send token to backend if user is logged in
        if (token != null && userToken != null) {
          await _sendTokenToBackend(token, userToken);
        }

        // Listen for token refresh
        _firebaseMessaging.onTokenRefresh.listen((newToken) {
          debugPrint('📱 FCM Token refreshed: $newToken');
          if (userToken != null) {
            _sendTokenToBackend(newToken, userToken);
          }
        });

        // Subscribe to 'farmers' topic for broadcast notifications from admin
        await _firebaseMessaging.subscribeToTopic('farmers');
        debugPrint('📱 Subscribed to "farmers" topic');

        // Also subscribe to 'all' topic for general broadcasts
        await _firebaseMessaging.subscribeToTopic('all');
        debugPrint('📱 Subscribed to "all" topic');

        // Handle foreground messages
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

        // Handle background messages
        FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

        // Handle notification when app is opened from terminated state
        final initialMessage = await _firebaseMessaging.getInitialMessage();
        if (initialMessage != null) {
          _handleMessageOpenedApp(initialMessage);
        }

        _initialized = true;
        debugPrint('✅ Notification service initialized');
      } else {
        debugPrint('⚠️ Notification permission denied');
      }
    } catch (e) {
      debugPrint('❌ Error initializing notifications: $e');
    }
  }

  /// Initialize local notifications for foreground display
  Future<void> _initializeLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    const androidChannel = AndroidNotificationChannel(
      'pashu_mitra_channel',
      'Pashu Mitra Notifications',
      description: 'Notifications for Pashu Mitra app',
      importance: Importance.high,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  /// Handle foreground messages (show local notification)
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('📱 Foreground message received: ${message.messageId}');
    debugPrint('📱 Title: ${message.notification?.title}');
    debugPrint('📱 Body: ${message.notification?.body}');
    debugPrint('📱 Data: ${message.data}');

    // Show local notification when app is in foreground
    _showLocalNotification(message);
  }

  /// Handle notification tap (when app is in background or terminated)
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('📱 Notification tapped: ${message.messageId}');
    debugPrint('📱 Data: ${message.data}');

    // Handle navigation based on notification data
    _handleNotificationNavigation(message.data);
  }

  /// Handle notification tap from local notification
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('📱 Local notification tapped: ${response.payload}');

    // Parse payload and navigate
    if (response.payload != null) {
      // You can pass data as JSON string in payload
      _handleNotificationNavigation({'route': response.payload});
    }
  }

  /// Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      'pashu_mitra_channel',
      'Pashu Mitra Notifications',
      channelDescription: 'Notifications for Pashu Mitra app',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
      details,
      payload: message.data['route']?.toString(),
    );
  }

  /// Handle navigation based on notification data
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    // Implement navigation logic based on notification data
    // Example: navigate to specific screen based on 'route' or 'type' field

    final route = data['route'] as String?;
    final type = data['type'] as String?;

    debugPrint('📱 Navigation data - route: $route, type: $type');

    // You can use a navigation service or global navigator key to navigate
    // For now, just log the navigation intent
    if (route != null) {
      debugPrint('📱 Should navigate to: $route');
    }
  }

  /// Get FCM token
  Future<String?> getToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      debugPrint('❌ Error getting FCM token: $e');
      return null;
    }
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('📱 Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('❌ Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('📱 Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('❌ Error unsubscribing from topic: $e');
    }
  }

  /// Send FCM token to backend
  Future<void> _sendTokenToBackend(String fcmToken, String jwtToken) async {
    try {
      // Import dio for API calls
      final dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $jwtToken';
      dio.options.headers['Content-Type'] = 'application/json; charset=utf-8';

      await dio.put(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.profile}',
        data: {'fcmToken': fcmToken},
      );

      debugPrint('✅ FCM token sent to backend');
    } catch (e) {
      debugPrint('❌ Error sending FCM token to backend: $e');
    }
  }

  /// Send FCM token to backend (public method for manual calls)
  Future<void> sendTokenToBackend(
      String token, Function(String) apiCall) async {
    try {
      await apiCall(token);
      debugPrint('✅ FCM token sent to backend');
    } catch (e) {
      debugPrint('❌ Error sending token to backend: $e');
    }
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('📱 Background message received: ${message.messageId}');
  debugPrint('📱 Title: ${message.notification?.title}');
  debugPrint('📱 Body: ${message.notification?.body}');
}
