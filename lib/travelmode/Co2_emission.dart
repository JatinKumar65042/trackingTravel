import 'package:flutter/material.dart';
import 'package:tracker/tracking/location.dart'; // Import your location selection page

class Co2Emission extends StatefulWidget {
  final String selectedTransport;
  const Co2Emission({super.key, required this.selectedTransport});

  @override
  State<Co2Emission> createState() => _Co2EmissionState();
}

class _Co2EmissionState extends State<Co2Emission>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();

    // Animation for fade-in effect
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _fadeInAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // CO₂ emission values based on transport mode
    Map<String, double> co2Emissions = {
      'Car': 120.0,
      '2/3-Wheeler': 20.0,
      'Bus': 80.0,
      'Train': 40.0,
      'Walking': 0.0,
      'Bicycle': 0.0,
      'Flight': 250.0,
    };

    // Transport images (Replace with actual URLs)
    Map<String, String> transportImages = {
      'Car': "https://cdn-icons-png.flaticon.com/512/741/741407.png",
      'Bike': "https://cdn-icons-png.flaticon.com/512/2972/2972185.png",
      'Bus': "https://cdn-icons-png.flaticon.com/512/2906/2906276.png",
      'Train': "https://cdn-icons-png.flaticon.com/512/1995/1995574.png",
      'Plane': "https://cdn-icons-png.flaticon.com/512/2846/2846200.png",
      'Walking': "https://cdn-icons-png.flaticon.com/512/1041/1041884.png",
    };

    double emission = co2Emissions[widget.selectedTransport] ?? 0.0;
    String imageUrl = transportImages[widget.selectedTransport] ?? "";

    return Scaffold(
      appBar: AppBar(
        title: Text("CO₂ Emissions"),
        backgroundColor: Colors.blue,
      ),
      body: FadeTransition(
        opacity: _fadeInAnimation,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Display Transport Image
              if (imageUrl.isNotEmpty)
                Image.network(
                  imageUrl,
                  height: 150,
                  width: 150,
                  fit: BoxFit.cover,
                ),

              SizedBox(height: 20),

              // Transport Mode Text
              Text(
                "Selected Transport: ${widget.selectedTransport}",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),

              SizedBox(height: 20),

              // CO₂ Emission Value
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.blue, width: 1.5),
                ),
                child: Column(
                  children: [
                    Text(
                      "${emission.toStringAsFixed(2)} grams per kilometer",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      emission == 0.0
                          ? "Great! No CO₂ emissions for this mode."
                          : "Try eco-friendly options to reduce CO₂ emissions.",
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 40),

              // Next Button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              LocationSelectionPage(), // Navigate to location page
                    ),
                  );
                },
                icon: Icon(Icons.arrow_forward),
                label: Text("Next", style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
