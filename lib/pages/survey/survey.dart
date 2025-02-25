import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:tracker/services/shared_pref.dart';

class Survey extends StatefulWidget {
  Survey({super.key});

  @override
  _SurveyState createState() => _SurveyState();
}

class _SurveyState extends State<Survey> {
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
      "travel_time": "10 min",
      "access_time": "5 min",
      "cost": "Rs. 50 per passenger",
      "crowding": "Seats available in direction of travel",
    },
    {
      "mode": "Cycle",
      "travel_time": "30 min",
      "access_time": "0 min",
      "cost": "Rs. 0",
      "crowding": "Not Applicable",
    },
    {
      "mode": "Walking",
      "travel_time": "50 min",
      "access_time": "0 min",
      "cost": "Rs. 0",
      "crowding": "Not Applicable",
    },
    {
      "mode": "Own Car",
      "travel_time": "10 min",
      "access_time": "5 min",
      "cost": "Rs. 100",
      "crowding": "Not Applicable",
    },
    {
      "mode": "Two-Wheeler",
      "travel_time": "15 min",
      "access_time": "2 min",
      "cost": "Rs. 20",
      "crowding": "Not Applicable",
    },
    {
      "mode": "Bus",
      "travel_time": "20 min",
      "access_time": "5 min",
      "cost": "Rs. 15 per passenger",
      "crowding": "Sitting",
    },
  ];

  void saveSelection(String surveyField) async {
    if (selectedOption != null) {
      if (myid == null) {
        print("Error: userId is null or empty!");
        return;
      }

      try {
        // ✅ Store the survey response in "surveys" collection
        await FirebaseFirestore.instance.collection('surveys').doc(myid).set({
          'id':myid,
          surveyField: selectedOption, // ✅ Store each survey response
          'timestamp': Timestamp.now(), // ✅ Store timestamp for tracking
        }, SetOptions(merge: true)); // ✅ Merge instead of overwriting

        // ✅ Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selection saved: $selectedOption')),
        );

        // ✅ Navigate to next survey page
        Future.delayed(Duration(seconds: 1), () {
          Get.offNamed('/survey2'); // Change dynamically for each survey
        });

      } catch (e) {
        // ❌ Handle Firestore errors
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving selection! $e')));
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
          "Survey(1/5)",
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
                onPressed: () => saveSelection('survey1_mode'),
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
