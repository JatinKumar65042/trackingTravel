import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tracker/pages/login.dart';
import 'package:tracker/services/route_observer.dart';

import '../controller/auth_controller.dart';

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
    return Scaffold(
      resizeToAvoidBottomInset:
          true, // Ensures UI adjusts when keyboard appears
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset("images/login.jpg"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "WAY TO GO!",
                    style: TextStyle(
                      color: Color.fromARGB(189, 180, 180, 225),
                      fontSize: 70,
                      fontFamily: 'LondrinaSketch-Regular',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 30),
                  buildTextField("Name", _usernameController, Icons.person),
                  buildTextField("Email", _emailController, Icons.email),
                  buildTextField(
                    "Password",
                    _passwordController,
                    Icons.lock,
                    obscureText: true,
                  ),
                  buildTextField(
                    "Confirm Password",
                    _cnfpasswordController,
                    Icons.lock,
                    obscureText: true,
                  ),
                  SizedBox(height: 30),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => signup(),
                        child: Container(
                          margin: EdgeInsets.only(left: 70),
                          width: 140,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.white,
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
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already Have An Account? ",
                        style: TextStyle(
                          color: Color.fromARGB(157, 255, 255, 255),
                          fontSize: 15,
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
                            fontSize: 17,
                            fontFamily: 'Gilroy-Light',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
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
    IconData icon, {
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontFamily: 'Gilroy-Light',
            fontWeight: FontWeight.w600,
          ),
        ),
        TextField(
          controller: controller,
          obscureText: obscureText,
          style: TextStyle(
            color: Colors.white,
          ), // Changing input text color to white
          decoration: InputDecoration(
            hintText: "Enter $label Here",
            hintStyle: TextStyle(color: Colors.white54),
            suffixIcon: Icon(icon, color: Colors.white),
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  signup() {
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
