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

  Future<void> signup(String username, String email, String password , String cnfpassword) async {
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
        return; // Stop execution if passwords do not match
      }

      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      userId = credential.user!.uid;

      // ✅ Save user data to Firestore
      String id = randomAlphaNumeric(10);
      Map<String, dynamic> userInfoMap = {
        "Name": username,
        "Email": email.trim(),
        "id": id,
        "createdAt": FieldValue.serverTimestamp(),
      };
      await SharedPreferenceHelper().saveUserDisplayName(username);
      await SharedPreferenceHelper().saveUserEmail(email);
      await SharedPreferenceHelper().saveUserId(id);
      await DatabaseMethods().addUserDetails(userInfoMap, id).then((value) {
        Get.snackbar(
          "Success",
          "Registered Successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      });

      // await LocationService.startLocationTracking();

      // ✅ Show success message

      Get.offAllNamed('/survey');
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Something went wrong";

      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'The account already exists for that email.';
      }

// ❌ Show error message using Get.snackbar
      Get.snackbar(
        "Error",
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    } catch (e) {
      print(e);
    }
  }

  Future<void> login(String email, String password) async {
    try {
      String myname="" , myid = "";
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      QuerySnapshot querySnapshot = await DatabaseMethods().getUserbyEmail(email);
      myname = "${querySnapshot.docs[0]["Name"]}";
      myid = "${querySnapshot.docs[0]["id"]}";

      await SharedPreferenceHelper().saveUserId(myid);
      await SharedPreferenceHelper().saveUserEmail(email);
      await SharedPreferenceHelper().saveUserDisplayName(myname);

      // ✅ Get FCM Token
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      print("FCM Token: $fcmToken");

      // ✅ Update FCM Token in Firestore
      await FirebaseFirestore.instance.collection('users').doc(myid).update({
        "fcmToken": fcmToken,
      });
      print("📍 Current Route: ${AppState.currentRoute}");
      // ✅ Send local notification on login success
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

      // await LocationService.startLocationTracking();

      Get.offAllNamed('/home');
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Something went wrong";

      if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password provided for that user.';
      }

      Get.snackbar(
        "Error ❌",
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    }
  }
}
