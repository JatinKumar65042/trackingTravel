import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // ✅ Request notification permissions
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      print("❌ User declined notifications");
      return;
    }

    // ✅ Get FCM token
    String? token = await _firebaseMessaging.getToken();
    print("📌 FCM Token: $token");

    // ✅ Initialize local notifications
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initSettings = InitializationSettings(android: androidSettings);

    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload == 'start_navigation') {
          Get.toNamed('/location'); // ✅ Redirect to /location only for movement notifications
        }
      },
    );

    // ✅ Foreground notification handling (FCM)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("📩 Received foreground notification: ${message.notification?.title}");
      _showLocalNotification(message);
    });

    // ✅ Handle background & terminated state notifications
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("🚀 Opened notification: ${message.notification?.title}");
      if (message.data['type'] == 'movement') {
        Get.toNamed('/location'); // ✅ Redirect only if it's a movement notification
      }
    });
  }

  /// ✅ Show a manual local notification
  static Future<void> showNotification({
    required String title,
    required String body,
    String? type, // Optional type to differentiate notifications
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'channel_id',
      'General Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      title,
      body,
      platformDetails,
      payload: type, // ✅ Set type for handling click behavior
    );
  }

  /// ✅ Show notification from an incoming Firebase message
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    if (message.notification == null) return;

    String? type = message.data['type']; // Get type from message

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'channel_id',
      'Push Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.show(
      0,
      message.notification!.title ?? "Notification",
      message.notification!.body ?? "You have a new message",
      platformDetails,
      payload: type, // ✅ Set type for handling click behavior
    );
  }
}