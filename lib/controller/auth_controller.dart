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
      if (!email.endsWith("@itbhu.ac.in") && !email.endsWith("@iitbhu.ac.in")) {
        Get.snackbar(
          "Error",
          "Only institute emails are allowed!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        return;
      }

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

      User? user = credential.user;

      if (user != null) {
        await user.sendEmailVerification(); // ✅ Send Email Verification

        String id = randomAlphaNumeric(10);
        Map<String, dynamic> userInfoMap = {
          "Name": username,
          "Email": email.trim(),
          "id": id,
          "role": "user", // Initialize with default user role
          "createdAt": FieldValue.serverTimestamp(),
          "surveyCompleted": false,
          "emailVerified": false, // Initially false
          "fcmToken": await FirebaseMessaging.instance.getToken(),
        };
        await SharedPreferenceHelper().saveUserDisplayName(username);
        await SharedPreferenceHelper().saveUserEmail(email);
        await SharedPreferenceHelper().saveUserId(id);
        await SharedPreferenceHelper().saveUserRole("user");
        _roleController.add("user");
        await DatabaseMethods().addUserDetails(userInfoMap, id);

        Get.snackbar(
          "Success",
          "Registered Successfully! Please verify your email before logging in.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
        );

        // ✅ Check for email verification every 3 seconds
        Timer.periodic(Duration(seconds: 3), (timer) async {
          await user.reload();
          if (user.emailVerified) {
            timer.cancel(); // Stop checking
            await FirebaseFirestore.instance.collection("users").doc(id).update({
              "emailVerified": true,
            });

            Get.snackbar(
              "Email Verified ✅",
              "Your email has been successfully verified!",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.blue,
              colorText: Colors.white,
              duration: Duration(seconds: 5),
            );

            Get.offAllNamed('/login'); // Redirect to login
          }
        });
      };
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Something went wrong";

      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'The account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Invalid email format.';
      } else if (e.code == 'operation-not-allowed') {
        errorMessage = 'Email/password accounts are not enabled.';
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
      String myname = "", myid = "";

      final authFuture = FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email.trim(), password: password)
          .timeout(
        Duration(seconds: 15),
        onTimeout: () => throw TimeoutException(
          'Authentication timed out. Please check your internet connection.',
        ),
      );

      // Show "processing" after 2 seconds
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
      final User? user = credential.user;

      // ✅ Check email verification
      if (user != null && !user.emailVerified) {
        isLoading.value = false;
        Get.defaultDialog(
          title: "Email Not Verified ❌",
          middleText: "Please verify your email before logging in.",
          backgroundColor: Colors.orange,
          titleStyle: TextStyle(color: Colors.white),
          middleTextStyle: TextStyle(color: Colors.white),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  await user.reload();
                  final refreshedUser = FirebaseAuth.instance.currentUser;
                  if (refreshedUser != null && !refreshedUser.emailVerified) {
                    await refreshedUser.sendEmailVerification();
                    Get.back();
                    Get.snackbar(
                      "Verification Sent ✅",
                      "A new verification email has been sent.",
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.blue,
                      colorText: Colors.white,
                    );
                  } else {
                    Get.back();
                    Get.snackbar(
                      "Already Verified ✅",
                      "Your email is already verified. Try logging in again.",
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                  }
                } catch (e) {
                  Get.snackbar(
                    "Error ❌",
                    "Failed to send verification email.",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              },
              child: Text("Resend Email", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
        return;
      }

      // ✅ Fetch user data
      final querySnapshot = await DatabaseMethods()
          .getUserbyEmail(email)
          .timeout(Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('Database query timed out.');
      });

      if (querySnapshot.docs.isEmpty) throw Exception("User not found");

      final userDoc = querySnapshot.docs[0];
      myname = userDoc["Name"];
      myid = userDoc["id"];
      final bool surveyCompleted = userDoc["surveyCompleted"] ?? false;

      // ✅ Save shared preferences
      await Future.wait([
        SharedPreferenceHelper().saveUserId(myid),
        SharedPreferenceHelper().saveUserEmail(email),
        SharedPreferenceHelper().saveUserDisplayName(myname),
      ]);

      // ✅ Fetch role
      DocumentSnapshot roleSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(myid)
          .get()
          .timeout(Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('Role verification timed out.');
      });

      String? userRole = roleSnapshot.get('role') as String?;
      userRole ??= 'user';

      if (userRole != 'admin' && userRole != 'user') {
        userRole = 'user';
        await FirebaseFirestore.instance.collection('users').doc(myid).update({
          'role': userRole,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      SharedPreferenceHelper().saveUserRole(userRole);
      _roleController.add(userRole);

      // ✅ FCM token
      String? fcmToken = await FirebaseMessaging.instance
          .getToken()
          .timeout(Duration(seconds: 5), onTimeout: () => null);

      if (fcmToken != null) {
        FirebaseFirestore.instance.collection('users').doc(myid).update({
          "fcmToken": fcmToken,
          "emailVerified": user!.emailVerified,
        }).catchError((e) => print("Failed to update FCM token: $e"));
      }

      print("📍 Current Route: ${AppState.currentRoute}");

      // ✅ Navigate based on survey status
      if (surveyCompleted) {
        Get.offAllNamed('/home');
      } else {
        Get.offAllNamed('/survey');
      }

      // ✅ Success notification
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
      Get.snackbar(
        "Connection Issue ⚠️",
        e.message ?? "Login timed out. Please check your connection.",
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
        errorMessage = 'Wrong password provided.';
      } else if (e.code == 'network-request-failed') {
        errorMessage = 'Network error. Please check your connection.';
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
      String errorMessage = "An unexpected error occurred.";
      if (e.toString().contains('network')) {
        errorMessage = "Network error. Please check your connection.";
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
