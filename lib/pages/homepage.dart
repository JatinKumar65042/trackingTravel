import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:tracker/travelmode/transport_selection.dart';
import 'package:tracker/travelmode/Co2_emission.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String selectedTransport = "Select Travel Mode";

  // Selecting the Travel Mode option
  Widget _buildTransportSelection() {
    List<String> transportModes = [
      "Walking",
      "Bicycle",
      "Car",
      "2/3-Wheeler",
      "Bus",
      "Train",
      "Flight",
    ];

    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Select Travel Mode",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Divider(),
          Column(
            children: transportModes.map((mode) {
              return ListTile(
                title: Text(mode),
                onTap: () {
                  setState(() {
                    selectedTransport = mode;
                  });
                  Navigator.pop(context);  // Close the transport selection dialog
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          // To align all containers from the left
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                // Background top image valley
                Image.asset(
                  "images/valley.jpg",
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 2.75,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    top: 40.0,
                    right: 20.0,
                  ),
                  child: Row(
                    children: [
                      // Destination button
                      Material(
                        elevation: 5.0,
                        borderRadius: BorderRadius.circular(100),
                        child: Container(
                          padding: EdgeInsets.all(7.5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Image.asset(
                            "images/destination.jpg",
                            height: 38,
                            width: 38,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Spacer(),
                      // Add destination button
                      Material(
                        elevation: 5.0,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.add, color: Colors.blue, size: 30),
                        ),
                      ),
                      SizedBox(width: 10),
                      // Profile icon
                      Material(
                        elevation: 5.0,
                        borderRadius: BorderRadius.circular(60),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: Image.asset(
                            "images/profile.jpg",
                            height: 60,
                            width: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Quote on background
                Padding(
                  padding: const EdgeInsets.only(top: 145.0, left: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Fun One!              Travel Done",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'PlayfairDisplay-VariableFont_wght',
                          fontSize: 40.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "-Travelling Community",
                        style: TextStyle(
                          color: Color.fromARGB(205, 255, 255, 255),
                          fontFamily: 'Gilroy-Light',
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),


                // Mode of Travel Selection
                Container(
                  margin: EdgeInsets.only(
                    left: 30,
                    right: 30,
                    top: MediaQuery.of(context).size.height / 3,
                  ),
                  child: Material(
                    elevation: 5,
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.transparent,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(width: 1.5),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedTransport,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(10),
                                  ),
                                ),
                                builder: (context) {
                                  return _buildTransportSelection();
                                },
                              );
                            },
                            child: Icon(Icons.keyboard_arrow_down),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),


            // Add "Next" button after selecting a transport mode
            if (selectedTransport != "Select Travel Mode")
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to the CO₂ Emission page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Co2Emission(
                          selectedTransport: selectedTransport,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text("Next"),
                ),
              ),
          ],
        ),
      ),
    );
  }
}