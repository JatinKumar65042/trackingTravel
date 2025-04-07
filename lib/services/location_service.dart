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
  static bool _isMoving = false; // Flag to track if user is currently moving

  // ✅ Store the first location when the user logs in
  static String? _selectedTransportMode;

  static void setTransportMode(String mode) {
    _selectedTransportMode = mode;
  }

  static Future<void> storeFirstLocation() async {
    try {
      String? userId = await SharedPreferenceHelper().getUserId();
      if (userId == null) {
        print("❌ User ID is null. Cannot store first location.");
        return;
      }

      if (_selectedTransportMode == null) {
        print("❌ Transport mode not selected. Cannot store location.");
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Store under default/location/{userId}/{transportMode}
      await FirebaseFirestore.instance
          .collection('locations')
          .doc(userId)
          .collection(_selectedTransportMode!)
          .doc('locationData')
          .set({
        'locations': FieldValue.arrayUnion([
          {
            'latitude': position.latitude,
            'longitude': position.longitude,
            'timestamp': Timestamp.now(),
          },
        ])
      }, SetOptions(merge: true));
      print(
        "✅ First location stored: (${position.latitude}, ${position.longitude})",
      );
    } catch (e) {
      print("❌ Error storing first location: $e");
    }
  }

  // ✅ Start real-time tracking after first login
  static Future<void> startLocationTracking() async {
    try {
      // ✅ Initialize Notifications
      await NotificationService.init();

      // Check if location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print("❌ Location services are disabled.");
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          print("❌ Location permissions are denied.");
          return;
        }
      }

      // ✅ Start the inactivity timer
      _startInactivityTimer();

      // ✅ Listen to location updates
      positionStream = Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5, // Update every 5 meters for more accurate tracking
        ),
      ).listen((Position position) async {
        String? userId = await SharedPreferenceHelper().getUserId();
        if (userId == null) return;

        if (_selectedTransportMode == null) {
          print("❌ Transport mode not selected. Cannot update location.");
          return;
        }

        // Update location under default/location/{userId}/{transportMode}
        await FirebaseFirestore.instance
            .collection('locations')
            .doc(userId)
            .collection(_selectedTransportMode!) // this is the modeName as a collection
            .doc(_selectedTransportMode!)        // use the mode name itself as doc ID
            .set({
          'locations': FieldValue.arrayUnion([
            {
              'latitude': position.latitude,
              'longitude': position.longitude,
              'timestamp': Timestamp.now(),
            },
          ])
        }, SetOptions(merge: true));
        print(
          "📍 Updated location: (${position.latitude}, ${position.longitude}) for userId: $userId",
        );

        if (_lastPosition != null) {
          double distance = Geolocator.distanceBetween(
            _lastPosition!.latitude,
            _lastPosition!.longitude,
            position.latitude,
            position.longitude,
          );

          // We're still tracking distance but not sending movement notifications
          if (distance >= 20 && !_isMoving) {
            _isMoving = true;
            // Movement notification removed as requested
          } else if (distance < 5) {
            _isMoving =
                false; // Reset moving flag when user is relatively stationary
          }
        }
        _lastPosition = position;

        // Reset the inactivity timer on location update
        _resetInactivityTimer();
      });
    } catch (e) {
      print("❌ Error starting location tracking: $e");
    }
  }

  // Start the inactivity timer
  static void _startInactivityTimer() {
    _inactivityTimer = Timer(Duration(seconds: 30), () {
      // User was previously moving but we're no longer sending notifications
      if (_isMoving) {
        _isMoving = false;
        // Destination reached notification removed as requested
      }
    });
  }

  // ✅ Reset the inactivity timer
  static void _resetInactivityTimer() {
    _inactivityTimer?.cancel(); // Cancel the existing timer
    _startInactivityTimer(); // Start a new timer
  }

  // ✅ Stop tracking location when needed
  static void stopLocationTracking() {
    try {
      positionStream?.cancel();
      _inactivityTimer?.cancel();
      _lastPosition = null;
      _isMoving = false;
      print("🛑 Location tracking stopped and resources cleaned up.");
    } catch (e) {
      print("❌ Error stopping location tracking: $e");
    }
  }
}
