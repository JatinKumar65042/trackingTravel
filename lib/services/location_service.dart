import 'dart:async';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tracker/services/notification_service.dart';
import 'package:tracker/services/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:tracker/services/route_observer.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class LocationService {
  static int locationUpdateCount = 0;
  static StreamSubscription<Position>? positionStream;
  static Position? _lastPosition;
  static Position?
  _lastSentPosition; // New variable to track last sent position
  static Timer? _inactivityTimer; // Timer to track location inactivity
  static bool _isMoving = false; // Flag to track if user is currently moving

  // ✅ Store the first location when the user logs in
  static String? _selectedTransportMode;
  static Position?
  _previousPosition; // Track previous position for distance calculation

  // Queue for storing failed location updates for retry
  static List<Map<String, dynamic>> _failedUpdatesQueue = [];
  static Timer? _retryTimer;

  // ➕ Getter for location update count
  static int getLocationUpdateCount() => locationUpdateCount;

  // ➕ Reset the location update count
  static void resetLocationUpdateCount() {
    locationUpdateCount = 0;
  }

  static void setTransportMode(String mode) async {
    // Stop current tracking if active
    stopLocationTracking();

    _selectedTransportMode = mode;
    print("✅ Transport mode set to: $mode");

    // Store the first location whenever transport mode changes
    await storeFirstLocation();

    // Restart location tracking with new transport mode
    await startLocationTracking();
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
        // Set a default transport mode to prevent failures
        _selectedTransportMode = "default";
        print("⚠️ Using default transport mode as fallback.");
      }

      print(
        "📍 Attempting to store first location with transport mode: $_selectedTransportMode",
      );

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final locationData = {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': Timestamp.now(),
        'created_at': Timestamp.now(),
      };

      // Use a single document for all location updates of this transport mode
      final docRef = FirebaseFirestore.instance
          .collection('locations')
          .doc(userId)
          .collection(_selectedTransportMode!)
          .doc('location_history');

      try {
        print(
          "📍 Checking if document exists at path: locations/$userId/${_selectedTransportMode}/location_history",
        );
        // Get the document first to check if it exists
        final docSnapshot = await docRef.get();

        if (docSnapshot.exists) {
          print("📍 Document exists, updating with new location");
          // Document exists, update it by adding to the locations array
          await docRef.update({
            'locations': FieldValue.arrayUnion([locationData]),
            'last_updated': Timestamp.now(),
          });
          print("✅ Successfully updated existing document with new location");
        } else {
          print("📍 Document doesn't exist, creating new document");
          // Document doesn't exist, create it with the first location
          await docRef.set({
            'locations': [locationData],
            'created_at': Timestamp.now(),
            'last_updated': Timestamp.now(),
            'transport_mode': _selectedTransportMode,
          });
          print("✅ Successfully created new document with first location");
        }

        // Increment the update count after successful Firebase update
        locationUpdateCount++;

        print(
          "✅ First location stored: (${position.latitude}, ${position.longitude})",
        );

        // Initialize _lastSentPosition so that further updates are based off this
        _lastSentPosition = position;
      } catch (error) {
        print("❌ Error storing first location: $error");
      }
    } catch (e) {
      print("❌ Error accessing location: $e");
    }
  }

  static Future<void> startLocationTracking() async {
    try {
      // Ensure notification service is initialized
      await NotificationService.init();

      // Cancel any existing position stream to prevent duplicates
      await positionStream?.cancel();
      positionStream = null;

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print("❌ Location services are disabled.");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          print("❌ Location permissions are denied.");
          return;
        }
      }

      _startInactivityTimer();
      // Configure location settings for optimal real-time updates
      // Updated distanceFilter to 10 to align with our update threshold.
      positionStream = Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
          timeLimit: Duration(seconds: 10),
        ),
      ).listen(
        (Position position) async {
          // Enhanced duplicate prevention: Only send if moved enough AND enough time has passed
          const double minDistance = 10; // meters
          const int minTimeDiff = 15; // seconds
          bool shouldSend = true;
          if (_lastSentPosition != null) {
            double movedDistance = Geolocator.distanceBetween(
              _lastSentPosition!.latitude,
              _lastSentPosition!.longitude,
              position.latitude,
              position.longitude,
            );
            int lastSentTimestamp =
                _lastSentPosition!.timestamp != null
                    ? (_lastSentPosition!.timestamp!.millisecondsSinceEpoch ~/
                        1000)
                    : 0;
            int currentTimestamp =
                position.timestamp != null
                    ? (position.timestamp!.millisecondsSinceEpoch ~/ 1000)
                    : DateTime.now().millisecondsSinceEpoch ~/ 1000;
            int timeDiff = currentTimestamp - lastSentTimestamp;
            if (movedDistance < minDistance || timeDiff < minTimeDiff) {
              shouldSend = false;
            }
          }
          if (!shouldSend) {
            _lastPosition = position;
            _resetInactivityTimer();
            return;
          }
          // Wrap in try-catch to prevent stream termination on errors
          try {
            String? userId = await SharedPreferenceHelper().getUserId();
            if (userId == null) {
              print("❌ User ID is null. Cannot update location.");
              return;
            }

            if (_selectedTransportMode == null) {
              print("❌ Transport mode not selected. Cannot update location.");
              _selectedTransportMode = "default";
              print("⚠️ Using default transport mode as fallback.");
            }

            final locationData = {
              'latitude': position.latitude,
              'longitude': position.longitude,
              'timestamp': Timestamp.now(),
              'created_at': Timestamp.now(),
              'accuracy': position.accuracy,
              'speed': position.speed,
              'heading': position.heading,
            };

            final docRef = FirebaseFirestore.instance
                .collection('locations')
                .doc(userId)
                .collection(_selectedTransportMode!)
                .doc('location_history');

            // Enhanced retry logic with exponential backoff
            int maxRetries = 5;
            int currentRetry = 0;
            Duration baseDelay = Duration(milliseconds: 500);
            bool updateSuccessful = false;

            while (currentRetry < maxRetries && !updateSuccessful) {
              try {
                // Use transaction for atomic updates
                await FirebaseFirestore.instance.runTransaction((
                  transaction,
                ) async {
                  final docSnapshot = await transaction.get(docRef);

                  if (docSnapshot.exists) {
                    transaction.update(docRef, {
                      'locations': FieldValue.arrayUnion([locationData]),
                      'last_updated': Timestamp.now(),
                    });
                  } else {
                    transaction.set(docRef, {
                      'locations': [locationData],
                      'created_at': Timestamp.now(),
                      'last_updated': Timestamp.now(),
                      'transport_mode': _selectedTransportMode,
                    });
                  }
                });

                locationUpdateCount++;
                print("✅ Location updated successfully");
                updateSuccessful = true;
                // Update _lastSentPosition to current position after success.
                _lastSentPosition = position;
                break; // Success, exit retry loop
              } catch (error) {
                currentRetry++;
                if (currentRetry < maxRetries) {
                  // Calculate exponential backoff delay with jitter
                  final delay = baseDelay * pow(2, currentRetry - 1);
                  final jitter = Random().nextInt(200); // 0-200ms jitter
                  final totalDelay = delay + Duration(milliseconds: jitter);

                  print(
                    "⚠️ Retry attempt $currentRetry after delay: ${totalDelay.inMilliseconds}ms",
                  );
                  await Future.delayed(totalDelay);
                } else {
                  print(
                    "❌ Failed to update location after $maxRetries attempts: $error",
                  );
                  // Log error but don't throw to prevent stream termination
                  bool isConnected = await _isNetworkConnected();
                  if (!isConnected) {
                    print("📡 Network unavailable, queuing update for later");
                  } else {
                    print("❌ Firebase error despite network connection");
                  }
                  _queueFailedUpdate(
                    userId,
                    _selectedTransportMode!,
                    locationData,
                  );
                }
              }
            }

            // Update movement tracking (existing logic for logging, can be kept as is)
            if (_lastPosition != null) {
              double dist = Geolocator.distanceBetween(
                _lastPosition!.latitude,
                _lastPosition!.longitude,
                position.latitude,
                position.longitude,
              );

              if (dist >= 5 && !_isMoving) {
                _isMoving = true;
                print("🚶 Movement detected: ${dist.toStringAsFixed(2)}m");
              } else if (dist < 3) {
                _isMoving = false;
                print("🛑 User stationary: ${dist.toStringAsFixed(2)}m");
              }
            }
            _lastPosition = position;
            _resetInactivityTimer();
          } catch (e) {
            print("❌ Error in location update handler: $e");
          }
        },
        onError: (error) {
          print("❌ Position stream error: $error");
          Future.delayed(Duration(seconds: 5), () {
            startLocationTracking();
          });
        },
        cancelOnError: false,
      );
    } catch (e) {
      print("❌ Error in location tracking: $e");
      await Future.delayed(Duration(seconds: 5));
      startLocationTracking();
    }
  }

  static void _startInactivityTimer() {
    _inactivityTimer = Timer(Duration(seconds: 7), () {
      if (_isMoving) {
        _isMoving = false;
      }
    });
  }

  static void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    _startInactivityTimer();
  }

  static void _queueFailedUpdate(
    String userId,
    String transportMode,
    Map<String, dynamic> locationData,
  ) {
    _failedUpdatesQueue.add({
      'userId': userId,
      'transportMode': transportMode,
      'locationData': locationData,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    print(
      "⚠️ Added failed update to retry queue. Queue size: ${_failedUpdatesQueue.length}",
    );
    _startRetryTimer();
  }

  static void _startRetryTimer() {
    if (_retryTimer?.isActive ?? false) return;

    _retryTimer = Timer.periodic(Duration(seconds: 30), (timer) async {
      bool isConnected = await _isNetworkConnected();
      if (isConnected) {
        _retryFailedUpdates();
      } else {
        print("📡 Network still unavailable, will retry later");
      }
    });
  }

  static Future<bool> _isNetworkConnected() async {
    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      print("❌ Error checking connectivity: $e");
      return true;
    }
  }

  static Future<void> _retryFailedUpdates() async {
    if (_failedUpdatesQueue.isEmpty) {
      _retryTimer?.cancel();
      return;
    }

    print(
      "🔄 Attempting to retry ${_failedUpdatesQueue.length} failed updates",
    );

    final updatesToRetry = List<Map<String, dynamic>>.from(_failedUpdatesQueue);

    for (var update in updatesToRetry) {
      try {
        final userId = update['userId'];
        final transportMode = update['transportMode'];
        final locationData = update['locationData'];

        final docRef = FirebaseFirestore.instance
            .collection('locations')
            .doc(userId)
            .collection(transportMode)
            .doc('location_history');

        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final docSnapshot = await transaction.get(docRef);

          if (docSnapshot.exists) {
            transaction.update(docRef, {
              'locations': FieldValue.arrayUnion([locationData]),
              'last_updated': Timestamp.now(),
            });
          } else {
            transaction.set(docRef, {
              'locations': [locationData],
              'created_at': Timestamp.now(),
              'last_updated': Timestamp.now(),
              'transport_mode': transportMode,
            });
          }
        });

        _failedUpdatesQueue.removeWhere(
          (item) =>
              item['timestamp'] == update['timestamp'] &&
              item['userId'] == userId,
        );

        locationUpdateCount++;
        print(
          "✅ Successfully retried location update. Queue size: ${_failedUpdatesQueue.length}",
        );
      } catch (e) {
        print("❌ Failed to retry update: $e");
      }
    }
  }

  static Future<void> stopLocationTracking() async {
    try {
      if (_failedUpdatesQueue.isNotEmpty) {
        print(
          "🔄 Attempting to send ${_failedUpdatesQueue.length} pending updates before stopping",
        );
        await _retryFailedUpdates();
      }

      await positionStream?.cancel();
      _inactivityTimer?.cancel();
      _retryTimer?.cancel();

      _lastPosition = null;
      _isMoving = false;

      print("🛑 Location tracking stopped and resources cleaned up.");
      print("📊 Final location update count: $locationUpdateCount");
    } catch (e) {
      print("❌ Error stopping location tracking: $e");
    }
  }
}
