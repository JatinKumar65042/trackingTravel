import 'package:flutter/material.dart';
import 'package:tracker/travelmode/Co2_emission.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String selectedTransport = "Select Travel Mode";
  bool showNextButton = false;

  void _selectTransportMode(String mode) {
    setState(() {
      selectedTransport = mode;
      showNextButton = mode != "None";
    });
    Navigator.pop(context);
  }

  Widget _buildTransportSelection() {
    List<String> transportModes = [
      "None",
      "Walking",
      "Bicycle",
      "Car",
      "2/3-Wheeler",
      "Bus",
      "Train",
      "Flight",
    ];

    return SingleChildScrollView(
      child: Container(
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
              children:
              transportModes.map((mode) {
                return ListTile(
                  title: Text(
                    mode,
                    style: TextStyle(
                      color: mode == "None" ? Colors.red : Colors.black,
                      fontWeight:
                      mode == "None"
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  onTap: () => _selectTransportMode(mode),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // **Scrollable Content**
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // **Valley Image with Overlay Text**
                Stack(
                  children: [
                    Image.asset(
                      "images/valley.jpg",
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 2.75,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      bottom: 20,
                      left: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Fun One!\nTravel Done",
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'PlayfairDisplay-VariableFont_wght',
                              fontSize: 35.0,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  blurRadius: 4.0,
                                  color: Colors.black38,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            "-Travelling Community",
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Gilroy-Light',
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  blurRadius: 4.0,
                                  color: Colors.black38,
                                  offset: Offset(1, 1),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // **Mode of Travel Selection**
                Container(
                  margin: EdgeInsets.only(left: 30, right: 30, top: 30),
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
                                isScrollControlled: true,
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

                if (showNextButton) SizedBox(height: 20),
                if (showNextButton)
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => Co2Emission(
                              selectedTransport: selectedTransport,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        "Next",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),

                SizedBox(height: 20),

                // **User Post Section**
                Container(
                  margin: EdgeInsets.only(left: 30, right: 30),
                  child: Material(
                    elevation: 3.0,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 20.0,
                              left: 20.0,
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: Image.asset(
                                    "images/avatar.jpg",
                                    height: 50,
                                    width: 50,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "ROUNAK SAINI",
                                  style: TextStyle(
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 12),
                          Image.asset("images/Mandir.jpg"),
                          SizedBox(height: 5),
                          ListTile(
                            leading: Icon(
                              Icons.location_on,
                              color: Colors.blue,
                            ),
                            title: Text(
                              "Kashi Vishwanath Temple, Varanasi",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              "Historical moment in my life was , I witnessed the KVT",
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.favorite_outline,
                                  color: Colors.black54,
                                  size: 35,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "Like",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Gilroy-Italic',
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(width: 100),
                                Icon(
                                  Icons.comment_outlined,
                                  color: Colors.black54,
                                  size: 28,
                                ),
                                SizedBox(width: 10),

                                Text(
                                  "Comment",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Gilroy-Italic',
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // **Static Icons**
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, "/top_places");
                  },
                  child: Material(
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
                ),
                Spacer(),
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
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, "/me"); // Navigate to "/me" route
                  },
                  child: Material(
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}