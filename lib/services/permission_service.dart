import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  // Request location permissions including background location
  static Future<bool> requestLocationPermission(BuildContext context) async {
    // First check the current permission status
    LocationPermission geoPermission = await Geolocator.checkPermission();
    
    // If denied, request permission
    if (geoPermission == LocationPermission.denied) {
      geoPermission = await Geolocator.requestPermission();
      if (geoPermission == LocationPermission.denied) {
        // Permission denied
        _showPermissionDialog(
          context,
          'Location Permission Required',
          'This app needs location permission to track your travel. Please grant location permission.',
        );
        return false;
      }
    }
    
    // If permanently denied, open app settings
    if (geoPermission == LocationPermission.deniedForever) {
      _showPermissionDialog(
        context,
        'Location Permission Permanently Denied',
        'Location permission is permanently denied. Please enable it from app settings.',
        openSettings: true,
      );
      return false;
    }
    
    // On Android, we need to request background location separately
    if (await Permission.locationAlways.isDenied) {
      // First ensure we have foreground permission
      if (geoPermission == LocationPermission.whileInUse) {
        // Show dialog explaining why we need background location
        await _showBackgroundPermissionDialog(context);
        
        // Request background permission
        if (await Permission.locationAlways.request() != PermissionStatus.granted) {
          // User denied background permission
          print("❌ Background location permission denied");
          return false;
        }
      }
    }
    
    return true;
  }
  
  // Show dialog explaining why we need location permission
  static Future<void> _showPermissionDialog(
    BuildContext context,
    String title,
    String message, {
    bool openSettings = false,
  }) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (openSettings) {
                  openAppSettings();
                }
              },
              child: Text(openSettings ? 'Open Settings' : 'OK'),
            ),
          ],
        );
      },
    );
  }
  
  // Show dialog explaining why we need background location
  static Future<void> _showBackgroundPermissionDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Background Location Required'),
          content: const Text(
            'This app needs background location access to track your travel even when the app is closed. '
            'This helps us provide accurate journey tracking and notifications.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }
}