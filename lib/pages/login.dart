import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui'; // Required for blur effect
import 'package:lottie/lottie.dart';
import 'package:tracker/pages/signup.dart';
import 'package:tracker/services/route_observer.dart';

import '../controller/auth_controller.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  AuthController controller = Get.find() ;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  void _showLoginDialog() {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
        backgroundColor:
        Colors.transparent, // Transparent to allow blur effect
        child: Stack(
          children: [
            // Blurred Background
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 10,
                  sigmaY: 10,
                ), // Blur effect
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(
                      alpha: 0.4,
                    ), // Semi-transparent background
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.start, // Align left
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 28,
                            ),
                            onPressed: () {
                              Navigator.pop(context); // Close dialog
                            },
                          ),
                          SizedBox(
                            width: 50,
                          ), // Space between icon and text
                          Text(
                            "LOGIN",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: "Enter Email Here",
                          hintStyle: TextStyle(color: Colors.white54),
                          suffixIcon: Icon(
                            Icons.email,
                            color: Colors.white,
                          ),
                          filled: true,
                          fillColor: Colors.black.withValues(alpha: 0.2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 15),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: "Enter Password",
                          hintStyle: TextStyle(color: Colors.white54),
                          suffixIcon: Icon(Icons.lock, color: Colors.white),
                          filled: true,
                          fillColor: Colors.black.withValues(alpha: 0.2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end, // Aligns text to the right
                        children: [
                          Text(
                            "Forgot Password ? ",
                            style: TextStyle(
                              color: Colors.deepPurpleAccent,
                              fontSize: 14,
                              fontFamily: 'Gilroy-Light',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.center, // Centers buttons horizontally
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>SignUp(),
                                ),
                              );
                            },
                            child: Container(
                              width: 100,
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color:
                                Colors.white, // White background for SignUp
                              ),
                              child: Center(
                                child: Text(
                                  "SignUp",
                                  style: TextStyle(
                                    color: Colors.deepPurpleAccent,
                                    fontSize: 15,
                                    fontFamily: 'Gilroy-Light',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 60), // Space between buttons
                          GestureDetector(
                            onTap: () => login(),
                            child: Container(
                              width: 100,
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color:
                                Colors.deepPurpleAccent, // Purple background for LogIn
                              ),
                              child: Center(
                                child: Text(
                                  "LogIn",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontFamily: 'Gilroy-Light',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset : false,
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          //adding lottie
          Positioned(
            top: 375, // Moves it down
            left: 0,
            right: 0,
            child: Lottie.asset(
              "images/Animation - 1740244778613.json", // Replace with your file
              height: 300, // Adjust size as needed
              width: 300,
              fit: BoxFit.cover, // Ensures it fills correctly
            ),
          ),
          // Login Page Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset("images/login.jpg"),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 60.0, right: 60.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "WELCOME !",
                      style: TextStyle(
                        color: Color.fromARGB(189, 180, 180, 225),
                        fontSize: 70,
                        fontFamily: 'LondrinaSketch-Regular',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 390),
                    Center(
                      child: ElevatedButton(
                        onPressed: _showLoginDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurpleAccent,
                          padding: EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min, // Keeps it compact
                          children: [
                            Image.asset(
                              "images/travel.png", // Replace with your image path
                              height: 50, // Adjust size as needed
                              width: 50,
                            ),
                            SizedBox(height: 8), // Space between image and text
                            Text(
                              "Let's Go!",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  login(){
    String email = _emailController.text ;
    String password = _passwordController.text;
    print("📍 Current Route: ${AppState.currentRoute}");
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        "Error",
        "All fields are required!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
      return; // Stop execution
    }

    controller.login(email, password) ;
  }
}
