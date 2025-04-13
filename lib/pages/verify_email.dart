import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tracker/services/shared_pref.dart';

class VerifyEmailScreen extends StatefulWidget {
  @override
  _VerifyEmailScreenState createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool isEmailVerified = false;
  Timer? timer;
  bool isResendDisabled = false; // ✅ Prevent spam clicking
  String? userId; // ✅ Store alphanumeric ID

  @override
  void initState() {
    super.initState();
    getUserId(); // ✅ Fetch alphanumeric ID
    checkEmailVerification();

    // ✅ Automatically check email verification every 5 seconds
    timer = Timer.periodic(Duration(seconds: 5), (timer) {
      checkEmailVerification();
    });
  }

  @override
  void dispose() {
    timer?.cancel(); // ✅ Stop the timer when screen is disposed
    super.dispose();
  }

  Future<void> getUserId() async {
    userId = await SharedPreferenceHelper().getUserId();
  }

  Future<void> checkEmailVerification() async {
    User? user = FirebaseAuth.instance.currentUser;
    await user?.reload(); // Refresh user state

    if (user != null && user.emailVerified && userId != null) {
      setState(() => isEmailVerified = true);

      // ✅ Update emailVerified status in Firestore using alphanumeric ID
      await FirebaseFirestore.instance.collection("users").doc(userId).update({
        "emailVerified": true,
      });

      Get.snackbar(
        "Email Verified ✅",
        "Your email has been successfully verified!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );

      // ✅ Redirect to the next screen
      Get.offAllNamed('/survey');
    }
  }

  Future<void> resendVerificationEmail() async {
    if (isResendDisabled) return;

    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      setState(() => isResendDisabled = true);

      Get.snackbar(
        "Verification Email Sent",
        "Please check your inbox.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );

      // ✅ Enable button after 30 seconds
      Future.delayed(Duration(seconds: 30), () {
        setState(() => isResendDisabled = false);
      });
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to send email. Try again later.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Verify Email")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "A verification email has been sent. Please verify your email to continue.",
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isResendDisabled ? null : resendVerificationEmail,
              child: Text(isResendDisabled ? "Wait 30s..." : "Resend Email"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await checkEmailVerification();
                if (!isEmailVerified) {
                  Get.snackbar(
                    "Still Not Verified",
                    "Please check your inbox and verify.",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.orange,
                    colorText: Colors.white,
                  );
                }
              },
              child: Text("I have verified"),
            ),
          ],
        ),
      ),
    );
  }
}
