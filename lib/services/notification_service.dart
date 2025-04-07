import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';

// Define a top-level function to handle background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    // Need to initialize Firebase for background handlers
    await Firebase.initializeApp();
    print("✅ Firebase initialized successfully in background handler");
    if (message != null) {
      print("📩 Handling background message - ID: ${message.messageId}");
      print("📝 Message data: ${message.data}");
      print("🔔 Notification: ${message.notification?.title}");
    }
  } catch (e) {
    print("❌ Error in background message handler: $e");
  }
  // We can't navigate here since the app is in the background
  // The navigation will happen when the user taps on the notification
}

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // Create notification channels for Android
    if (GetPlatform.isAndroid) {
      // Create location tracking channel
      const AndroidNotificationChannel locationChannel =
          AndroidNotificationChannel(
            'location_tracking_channel',
            'Location Tracking',
            description: 'Notifications related to your location and movement',
            importance: Importance.max,
            enableVibration: true,
            enableLights: true,
            playSound: true,
            showBadge: true,
            ledColor: const Color.fromARGB(255, 255, 69, 0),
          );

      // Create general notifications channel
      const AndroidNotificationChannel generalChannel =
          AndroidNotificationChannel(
            'general_channel',
            'General Notifications',
            description: 'Important updates and general app notifications',
            importance: Importance.high,
            enableVibration: true,
            enableLights: true,
            playSound: true,
            showBadge: true,
          );

      // Register the channels with the system
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(locationChannel);

      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(generalChannel);
    }

    // ✅ Request notification permissions
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      criticalAlert: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      print("❌ User declined notifications");
      return;
    }

    // Print authorization status for debugging
    print(
      "🔔 Notification authorization status: ${settings.authorizationStatus}",
    );

    // ✅ Get FCM token
    String? token = await _firebaseMessaging.getToken();
    print("📌 FCM Token: $token");

    // ✅ Initialize local notifications
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        try {
          if (response.payload == 'start_navigation') {
            // Navigate to the location page when notification is clicked
            Get.toNamed('/location', arguments: {'from_notification': true});
            print('🗺️ Navigating to location page from notification');
          } else if (response.payload == 'destination_reached') {
            Get.toNamed('/journey_summary');
            print('📊 Navigating to journey summary from notification');
          } else {
            print('⚠️ Unknown notification type: ${response.payload}');
          }
        } catch (e) {
          print('❌ Error handling notification click: $e');
          // Fallback navigation to home page
          Get.toNamed('/');
        }
      },
    );

    // ✅ Foreground notification handling (FCM)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(
        "📩 Received foreground notification: ${message.notification?.title}",
      );
      _showLocalNotification(message);
    });

    // ✅ Handle background & terminated state notifications
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      try {
        print("🚀 Opened notification: ${message.notification?.title}");
        final String? type = message.data['type'];

        switch (type) {
          case 'movement':
          case 'start_navigation':
            Get.toNamed('/location', arguments: {'from_notification': true});
            print('🗺️ Navigating to location page from FCM notification');
            break;
          case 'destination_reached':
            Get.toNamed('/journey_summary');
            print('📊 Navigating to journey summary from FCM notification');
            break;
          default:
            print('⚠️ Unknown FCM notification type: $type');
            Get.toNamed('/');
        }
      } catch (e) {
        print('❌ Error handling FCM notification click: $e');
        // Fallback navigation to home page
        Get.toNamed('/');
      }
    });

    // Set up background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  /// ✅ Show a manual local notification
  static Future<void> showNotification({
    required String title,
    required String body,
    String? type, // Optional type to differentiate notifications
  }) async {
    try {
      // Use different notification channels based on notification type
      final AndroidNotificationDetails androidDetails;

      // Generate a unique notification ID based on current time
      final int notificationId = DateTime.now().millisecondsSinceEpoch
          .remainder(100000);

      // Use location tracking channel for location-related notifications
      if (type == 'start_navigation' || type == 'destination_reached') {
        androidDetails = const AndroidNotificationDetails(
          'location_tracking_channel',
          'Location Tracking',
          importance: Importance.high,
          priority: Priority.high,
          enableVibration: true,
          enableLights: true,
          playSound: true,
          icon: '@mipmap/ic_launcher',
          channelShowBadge: true,
        );
      } else {
        // Use general channel for other notifications
        androidDetails = const AndroidNotificationDetails(
          'general_channel',
          'General Notifications',
          importance: Importance.high,
          priority: Priority.high,
          enableVibration: true,
          enableLights: true,
          playSound: true,
          icon: '@mipmap/ic_launcher',
          channelShowBadge: true,
        );
      }

      final NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
      );

      try {
        await _flutterLocalNotificationsPlugin.show(
          notificationId, // Unique notification ID
          title,
          body,
          platformDetails,
          payload: type, // ✅ Set type for handling click behavior
        );
        print("✅ Successfully showed notification: $title");
      } catch (e) {
        print("❌ Error showing notification: $e");
        // Retry once after a short delay
        await Future.delayed(const Duration(seconds: 1));
        try {
          await _flutterLocalNotificationsPlugin.show(
            notificationId,
            title,
            body,
            platformDetails,
            payload: type,
          );
        } catch (retryError) {
          print("❌ Retry failed: $retryError");
          throw Exception('Failed to show notification after retry');
        }
      }
    } catch (e) {
      print("❌ Error showing notification: $e");
      // Show error message to user
      Get.snackbar(
        'Error',
        'Failed to show notification. Please check your settings.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// ✅ Show notification from an incoming Firebase message
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      if (message == null) {
        print("❌ Error: Received null message");
        return;
      }

      if (message.notification == null) {
        print("❌ Error: Message notification is null");
        return;
      }

      String? type = message.data['type']; // Get type from message
      final int notificationId = DateTime.now().millisecondsSinceEpoch
          .remainder(100000);

      // Select appropriate channel based on notification type
      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            type == 'start_navigation' || type == 'destination_reached'
                ? 'location_tracking_channel'
                : 'general_channel',
            type == 'start_navigation' || type == 'destination_reached'
                ? 'Location Tracking'
                : 'General Notifications',
            importance: Importance.max,
            priority: Priority.high,
            enableVibration: true,
            enableLights: true,
            playSound: true,
            icon: '@mipmap/ic_launcher',
            channelShowBadge: true,
          );

      final NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
      );

      await _showNotificationWithRetry(
        notificationId: notificationId,
        title: message.notification!.title ?? "Notification",
        body: message.notification!.body ?? "You have a new message",
        platformDetails: platformDetails,
        type: type,
      );

      print(
        "✅ Successfully showed notification: ${message.notification!.title}",
      );
    } catch (e) {
      print("❌ Error showing notification: $e");
    }
  }

  /// Helper method to show notification with retry mechanism
  static Future<void> _showNotificationWithRetry({
    required int notificationId,
    required String title,
    required String body,
    required NotificationDetails platformDetails,
    String? type,
  }) async {
    try {
      await _flutterLocalNotificationsPlugin.show(
        notificationId,
        title,
        body,
        platformDetails,
        payload: type,
      );
    } catch (e) {
      print("❌ Error showing notification: $e");
      // Retry once after a short delay
      await Future.delayed(const Duration(seconds: 1));
      try {
        await _flutterLocalNotificationsPlugin.show(
          notificationId,
          title,
          body,
          platformDetails,
          payload: type,
        );
      } catch (retryError) {
        print("❌ Retry failed: $retryError");
        // Show error message to user
        Get.snackbar(
          'Error',
          'Failed to show notification. Please check your settings.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
          duration: const Duration(seconds: 3),
        );
      }
    }
  }
}
