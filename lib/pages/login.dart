import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui'; // Required for blur effect
import 'package:lottie/lottie.dart';
import 'package:tracker/pages/signup.dart';
import 'package:tracker/services/route_observer.dart';
import 'package:tracker/widgets/loading_button.dart';

import '../controller/auth_controller.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  AuthController controller = Get.find();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent, // Transparent to allow blur effect
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
                        mainAxisAlignment: MainAxisAlignment.start, // Align left
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
                        mainAxisAlignment:
                            MainAxisAlignment.end, // Aligns text to the right
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
                                  builder: (context) => SignUp(),
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
                          Obx(
                            () => SizedBox(
                              width: 100,
                              child: LoadingButton(
                                onPressed: () async {
                                  await controller.login(
                                    _emailController.text.trim(),
                                    _passwordController.text,
                                  );
                                },
                                isLoading: controller.isLoading.value,
                                backgroundColor: Colors.deepPurpleAccent,
                                borderRadius: BorderRadius.circular(30),
                                padding: EdgeInsets.all(10),
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
    // Get screen dimensions
    final Size screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;
    
    return Scaffold(
      // Allow scrolling when keyboard appears
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: screenHeight,
          ),
          child: Stack(
            children: [
              // Adding lottie with responsive positioning
              Positioned(
                top: screenHeight * 0.45, // Relative positioning (45% from top)
                left: 0,
                right: 0,
                child: Lottie.asset(
                  "images/Animation - 1740244778613.json",
                  height: screenHeight * 0.3, // 30% of screen height
                  width: screenWidth,
                  fit: BoxFit.contain, // Changed to contain for better scaling
                ),
              ),
              // Login Page Content
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image with responsive height
                  Container(
                    width: screenWidth,
                    height: screenHeight * 0.3, // 30% of screen height
                    child: Image.asset(
                      "images/login.jpg",
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02), // 2% of screen height
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.15, // 15% of screen width
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "WELCOME !",
                          style: TextStyle(
                            color: Color.fromARGB(189, 180, 180, 225),
                            // Responsive font size
                            fontSize: screenWidth * 0.15, // 15% of screen width
                            fontFamily: 'LondrinaSketch-Regular',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        // Flexible spacing that adapts to screen size
                        SizedBox(height: screenHeight * 0.35), // 35% of screen height
                        // Center button with responsive sizing
                        Center(
                          child: ElevatedButton(
                            onPressed: _showLoginDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurpleAccent,
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.04, // 4% of screen width
                                vertical: screenHeight * 0.02, // 2% of screen height
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  "images/travel.png",
                                  height: screenHeight * 0.06, // 6% of screen height
                                  width: screenWidth * 0.12, // 12% of screen width
                                ),
                                SizedBox(height: screenHeight * 0.01), // 1% of screen height
                                Text(
                                  "Let's Go!",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: screenWidth * 0.05, // 5% of screen width
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
        ),
      ),
    );
  }

  login() {
    String email = _emailController.text;
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

    controller.login(email, password);
  }
}
