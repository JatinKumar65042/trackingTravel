import 'package:flutter/material.dart';

class Co2Emission extends StatefulWidget {
  final String selectedTransport;

  const Co2Emission({super.key, required this.selectedTransport});

  @override
  State<Co2Emission> createState() => _Co2EmissionState();
}

class _Co2EmissionState extends State<Co2Emission> {
  @override
  Widget build(BuildContext context) {
    // CO₂ emission values based on transport mode
    Map<String, double> co2Emissions = {
      'Car': 120.0, // CO₂ emission in grams per km
      'Bike': 20.0,
      'Bus': 80.0,
    };

    double emission = co2Emissions[widget.selectedTransport] ?? 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text("CO₂ Emissions"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Selected Transport: ${widget.selectedTransport}",
              style: TextStyle(fontSize: 22),
            ),
            SizedBox(height: 20),
            Text(
              "CO₂ Emissions: ${emission.toStringAsFixed(2)} grams per kilometer",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),
            
          ],
        ),
      ),
    );
  }
}
