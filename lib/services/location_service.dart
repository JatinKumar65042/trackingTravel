import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tracker/services/notification_service.dart';
import 'package:tracker/services/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:tracker/services/route_observer.dart';

class LocationService {
  static StreamSubscription<Position>? positionStream;
  static Position? _lastPosition;
  static Timer? _inactivityTimer; // Timer to track location inactivity

  // ✅ Store the first location when the user logs in
  static Future<void> storeFirstLocation() async {
    try {
      String? userId = await SharedPreferenceHelper().getUserId();
      if (userId == null) {
        print("❌ User ID is null. Cannot store first location.");
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // ✅ Store user's first location only if the document doesn't exist
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('locations')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        await FirebaseFirestore.instance.collection('locations').doc(userId).set({
          'userId': userId,
          'locations': [
            {
              'latitude': position.latitude,
              'longitude': position.longitude,
              'timestamp': Timestamp.now(), // ✅ FIX: Use Timestamp.now()
            }
          ]
        });
        print("✅ First location stored: (${position.latitude}, ${position.longitude})");
      } else {
        print("⚠️ First location already exists, skipping...");
      }

    } catch (e) {
      print("❌ Error storing first location: $e");
    }
  }

  // ✅ Start real-time tracking after first login
  static Future<void> startLocationTracking() async {
    try {
      // ✅ Initialize Notifications
      await NotificationService.init();

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.deniedForever) {
          print("❌ Location permissions are permanently denied.");
          return;
        }
      }

      // ✅ Start the inactivity timer
      _startInactivityTimer();

      // ✅ Listen to location updates
      positionStream = Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // Update only when moved 10 meters
        ),
      ).listen((Position position) async {
        String? userId = await SharedPreferenceHelper().getUserId();
        if (userId == null) return;

        // ✅ Update user's location in Firestore
        await FirebaseFirestore.instance.collection('locations').doc(userId).set({
          'userId': userId,
          'locations': FieldValue.arrayUnion([
            {
              'latitude': position.latitude,
              'longitude': position.longitude,
              'timestamp': Timestamp.now(), // ✅ FIX: Use Timestamp.now()
            }
          ]),
        }, SetOptions(merge: true));

        print("📍 Updated location: (${position.latitude}, ${position.longitude}) for userId: $userId");

        if (_lastPosition != null) {
          double distance = Geolocator.distanceBetween(
            _lastPosition!.latitude,
            _lastPosition!.longitude,
            position.latitude,
            position.longitude,
          );
          if (distance >= 10) {
            // ✅ Check if the user is already on the /location page
            if (AppState.currentRoute.trim().toLowerCase() != '/location') {
              NotificationService.showNotification(
                title: "Are you going somewhere?",
                body: "Start navigation now.",
                type: "start_navigation",
              );
            } else {
              print("🚀 User is already on /location, skipping notification...");
            }
          }
        }
        _lastPosition = position;

        // ✅ Reset the inactivity timer on location update
        _resetInactivityTimer();
      });

    } catch (e) {
      print("❌ Error starting location tracking: $e");
    }
  }

  // ✅ Start the inactivity timer
  static void _startInactivityTimer() {
    _inactivityTimer = Timer(Duration(minutes: 2), () {
      // ✅ Send notification if no location updates for 2 minutes
      NotificationService.showNotification(
        title: "Have you reached your destination?",
        body: "Tap to go home.",
        type: "destination_reached",
      );
    });
  }

  // ✅ Reset the inactivity timer
  static void _resetInactivityTimer() {
    _inactivityTimer?.cancel(); // Cancel the existing timer
    _startInactivityTimer(); // Start a new timer
  }

  // ✅ Stop tracking location when needed
  static void stopLocationTracking() {
    positionStream?.cancel();
    print("🛑 Location tracking stopped.");
  }

}