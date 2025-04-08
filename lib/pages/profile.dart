import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tracker/pages/login.dart';
import 'package:tracker/services/location_service.dart';
import '../services/shared_pref.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? email = "";
  String? name = "";
  bool isEditingName = false;
  bool isEditingEmail = false;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  getthesharedpref() async {
    name = await SharedPreferenceHelper().getUserDisplayName();
    email = await SharedPreferenceHelper().getUserEmail();
    nameController.text = name ?? "";
    emailController.text = email ?? "";
    setState(() {});
  }

  @override
  void initState() {
    getthesharedpref();
    super.initState();
  }

  void logout() {
    // Implement logout functionality
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Logout"),
            content: Text("Are you sure you want to log out?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    await _auth.signOut(); // Firebase logout
                    Navigator.pop(context); // Close dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Logged out successfully!")),
                    );
                    String name = "", email = "", id = "";
                    await SharedPreferenceHelper().saveUserDisplayName(name);
                    await SharedPreferenceHelper().saveUserEmail(email);
                    await SharedPreferenceHelper().saveUserId(id);
                    LocationService.stopLocationTracking();
                    Navigator.pushReplacementNamed(context, "/login");
                  } catch (e) {
                    print("Error during logout: $e");
                  }
                },
                child: Text("Logout", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text("Profile", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 40),

          // Circular Avatar
          Center(
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.blueAccent,
              child: CircleAvatar(
                radius: 57,
                backgroundImage: AssetImage(
                  "images/profile.jpg",
                ), // Change image path
              ),
            ),
          ),

          SizedBox(height: 20),

          // Name
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              isEditingName
                  ? SizedBox(
                    width: 200,
                    child: TextField(
                      controller: nameController,
                      readOnly: true,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                      ),
                    ),
                  )
                  : Text(
                    name ?? "User Name",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
              SizedBox(width: 10),
              IconButton(
                icon: Icon(isEditingName ? Icons.check : Icons.edit),
                onPressed: () async {
                  if (isEditingName) {
                    // Save the changes
                    String newName = nameController.text.trim();
                    if (newName.isNotEmpty) {
                      String? userId =
                          await SharedPreferenceHelper().getUserId();
                      await FirebaseFirestore.instance
                          .collection("users")
                          .doc(userId)
                          .update({"Name": newName});
                      await SharedPreferenceHelper().saveUserDisplayName(
                        newName,
                      );
                      setState(() {
                        name = newName;
                        isEditingName = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Name updated successfully!")),
                      );
                    }
                  } else {
                    setState(() {
                      isEditingName = true;
                    });
                  }
                },
              ),
            ],
          ),

          SizedBox(height: 10),

          // Email
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              isEditingEmail
                  ? SizedBox(
                    width: 200,
                    child: TextField(
                      controller: emailController,
                      readOnly: true,
                      style: TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                      ),
                    ),
                  )
                  : Text(
                    email ?? "user@example.com",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
              SizedBox(width: 10),
              IconButton(
                icon: Icon(isEditingEmail ? Icons.check : Icons.edit),
                onPressed: () async {
                  if (isEditingEmail) {
                    // Save the changes
                    String newEmail = emailController.text.trim();
                    if (newEmail.isNotEmpty && newEmail.contains("@")) {
                      String? userId =
                          await SharedPreferenceHelper().getUserId();
                      await FirebaseFirestore.instance
                          .collection("users")
                          .doc(userId)
                          .update({"Email": newEmail});
                      await SharedPreferenceHelper().saveUserEmail(newEmail);
                      setState(() {
                        email = newEmail;
                        isEditingEmail = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Email updated successfully!")),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Please enter a valid email address"),
                        ),
                      );
                    }
                  } else {
                    setState(() {
                      isEditingEmail = true;
                    });
                  }
                },
              ),
            ],
          ),

          Spacer(),

          // Logout Button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  "Log Out",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ),

          SizedBox(height: 40),
        ],
      ),
    );
  }
}
