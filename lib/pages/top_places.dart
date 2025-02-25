import 'package:flutter/material.dart';

class TopPlaces extends StatefulWidget {
  const TopPlaces({super.key});

  @override
  State<TopPlaces> createState() => _TopPlacesState();
}

class _TopPlacesState extends State<TopPlaces> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        margin: EdgeInsets.only(top: 50),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Row(
                children: [
                  // for back arrow button
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, "/home"); // Navigate to "/me" route
                    },
                    child: Material(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // text placement for top places
                  SizedBox(width: MediaQuery.of(context).size.width / 5.5),
                  Text(
                    "Top Places",
                    style: TextStyle(
                      color: Colors.blue,
                      fontFamily: 'Gilroy-Italic',
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // SizedBox(height: 30),

            //expanded used to resolve size of box and image(material widget was overlapping container widget
            Expanded(
              child: Material(
                elevation: 3.0,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                child: Container(
                  //padding to images in same row
                  padding: (EdgeInsets.only(left:10, top: 30, right:10)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  width: MediaQuery.of(context).size.width,

                  //wrapping column to extend page so that user can scroll
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                    
                        //using row widget to put images in row together
                        Row(
                          //spacing between two top places in same row
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Ensures equal spacing
                          children: [
                            Flexible(
                              child: Material(
                                elevation: 3.0,
                                borderRadius: BorderRadius.circular(20),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.asset(
                                        "images/India.jpg",
                                        height: 250, // Reduced height
                                        width: 160,  // Reduced width
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      child: Container(
                                        width: 160,
                                        decoration: BoxDecoration(
                                          color: Colors.black26,
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(20),
                                            bottomRight: Radius.circular(20),
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "INDIA",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'Gilroy-Italic',
                                              fontSize: 24.0, // Slightly smaller font
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(width: 10), // Adds spacing between images

                            Flexible(
                              child: Material(
                                elevation: 3.0,
                                borderRadius: BorderRadius.circular(20),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.asset(
                                        "images/Italy.jpg",
                                        height: 250,
                                        width: 160,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      child: Container(
                                        width: 160,
                                        decoration: BoxDecoration(
                                          color: Colors.black26,
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(20),
                                            bottomRight: Radius.circular(20),
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "ITALY",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'Gilroy-Italic',
                                              fontSize: 24.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                    
                        //using row widget to put images in row together
                        Row(
                          //spacing between two top places in same row
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Ensures equal spacing
                          children: [
                            Flexible(
                              child: Material(
                                elevation: 3.0,
                                borderRadius: BorderRadius.circular(20),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.asset(
                                        "images/France.jpg",
                                        height: 250, // Reduced height
                                        width: 160,  // Reduced width
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      child: Container(
                                        width: 160,
                                        decoration: BoxDecoration(
                                          color: Colors.black26,
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(20),
                                            bottomRight: Radius.circular(20),
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "FRANCE",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'Gilroy-Italic',
                                              fontSize: 24.0, // Slightly smaller font
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(width: 10), // Adds spacing between images

                            Flexible(
                              child: Material(
                                elevation: 3.0,
                                borderRadius: BorderRadius.circular(20),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.asset(
                                        "images/China.jpg",
                                        height: 250,
                                        width: 160,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      child: Container(
                                        width: 160,
                                        decoration: BoxDecoration(
                                          color: Colors.black26,
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(20),
                                            bottomRight: Radius.circular(20),
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "CHINA",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'Gilroy-Italic',
                                              fontSize: 24.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                    
                        //using row widget to put images in row together
                        Row(
                          //spacing between two top places in same row
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Ensures equal spacing
                          children: [
                            Flexible(
                              child: Material(
                                elevation: 3.0,
                                borderRadius: BorderRadius.circular(20),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.asset(
                                        "images/Disney.jpg",
                                        height: 250, // Reduced height
                                        width: 160,  // Reduced width
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      child: Container(
                                        width: 160,
                                        decoration: BoxDecoration(
                                          color: Colors.black26,
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(20),
                                            bottomRight: Radius.circular(20),
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "HONG KONG",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'Gilroy-Italic',
                                              fontSize: 24.0, // Slightly smaller font
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(width: 10), // Adds spacing between images

                            Flexible(
                              child: Material(
                                elevation: 3.0,
                                borderRadius: BorderRadius.circular(20),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.asset(
                                        "images/NewYork.jpg",
                                        height: 250,
                                        width: 160,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      child: Container(
                                        width: 160,
                                        decoration: BoxDecoration(
                                          color: Colors.black26,
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(20),
                                            bottomRight: Radius.circular(20),
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "NEW YORK",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'Gilroy-Italic',
                                              fontSize: 24.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height:50.0,),
                      ],
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
