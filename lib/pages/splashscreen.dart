import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:tracker/pages/homepage.dart';
import 'package:tracker/pages/login.dart';
import 'package:tracker/pages/signup.dart';
import 'package:tracker/services/shared_pref.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () => handleNavigation());
  }

  Future<void> handleNavigation() async {
    User? user = FirebaseAuth.instance.currentUser;
    await Future.delayed(Duration(milliseconds: 300)); // just to ensure reload completes
    await user?.reload();
    user = FirebaseAuth.instance.currentUser;

    if (user == null || !(user.emailVerified)) {
      Get.offAllNamed('/login');
      return;
    }

    final userId = await SharedPreferenceHelper().getUserId();
    if (userId == null || userId.isEmpty) {
      Get.offAllNamed('/login');
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (!doc.exists) {
        Get.offAllNamed('/login');
        return;
      }

      final data = doc.data() ?? {};
      final isSurveyCompleted = data['surveyCompleted'] == true;
      final isEmailVerifiedInDb = data['emailVerified'] == true;

      if (!isEmailVerifiedInDb) {
        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'emailVerified': true,
        });
      }

      if (isSurveyCompleted) {
        Get.offAllNamed('/home');
      } else {
        Get.offAllNamed('/survey');
      }
    } catch (e) {
      print("Splash Error: $e");
      Get.offAllNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              "images/splash.json",
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 20),
            Text(
              "Future's In Your Hands",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'PlayfairDisplay-VariableFont_wght',
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}