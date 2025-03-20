import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tracker/services/shared_pref.dart';

class LocationService {
  static StreamSubscription<Position>? positionStream;

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
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.deniedForever) {
          print("❌ Location permissions are permanently denied.");
          return;
        }
      }

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
      });

    } catch (e) {
      print("❌ Error starting location tracking: $e");
    }
  }

  // ✅ Stop tracking location when needed
  static void stopLocationTracking() {
    positionStream?.cancel();
    print("🛑 Location tracking stopped.");
  }
}
