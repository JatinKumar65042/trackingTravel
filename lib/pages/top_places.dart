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
                  Material(
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            //using stack widget to put images on top of each other and t be able to show name of places over images
                            Material(
                              elevation: 3.0,
                              borderRadius: BorderRadius.circular(20),
                              child: Stack(
                                children: [
                                  //providing border radius using clipRReact widget on Image.asset below
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.asset(
                                      "images/India.jpg",
                                      height: 300,
                                      width: 190,
                                      fit: BoxFit.cover,
                                      alignment: Alignment(-0.4, 0.0),
                                    ),
                                  ),
                                  Container(
                                    //providing margin to the container to put text over image
                                    margin: EdgeInsets.only(top: 260.0),
                                    //if ht used then india wal container goes below
                                    // height: 300,
                                    width: 190,
                                    decoration: BoxDecoration(
                                      color: Colors.black26,
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(20),
                                        bottomRight: Radius.circular(20),
                                      ),
                                    ),
                    
                                    //centering the text widget onto the image
                                    child: Center(
                                      child: Text(
                                        "INDIA",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Gilroy-Italic',
                                          fontSize: 28.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // SizedBox(width: 30.0),
                                ],
                              ),
                            ),
                    
                            //for second place
                            Material(
                              elevation: 3.0,
                              borderRadius: BorderRadius.circular(20),
                              child: Stack(
                                children: [
                                  //providing border radius using clipRReact widget on Image.asset below
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.asset(
                                      "images/Italy.jpg",
                                      height: 300,
                                      width: 190,
                                      fit: BoxFit.cover,
                                      // alignment: Alignment(-0.4, 0.0),
                                    ),
                                  ),
                                  Container(
                                    //providing margin to the container to put text over image
                                    margin: EdgeInsets.only(top: 260.0),
                                    // height: 300,
                                    width: 190,
                                    decoration: BoxDecoration(
                                      color: Colors.black26,
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(20),
                                        bottomRight: Radius.circular(20),
                                      ),
                                    ),
                    
                                    //centering the text widget onto the image
                                    child: Center(
                                      child: Text(
                                        "ITALY",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Gilroy-Italic',
                                          fontSize: 28.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // SizedBox(width: 30.0),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                    
                        //using row widget to put images in row together
                        Row(
                          //spacing between two top places in same row
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                    
                            //using stack widget to put images on top of each other and t be able to show name of places over images
                            Material(
                              elevation: 3.0,
                              borderRadius: BorderRadius.circular(20),
                              child: Stack(
                                children: [
                                  //providing border radius using clipRReact widget on Image.asset below
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.asset(
                                      "images/France.jpg",
                                      height: 300,
                                      width: 190,
                                      fit: BoxFit.cover,
                                      // alignment: Alignment(-0.4, 0.0),
                                    ),
                                  ),
                                  Container(
                                    //providing margin to the container to put text over image
                                    margin: EdgeInsets.only(top: 260.0),
                                    //if ht used then india wal container goes below
                                    // height: 300,
                                    width: 190,
                                    decoration: BoxDecoration(
                                      color: Colors.black26,
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(20),
                                        bottomRight: Radius.circular(20),
                                      ),
                                    ),
                    
                                    //centering the text widget onto the image
                                    child: Center(
                                      child: Text(
                                        "FRANCE",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Gilroy-Italic',
                                          fontSize: 28.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // SizedBox(width: 30.0),
                                ],
                              ),
                            ),
                    
                            //for second place
                            Material(
                              elevation: 3.0,
                              borderRadius: BorderRadius.circular(20),
                              child: Stack(
                                children: [
                                  //providing border radius using clipRReact widget on Image.asset below
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.asset(
                                      "images/China.jpg",
                                      height: 300,
                                      width: 190,
                                      fit: BoxFit.cover,
                                      // alignment: Alignment(-0.4, 0.0),
                                    ),
                                  ),
                                  Container(
                                    //providing margin to the container to put text over image
                                    margin: EdgeInsets.only(top: 260.0),
                                    // height: 300,
                                    width: 190,
                                    decoration: BoxDecoration(
                                      color: Colors.black26,
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(20),
                                        bottomRight: Radius.circular(20),
                                      ),
                                    ),
                    
                                    //centering the text widget onto the image
                                    child: Center(
                                      child: Text(
                                        "CHINA",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Gilroy-Italic',
                                          fontSize: 28.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // SizedBox(width: 30.0),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                    
                        //using row widget to put images in row together
                        Row(
                          //spacing between two top places in same row
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                    
                            //using stack widget to put images on top of each other and t be able to show name of places over images
                            Material(
                              elevation: 3.0,
                              borderRadius: BorderRadius.circular(20),
                              child: Stack(
                                children: [
                                  //providing border radius using clipRReact widget on Image.asset below
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.asset(
                                      "images/Disney.jpg",
                                      height: 300,
                                      width: 190,
                                      fit: BoxFit.cover,
                                      // alignment: Alignment(-0.4, 0.0),
                                    ),
                                  ),
                                  Container(
                                    //providing margin to the container to put text over image
                                    margin: EdgeInsets.only(top: 260.0),
                                    //if ht used then india wal container goes below
                                    // height: 300,
                                    width: 190,
                                    decoration: BoxDecoration(
                                      color: Colors.black26,
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(20),
                                        bottomRight: Radius.circular(20),
                                      ),
                                    ),
                    
                                    //centering the text widget onto the image
                                    child: Center(
                                      child: Text(
                                        "HONK KONG",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Gilroy-Italic',
                                          fontSize: 28.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // SizedBox(width: 30.0),
                                ],
                              ),
                            ),
                    
                            //for second place
                            Material(
                              elevation: 3.0,
                              borderRadius: BorderRadius.circular(20),
                              child: Stack(
                                children: [
                                  //providing border radius using clipRReact widget on Image.asset below
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.asset(
                                      "images/NewYork.jpg",
                                      height: 300,
                                      width: 190,
                                      fit: BoxFit.cover,
                                      // alignment: Alignment(-0.4, 0.0),
                                    ),
                                  ),
                                  Container(
                                    //providing margin to the container to put text over image
                                    margin: EdgeInsets.only(top: 260.0),
                                    // height: 300,
                                    width: 190,
                                    decoration: BoxDecoration(
                                      color: Colors.black26,
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(20),
                                        bottomRight: Radius.circular(20),
                                      ),
                                    ),
                    
                                    //centering the text widget onto the image
                                    child: Center(
                                      child: Text(
                                        "NEW YORK",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Gilroy-Italic',
                                          fontSize: 28.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // SizedBox(width: 30.0),
                                ],
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
