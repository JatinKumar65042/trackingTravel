import 'package:flutter/material.dart';
import 'package:tracker/services/permission_service.dart';
import 'package:tracker/travelmode/Co2_emission.dart';
import 'package:tracker/services/Notice_board_service.dart';
import 'package:tracker/services/Li_Chi.dart';
import 'package:tracker/services/Kno_call.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String selectedTransport = "Select Travel Mode";
  bool showNextButton = false;
  int _selectedIndex = 0; // Bottom Navigation Bar Index

  @override
  void initState() {
    super.initState();
    // Request location permissions when the app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PermissionService.requestLocationPermission(context);
    });
  }

  void _selectTransportMode(String mode) {
    setState(() {
      selectedTransport = mode;
      showNextButton = mode != "None";
    });
    Navigator.pop(context);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NoticeBoard()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LiChiChat()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => KnoCollChat()),
        );
        break;
    }
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
                  transportModes
                      .map(
                        (mode) => ListTile(
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
                        ),
                      )
                      .toList(),
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
                  child: Container(
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
                            Icon(Icons.keyboard_arrow_down),
                          ],
                        ),
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
                SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      "/me",
                    ); // Navigate to "/me" route
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

      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notice Board',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Li-Chi'),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy),
            label: 'KnO-Coll',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildIcon(IconData icon, String label, String route) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Column(
        children: [
          Icon(icon, size: 40, color: Colors.blue),
          SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
