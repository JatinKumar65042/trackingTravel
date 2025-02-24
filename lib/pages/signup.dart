import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tracker/pages/login.dart';

import '../controller/auth_controller.dart';

class SignUp extends StatefulWidget {

  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  AuthController controller = Get.find() ;
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _cnfpasswordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset : false,
      backgroundColor: Colors.black,
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset("images/login.jpg"),
            Padding(
              padding: const EdgeInsets.only(left: 60.0, right: 60.0),
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
                  // Text(
                  //   "LogIn",
                  //   style: TextStyle(
                  //     color: Colors.white,
                  //     fontSize: 45,
                  //     fontFamily: 'Gilroy-Light',
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                  SizedBox(height: 30),
                  Text(
                    "Name",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontFamily: 'Gilroy-Light',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      hintText: "Enter Name Here",
                      hintStyle: TextStyle(color: Colors.white54),
                      suffixIcon: Icon(Icons.person, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Email",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontFamily: 'Gilroy-Light',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: "Enter Email Here",
                      hintStyle: TextStyle(color: Colors.white54),
                      suffixIcon: Icon(Icons.email, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 30),
                  Text(
                    "Password ",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontFamily: 'Gilroy-Light',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      hintText: "Enter Password Here ",
                      hintStyle: TextStyle(color: Colors.white54),
                      suffixIcon: Icon(Icons.password, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Confirm Password",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontFamily: 'Gilroy-Light',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextField(
                    controller: _cnfpasswordController,
                    decoration: InputDecoration(
                      hintText: "Confirm Password Here",
                      hintStyle: TextStyle(color: Colors.white54),
                      suffixIcon: Icon(Icons.password, color: Colors.white),
                    ),
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
                        "Already Have An Account ? ",
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
  signup(){
    String username = _usernameController.text;
    String email = _emailController.text ;
    String password = _passwordController.text;
    String cnfpassword = _cnfpasswordController.text;

    if (username.isEmpty || email.isEmpty || password.isEmpty || cnfpassword.isEmpty) {
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

    controller.signup(username , email, password , cnfpassword) ;
  }
}
