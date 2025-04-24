import 'package:flutter/material.dart';

class TopPlaces extends StatefulWidget {
  const TopPlaces({Key? key}) : super(key: key);

  @override
  State<TopPlaces> createState() => _TopPlacesState();
}

class _TopPlacesState extends State<TopPlaces> with TickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive design
    final Size screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: 22,
                      ),
                    ),
                  ),
                  Text(
                    "Top Places",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'PlayfairDisplay-VariableFont_wght',
                    ),
                  ),
                  SizedBox(width: 40),
                ],
              ),
            ),
            
            SizedBox(height: 20),
            
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.blue,
                indicatorWeight: 3,
                tabs: [
                  Tab(text: "Departments"),
                  Tab(text: "Campus"),
                ],
              ),
            ),
            
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Departments Tab
                  SingleChildScrollView(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // First row of departments
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildPlaceCard(
                              image: "images/cse.jpg",
                              title: "CSE",
                              width: screenWidth * 0.43,
                            ),
                            _buildPlaceCard(
                              image: "images/civil.jpg",
                              title: "CIVIL",
                              width: screenWidth * 0.43,
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        
                        // Second row of departments
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildPlaceCard(
                              image: "images/mechanical.jpg",
                              title: "MECHANICAL",
                              width: screenWidth * 0.43,
                            ),
                            _buildPlaceCard(
                              image: "images/electrical.jpg",
                              title: "ELECTRICAL",
                              width: screenWidth * 0.43,
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        
                        // Third row of departments
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildPlaceCard(
                              image: "images/metallurgy.jpg",
                              title: "METALLURGY",
                              width: screenWidth * 0.43,
                            ),
                            _buildPlaceCard(
                              image: "images/mnc.jpg",
                              title: "MNC",
                              width: screenWidth * 0.43,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Campus Tab
                  SingleChildScrollView(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildFullWidthCard(
                          image: "images/library.webp",
                          title: "LIBRARY",
                          width: screenWidth - 40,
                        ),
                        SizedBox(height: 20),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildPlaceCard(
                              image: "images/wheeler.jpg",
                              title: "WHEELER",
                              width: screenWidth * 0.43,
                            ),
                            _buildPlaceCard(
                              image: "images/lankagate.jpeg",
                              title: "LANKA GATE",
                              width: screenWidth * 0.43,
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        
                        _buildFullWidthCard(
                          image: "images/ablt.png",
                          title: "ABLT",
                          width: screenWidth - 40,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPlaceCard({
    required String image,
    required String title,
    required double width,
  }) {
    return Material(
      elevation: 4.0,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: width,
        height: 200,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                image,
                width: width,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Center(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Gilroy-Light',
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFullWidthCard({
    required String image,
    required String title,
    required double width,
  }) {
    return Material(
      elevation: 4.0,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: width,
        height: 180,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                image,
                width: width,
                height: 180,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Center(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Gilroy-Light',
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
