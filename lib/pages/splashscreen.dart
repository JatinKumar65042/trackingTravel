import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:tracker/pages/login.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(seconds: 5), () {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => LogIn()),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center( // Centers everything in the screen
        child: Column(
          mainAxisSize: MainAxisSize.min, // Prevents full height usage
          children: [
            // Lottie Animation (Centered)
            Lottie.asset(
              "images/splash.json", // Ensure the file exists in assets
              width: 200, // Adjust the width as needed
              height: 200, // Adjust the height as needed
              fit: BoxFit.contain,
            ),
            SizedBox(height: 20), // Space between animation and text
            // Text Below Animation
            Text(
              "Future's In Your Hands",
              style: TextStyle(
                fontSize: 20, // Adjust font size
                fontWeight: FontWeight.bold,
                fontFamily: 'PlayfairDisplay-VariableFont_wght',
                color: Colors.black, // Change color if needed
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
