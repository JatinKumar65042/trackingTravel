import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tracker/pages/login.dart';
import 'package:tracker/services/route_observer.dart';

import '../controller/auth_controller.dart';
import '../widgets/loading_button.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  AuthController controller = Get.find();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _cnfpasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final Size screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;
    
    return Scaffold(
      resizeToAvoidBottomInset: true, // Ensures UI adjusts when keyboard appears
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: screenWidth,
              height: screenHeight * 0.25, // 25% of screen height
              child: Image.asset(
                "images/login.jpg",
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.08, // 8% of screen width
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "WAY TO GO!",
                    style: TextStyle(
                      color: Color.fromARGB(189, 180, 180, 225),
                      fontSize: screenWidth * 0.12, // Responsive font size
                      fontFamily: 'LondrinaSketch-Regular',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03), // 3% of screen height
                  buildTextField("Name", _usernameController, Icons.person, screenWidth, screenHeight),
                  buildTextField("Email", _emailController, Icons.email, screenWidth, screenHeight),
                  buildTextField(
                    "Password",
                    _passwordController,
                    Icons.lock,
                    screenWidth,
                    screenHeight,
                    obscureText: true,
                  ),
                  buildTextField(
                    "Confirm Password",
                    _cnfpasswordController,
                    Icons.lock,
                    screenWidth,
                    screenHeight,
                    obscureText: true,
                  ),
                  SizedBox(height: screenHeight * 0.03), // 3% of screen height
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center, // Center the button
                    children: [
                      Container(
                        width: screenWidth * 0.4, // 40% of screen width
                        constraints: BoxConstraints(maxWidth: 200), // Maximum width
                        child: Obx(
                          () => LoadingButton(
                            onPressed: () async {
                              await signup();
                            },
                            isLoading: controller.isLoading.value,
                            backgroundColor: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            padding: EdgeInsets.all(screenHeight * 0.015), // Responsive padding
                            child: Text(
                              "SignUp",
                              style: TextStyle(
                                color: Colors.deepPurpleAccent,
                                fontSize: screenWidth * 0.04, // Responsive font size
                                fontFamily: 'Gilroy-Light',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02), // 2% of screen height
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already Have An Account? ",
                        style: TextStyle(
                          color: Color.fromARGB(157, 255, 255, 255),
                          fontSize: screenWidth * 0.035, // Responsive font size
                          fontFamily: 'Gilroy-Light',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => LogIn()),
                          );
                        },
                        child: Text(
                          "LogIn",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.04, // Responsive font size
                            fontFamily: 'Gilroy-Light',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02), // Add bottom padding
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
    double screenWidth,
    double screenHeight, {
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: screenWidth * 0.05, // Responsive font size
            fontFamily: 'Gilroy-Light',
            fontWeight: FontWeight.w600,
          ),
        ),
        TextField(
          controller: controller,
          obscureText: obscureText,
          style: TextStyle(
            color: Colors.white,
            fontSize: screenWidth * 0.04, // Responsive font size
          ),
          decoration: InputDecoration(
            hintText: "Enter $label Here",
            hintStyle: TextStyle(
              color: Colors.white54,
              fontSize: screenWidth * 0.04, // Responsive font size
            ),
            suffixIcon: Icon(icon, color: Colors.white),
          ),
        ),
        SizedBox(height: screenHeight * 0.015), // 1.5% of screen height
      ],
    );
  }

  Future<void> signup() async {
    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;
    String cnfpassword = _cnfpasswordController.text;
    print("📍 Current Route: ${AppState.currentRoute}");
    if (username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        cnfpassword.isEmpty) {
      Get.snackbar(
        "Error",
        "All fields are required!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
      return;
    }

    controller.signup(username, email, password, cnfpassword);
  }
}
