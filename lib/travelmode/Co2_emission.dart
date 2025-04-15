import 'package:flutter/material.dart';
import 'package:tracker/tracking/location.dart';
import 'package:tracker/pages/journey_summary.dart';
import 'package:tracker/services/location_service.dart';

class Co2Emission extends StatefulWidget {
  final String selectedTransport;
  const Co2Emission({super.key, required this.selectedTransport});

  @override
  State<Co2Emission> createState() => _Co2EmissionState();
}

class _Co2EmissionState extends State<Co2Emission>
    with SingleTickerProviderStateMixin {
  int _locationUpdateCount = 0;
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
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

  void _navigateToJourneySummary() {
    if (_locationUpdateCount > 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => JourneySummary(
                selectedTransport: widget.selectedTransport,
                locationUpdateCount: _locationUpdateCount,
                co2Emission:
                    _getCo2Emissions()[widget.selectedTransport] ?? 0.0,
              ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a location first.")),
      );
    }
  }

  Map<String, double> _getCo2Emissions() {
    return {
      'Car': 120.0,
      '2/3-Wheeler': 20.0,
      'Bus': 80.0,
      'Train': 40.0,
      'Walking': 0.0,
      'Bicycle': 0.0,
      'Flight': 250.0,
    };
  }

  Map<String, String> _getTransportImages() {
    return {
      'Car': "images/car.jpg",
      'two_three_Wheeler': "images/wheeler.jpg",
      'Bus': "images/bus.jpg",
      'Train': "images/train.jpg",
      'Flight': "images/flight.jpg",
      'Walking': "images/walking.jpg",
      'Bicycle': "images/bicycle.jpg",
    };
  }

  @override
  Widget build(BuildContext context) {
    final co2Emissions = _getCo2Emissions();
    final transportImages = _getTransportImages();
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
              if (imageUrl.isNotEmpty)
                Image.asset(
                  imageUrl,
                  height: 150,
                  width: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.image_not_supported,
                      size: 100,
                      color: Colors.grey,
                    );
                  },
                ),
              SizedBox(height: 20),
              Text(
                "Selected Transport: ${widget.selectedTransport}",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 20),
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
              SizedBox(height: 20),
              // Add instruction card to guide the user
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.amber, width: 1.5),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.amber[800],
                      size: 28,
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Next Steps:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber[800],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "1. Click the 'Next' button below to select your route on the map\n2. After selecting your destination, the 'View Journey Summary' button will be enabled",
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // Make the Next button more prominent with animation
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                transform: Matrix4.translationValues(0, _isLoading ? 5 : 0, 0),
                child: ElevatedButton.icon(
                  onPressed:
                      _isLoading
                          ? null
                          : () async {
                            try {
                              setState(() {
                                _isLoading = true;
                              });

                              // Set the transport mode in LocationService
                              LocationService.setTransportMode(
                                widget.selectedTransport,
                              );
                              await LocationService.storeFirstLocation();

                              // Navigate to location page first
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LocationSelectionPage(),
                                ),
                              );

                              if (!mounted) return;

                              if (result != null && result is int) {
                                setState(() {
                                  _locationUpdateCount = result;
                                });
                                // Show success message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Route selected successfully! You can now view your journey summary.',
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('An error occurred: $e'),
                                ),
                              );
                            } finally {
                              if (mounted) {
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                            }
                          },
                  icon: Icon(Icons.navigation, size: 24),
                  label: Text(
                    "Select Route on Map",
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // Bottom navigation bar with improved UI and explanation
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton.icon(
                    onPressed:
                        _locationUpdateCount > 0
                            ? _navigateToJourneySummary
                            : null,
                    icon: Icon(Icons.summarize),
                    label: Text("View Journey Summary"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  if (_locationUpdateCount == 0)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                      child: Text(
                        "⚠️ Select a route first using the button above",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[800],
                          fontStyle: FontStyle.italic,
                        ),
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
}
