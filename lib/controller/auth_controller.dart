import 'dart:async'; // Import for TimeoutException
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:random_string/random_string.dart';
import 'package:tracker/services/database.dart';
import 'package:tracker/services/location_service.dart';
import 'package:tracker/services/notification_service.dart';
import 'package:tracker/services/route_observer.dart';
import 'package:tracker/services/shared_pref.dart';

class AuthController extends GetxController {
  var userId;
  final _roleController = StreamController<String?>.broadcast();
  Stream<String?> get roleStream => _roleController.stream;

  @override
  void onClose() {
    _roleController.close();
    super.onClose();
  }

  Future<void> updateUserRole(String userId, String newRole) async {
    try {
      // Validate the new role
      if (newRole != 'admin' && newRole != 'user') {
        throw Exception('Invalid role type');
      }

      // Get current user document
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();

      if (!userDoc.exists) {
        throw Exception('User not found');
      }

      // Update role in Firestore
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'role': newRole,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update role in SharedPreferences
      await SharedPreferenceHelper().saveUserRole(newRole);

      // Notify listeners about role change
      _roleController.add(newRole);

      Get.snackbar(
        "Success",
        "Role updated successfully to $newRole",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error updating role: $e');
      Get.snackbar(
        "Error",
        "Failed to update role",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Observable loading state
  final isLoading = false.obs;

  Future<void> signup(
    String username,
    String email,
    String password,
    String cnfpassword,
  ) async {
    isLoading.value = true;
    try {
      if (password != cnfpassword) {
        Get.snackbar(
          "Error",
          "Passwords do not match!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        isLoading.value = false;
        return; // Stop execution if passwords do not match
      }

      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );

      userId = credential.user!.uid;

      String id = randomAlphaNumeric(10);
      Map<String, dynamic> userInfoMap = {
        "Name": username,
        "Email": email.trim(),
        "id": id,
        "role": "user", // Initialize with default user role
        "createdAt": FieldValue.serverTimestamp(),
        "fcmToken": await FirebaseMessaging.instance.getToken(),
      };
      await SharedPreferenceHelper().saveUserDisplayName(username);
      await SharedPreferenceHelper().saveUserEmail(email);
      await SharedPreferenceHelper().saveUserId(id);
      await SharedPreferenceHelper().saveUserRole("user");
      _roleController.add("user");
      await DatabaseMethods().addUserDetails(userInfoMap, id).then((value) {
        Get.snackbar(
          "Success",
          "Registered Successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      });

      Get.offAllNamed('/survey');
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Something went wrong";

      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'The account already exists for that email.';
      }

      Get.snackbar(
        "Error",
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    } catch (e) {
      print("Signup error: $e");
      Get.snackbar(
        "Error",
        "An unexpected error occurred during signup",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login(String email, String password) async {
    isLoading.value = true;
    try {
      // Add timeout to Firebase authentication to prevent long waits
      final authFuture = FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email.trim(), password: password)
          .timeout(
            Duration(seconds: 15),
            onTimeout:
                () =>
                    throw TimeoutException(
                      'Authentication timed out. Please check your internet connection.',
                    ),
          );

      // Show a progress indicator after 2 seconds if auth is still processing
      Future.delayed(Duration(seconds: 2), () {
        if (isLoading.value) {
          Get.snackbar(
            "Processing",
            "Authenticating your credentials...",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.blue,
            colorText: Colors.white,
            duration: Duration(seconds: 2),
          );
        }
      });

      final credential = await authFuture;

      // Fetch user data and role in parallel to save time
      String myname = "", myid = "";
      final userDataFuture = DatabaseMethods()
          .getUserbyEmail(email)
          .timeout(
            Duration(seconds: 10),
            onTimeout:
                () =>
                    throw TimeoutException(
                      'Database query timed out. Please try again.',
                    ),
          );

      final QuerySnapshot querySnapshot = await userDataFuture;
      if (querySnapshot.docs.isEmpty) {
        throw Exception('User data not found');
      }

      myname = "${querySnapshot.docs[0]["Name"]}";
      myid = "${querySnapshot.docs[0]["id"]}";

      // Save user ID immediately to improve perceived performance
      SharedPreferenceHelper().saveUserId(myid);

      // Fetch user role with timeout
      final userDocFuture = FirebaseFirestore.instance
          .collection('users')
          .doc(myid)
          .get()
          .timeout(
            Duration(seconds: 10),
            onTimeout:
                () => throw TimeoutException('Role verification timed out.'),
          );

      final DocumentSnapshot userDoc = await userDocFuture;

      if (!userDoc.exists) {
        throw Exception('User document not found');
      }

      String? userRole = userDoc.get('role') as String?;
      if (userRole == null) {
        // Set default role if not exists
        userRole = 'user';
        FirebaseFirestore.instance.collection('users').doc(myid).update({
          'role': userRole,
          'updatedAt': FieldValue.serverTimestamp(),
        }); // Don't await this update to speed up login process
      }

      // Validate role type
      if (userRole != 'admin' && userRole != 'user') {
        userRole = 'user'; // Reset to default if invalid
        await FirebaseFirestore.instance.collection('users').doc(myid).update({
          'role': userRole,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // Save and broadcast role - do these operations in parallel
      final saveRoleFuture = SharedPreferenceHelper().saveUserRole(userRole);
      _roleController.add(userRole); // This is synchronous, do it immediately
      final saveEmailFuture = SharedPreferenceHelper().saveUserEmail(email);
      final saveNameFuture = SharedPreferenceHelper().saveUserDisplayName(
        myname,
      );

      // Get FCM token in parallel with other operations
      final fcmTokenFuture = FirebaseMessaging.instance.getToken().timeout(
        Duration(seconds: 5),
        onTimeout: () => null, // Don't let FCM token delay the login process
      );

      // Wait for critical operations to complete
      await Future.wait([saveRoleFuture, saveEmailFuture, saveNameFuture]);

      // Get FCM token result
      String? fcmToken = await fcmTokenFuture;
      print("FCM Token: $fcmToken");

      // Update FCM token in background without waiting
      if (fcmToken != null) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(myid)
            .update({"fcmToken": fcmToken})
            .catchError((error) {
              print("Failed to update FCM token: $error");
            });
      }
      print("📍 Current Route: ${AppState.currentRoute}");

      // Navigate to home screen first for better perceived performance
      Get.offAllNamed('/home');

      // Show notification and success message after navigation
      NotificationService.showNotification(
        title: "Welcome Back, $myname! 🎉",
        body: "You have successfully logged in.",
      );

      Get.snackbar(
        "Success 🎉",
        "Login Successful",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    } on TimeoutException catch (e) {
      // Handle timeout specifically
      Get.snackbar(
        "Connection Issue ⚠️",
        e.message ??
            "Login timed out. Please check your internet connection and try again.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Something went wrong";

      if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password provided for that user.';
      } else if (e.code == 'network-request-failed') {
        errorMessage = 'Network error. Please check your internet connection.';
      }

      Get.snackbar(
        "Error ❌",
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    } catch (e) {
      print("Login error: $e");
      String errorMessage = "An unexpected error occurred during login";

      // Provide more helpful messages for common errors
      if (e.toString().contains('network')) {
        errorMessage = "Network error. Please check your internet connection.";
      } else if (e.toString().contains('timeout')) {
        errorMessage = "Login timed out. Please try again.";
      }

      Get.snackbar(
        "Error",
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
