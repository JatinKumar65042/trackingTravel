import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:tracker/pages/homepage.dart';
import 'package:tracker/pages/login.dart';
import 'package:tracker/pages/signup.dart';

class SplashScreen extends StatefulWidget {
  final Widget? child;
  const SplashScreen({super.key, this.child}) ;

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Future.delayed(
        Duration(seconds: 3),(){
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => widget.child!), (route) => false);
    }
    );
    super.initState();
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
