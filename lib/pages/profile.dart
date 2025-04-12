import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tracker/pages/login.dart';
import 'package:tracker/services/location_service.dart';
import '../services/shared_pref.dart';
import '../models/user_xp.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? email = "";
  String? name = "";
  UserXP? _userXP;
  bool _isLoadingXP = true;
  StreamSubscription<DocumentSnapshot>? _xpSubscription;

  getthesharedpref() async {
    name = await SharedPreferenceHelper().getUserDisplayName();
    email = await SharedPreferenceHelper().getUserEmail();
    setState(() {});
  }

  Future<void> _loadUserXP() async {
    setState(() {
      _isLoadingXP = true;
    });

    _userXP = await UserXP.getUserXP();

    setState(() {
      _isLoadingXP = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getthesharedpref();
    _setupXPListener();
  }

  Future<void> _setupXPListener() async {
    String? userId = await SharedPreferenceHelper().getUserId();
    if (userId == null) return;

    _xpSubscription = FirebaseFirestore.instance
        .collection('userXP')
        .doc(userId)
        .snapshots()
        .listen(
          (snapshot) {
            if (snapshot.exists) {
              setState(() {
                _userXP = UserXP.fromFirestore(snapshot);
                _isLoadingXP = false;
              });
            } else {
              setState(() {
                _userXP = UserXP.empty();
                _isLoadingXP = false;
              });
            }
          },
          onError: (error) {
            print('Error listening to XP updates: $error');
            setState(() {
              _isLoadingXP = false;
            });
          },
        );
  }

  @override
  void dispose() {
    _xpSubscription?.cancel();
    super.dispose();
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
      body: SingleChildScrollView(
        child: Column(
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
            Text(
              name ?? "User Name",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            // Email
            Text(
              email ?? "user@example.com",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),

            SizedBox(height: 30),

            // XP Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: _buildXPSection(),
            ),

            SizedBox(height: 30),

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
      ),
    );
  }

  // Build XP Section Widget
  Widget _buildXPSection() {
    if (_isLoadingXP) {
      return Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // XP Section Header
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 28),
                SizedBox(width: 10),
                Text(
                  'Travel Experience',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            // Level and Points
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Level ${_userXP?.level ?? 1}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '${_userXP?.totalPoints ?? 0} XP',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_userXP?.pointsToNextLevel ?? 100} XP to next level',
                    style: TextStyle(fontSize: 14, color: Colors.blue[800]),
                  ),
                ),
              ],
            ),

            SizedBox(height: 15),

            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value:
                    _userXP != null && _userXP!.level > 1
                        ? 1 - (_userXP!.pointsToNextLevel / 100)
                        : (_userXP?.totalPoints ?? 0) / 100,
                minHeight: 10,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            ),

            SizedBox(height: 20),

            // Trip Points Breakdown
            Text(
              'Points Breakdown',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),

            SizedBox(height: 10),

            // Trip Points List
            _userXP != null && _userXP!.tripPoints.isNotEmpty
                ? Column(children: _buildTripPointsList())
                : Container(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Center(
                    child: Text(
                      'No trips recorded yet. Start traveling to earn XP!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  // Build list of trip points
  List<Widget> _buildTripPointsList() {
    List<Widget> tripWidgets = [];

    // Sort trips by date (most recent first)
    List<MapEntry<String, int>> sortedTrips =
        _userXP!.tripPoints.entries.toList();
    sortedTrips.sort((a, b) => b.key.compareTo(a.key));

    // Take only the 5 most recent trips
    int tripsToShow = sortedTrips.length > 5 ? 5 : sortedTrips.length;

    for (int i = 0; i < tripsToShow; i++) {
      String tripId = sortedTrips[i].key;
      int points = sortedTrips[i].value;

      // Convert timestamp to date
      DateTime tripDate = DateTime.fromMillisecondsSinceEpoch(
        int.parse(tripId),
      );
      String formattedDate =
          '${tripDate.day}/${tripDate.month}/${tripDate.year}';

      tripWidgets.add(
        Padding(
          padding: EdgeInsets.symmetric(vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Trip on $formattedDate',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              Text(
                '+$points XP',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Add a "View All" option if there are more than 5 trips
    if (sortedTrips.length > 5) {
      tripWidgets.add(
        Padding(
          padding: EdgeInsets.only(top: 10),
          child: Center(
            child: TextButton(
              onPressed: () {
                // This could navigate to a detailed trips history page in the future
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Full trip history coming soon!')),
                );
              },
              child: Text(
                'View All Trips',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return tripWidgets;
  }
}
