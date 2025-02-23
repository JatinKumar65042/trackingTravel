import 'package:flutter/material.dart';

class Location extends StatefulWidget {
  const Location({super.key});

  @override
  State<Location> createState() => _LocationState();
}

class _LocationState extends State<Location> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            //i need to create this page so that whenever user clicks on search your destination
            //on my home page it will take me to this page
            //features i need is to be able to mark positions and polyline be
          ],
        ),
      ),
    );
  }
}
