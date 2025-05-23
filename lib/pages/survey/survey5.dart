import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../services/shared_pref.dart';

class Survey5 extends StatefulWidget {
  Survey5({super.key});

  @override
  _Survey5State createState() => _Survey5State();
}

class _Survey5State extends State<Survey5> {
  String? selectedOption;
  String? myid = "";
  String? name="";
  getthesharedpref()async{
    name = await SharedPreferenceHelper().getUserDisplayName();
    myid = await SharedPreferenceHelper().getUserId();
    setState(() {

    });
  }
  @override
  void initState() {
    getthesharedpref();
    super.initState();
  }

  final List<Map<String, String>> transportOptions = [
    {
      "mode": "E-Rickshaw",
      "travel_time": "25 min",
      "access_time": "5 min",
      "cost": "Rs 100 per passenger",
      "crowding": "Seats available only beside driver"
    },
    {
      "mode": "Cycle",
      "travel_time": "65 min",
      "access_time": "0 min",
      "cost": "Rs. 0",
      "crowding": "Not Applicable"
    },
    {
      "mode": "Walking",
      "travel_time": "75 min",
      "access_time": "0 min",
      "cost": "Rs. 0",
      "crowding": "Not Applicable"
    },
    {
      "mode": "Own Car",
      "travel_time": "30 min",
      "access_time": "10 min",
      "cost": "Rs 500",
      "crowding": "Not Applicable"
    },
    {
      "mode": "Two-Wheeler",
      "travel_time": "45 min",
      "access_time": "2 min",
      "cost": "Rs 100",
      "crowding": "Not Applicable"
    },
    {
      "mode": "Bus",
      "travel_time": "35 min",
      "access_time": "10 min",
      "cost": "Rs 40 per passenger",
      "crowding": "Standing with many people"
    }
  ];

  void saveSelection(String surveyField) async {
    if (selectedOption != null) {
      if (myid == null || myid!.isEmpty) {
        print("Error: userId is null or empty!");
        return;
      }

      try {
        // ✅ Store the survey response in "surveys" collection
        await FirebaseFirestore.instance.collection('surveys').doc(myid).set({
          'id': myid,
          surveyField: selectedOption, // ✅ Store last survey response
          'timestamp': Timestamp.now(),
        }, SetOptions(merge: true));

        // ✅ Mark survey as completed in Firestore (users collection)
        await FirebaseFirestore.instance.collection('users').doc(myid).update({
          'surveyCompleted': true, // ✅ Mark survey as completed
        });

        // ✅ Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Survey Completed Successfully!')),
        );

        // ✅ Navigate to home page
        Future.delayed(Duration(seconds: 1), () {
          Get.offAllNamed('/home'); // ✅ Redirect to Home Page
        });

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving survey! $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a transport mode!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Survey(5/5)",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Select Transportation Mode",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.purpleAccent,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16),
              children:
              transportOptions.map((option) {
                return Card(
                  color: Colors.grey[900],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(
                      option['mode']!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Travel Time: ${option['travel_time']}",
                          style: TextStyle(color: Colors.white70),
                        ),
                        Text(
                          "Access Time: ${option['access_time']}",
                          style: TextStyle(color: Colors.white70),
                        ),
                        Text(
                          "Cost: ${option['cost']}",
                          style: TextStyle(color: Colors.purpleAccent),
                        ),
                        Text(
                          "Crowding: ${option['crowding']}",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                    trailing: Radio<String>(
                      value: option['mode']!,
                      groupValue: selectedOption,
                      onChanged: (value) {
                        setState(() {
                          selectedOption = value;
                        });
                      },
                      activeColor: Colors.purpleAccent,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purpleAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                onPressed: () => saveSelection('survey5_mode'),
                child: Text(
                  "Save",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
