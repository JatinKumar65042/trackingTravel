import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tracker/pages/login.dart';
import '../services/shared_pref.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? email = "";
  String? name="";
  getthesharedpref()async{
    name = await SharedPreferenceHelper().getUserDisplayName();
    email = await SharedPreferenceHelper().getUserEmail();
    setState(() {

    });
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
      builder: (context) => AlertDialog(
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
                String name = "" ,email = "", id = "";
                await SharedPreferenceHelper().saveUserDisplayName(name);
                await SharedPreferenceHelper().saveUserEmail(email);
                await SharedPreferenceHelper().saveUserId(id);
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
                backgroundImage: AssetImage("images/profile.jpg"), // Change image path
              ),
            ),
          ),

          SizedBox(height: 20),

          // Name
          Text(
            name ?? "User Name",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          // Email
          Text(
            email ?? "user@example.com",
            style: TextStyle(fontSize: 16, color: Colors.grey),
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
