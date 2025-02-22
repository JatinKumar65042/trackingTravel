import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(

          //to put all containers to start from left
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [

                //background top image valley
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

                      //option to check for different destinations around the world
                      Material(
                        elevation: 5.0,
                        //padding border
                        borderRadius: BorderRadius.circular(100),
                        child: Container(
                          //all for padding
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

                      //space between small containers
                      Spacer(),

                      //adding reached destination button
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

                      //profile icon
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
                Container(
                  margin: EdgeInsets.only(
                    left: 30,
                    right: 30,
                    top: MediaQuery.of(context).size.height / 3,
                  ),
                  child: Material(
                    elevation: 5,
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      padding: EdgeInsets.only(left: 20, top: 7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(width: 1.5),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "search your destination",
                          suffixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 40.0),
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
                  // margin: EdgeInsets.only(left: 30, right: 30),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0, left: 20.0),
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
                            SizedBox(height: 15),
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Text(
                                "ROUNAK SAINI",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Gilroy-Light',
                                  fontSize: 25.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12),
                      Image.asset("images/Mandir.jpg"),
                      SizedBox(height: 5),
                      // putting the location icon to know the location of place
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.blue),
                            Text(
                              "Kashi Vishwanath Temple,Varanasi",
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'Gilroy-dark',
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Text(
                          "One of the historical moments in my life was i witnessed the KVT",
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Gilroy-Italic',
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
                            SizedBox(width: 50),
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
    );
  }
}
