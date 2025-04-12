import 'package:flutter/material.dart';
import 'package:tracker/models/user_xp.dart';
import 'package:share_plus/share_plus.dart';

class JourneySummary extends StatefulWidget {
  final String selectedTransport;
  final int locationUpdateCount; // Number of updates sent to Firebase
  final double co2Emission; // Emission per km in grams

  const JourneySummary({
    Key? key,
    required this.selectedTransport,
    required this.locationUpdateCount,
    required this.co2Emission,
  }) : super(key: key);

  @override
  State<JourneySummary> createState() => _JourneySummaryState();
}

class _JourneySummaryState extends State<JourneySummary> {
  bool _pointsAwarded = false;

  // Convert update count to distance in km (each update ~10 meters)
  double get distanceKm => (widget.locationUpdateCount * 10) / 1000.0;

  @override
  void initState() {
    super.initState();
    _awardXpPoints();
  }

  void _awardXpPoints() async {
    if (!_pointsAwarded) {
      await UserXP.addPointsForTrip(
        widget.selectedTransport,
        widget.locationUpdateCount,
      );
      setState(() {
        _pointsAwarded = true;
      });
    }
  }

  double calculateCalories() {
    Map<String, double> caloriesPerKm = {
      'Walking': 60.0,
      'Bicycle': 30.0,
      'Car': 0.0,
      'Bus': 0.0,
      'Train': 0.0,
      'Flight': 0.0,
      '2/3-Wheeler': 0.0,
    };

    return (caloriesPerKm[widget.selectedTransport] ?? 0.0) * distanceKm;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journey Summary'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Journey Statistics',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
            SizedBox(height: 30),

            _buildInfoCard(
              icon: Icons.directions,
              title: 'Transport Mode',
              value: widget.selectedTransport,
              color: Colors.blue[100]!,
            ),
            SizedBox(height: 20),

            _buildInfoCard(
              icon: Icons.route,
              title: 'Distance Traveled',
              value: '${distanceKm.toStringAsFixed(2)} km',
              color: Colors.green[100]!,
            ),
            SizedBox(height: 20),

            _buildInfoCard(
              icon: Icons.cloud_outlined,
              title: 'CO₂ Emissions',
              value:
                  '${(widget.co2Emission * distanceKm).toStringAsFixed(2)} grams',
              color: Colors.orange[100]!,
            ),
            SizedBox(height: 20),

            if (calculateCalories() > 0)
              _buildInfoCard(
                icon: Icons.local_fire_department,
                title: 'Calories Burned',
                value: '${calculateCalories().toStringAsFixed(0)} cal',
                color: Colors.red[100]!,
              ),

            SizedBox(height: 40),

            _buildEnvironmentalMessage(),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  final distance = distanceKm.toStringAsFixed(2);
                  final emission = (widget.co2Emission * distanceKm)
                      .toStringAsFixed(2);

                  Share.share(
                    '🚶 I just traveled $distance km using ${widget.selectedTransport} '
                    'and emitted only $emission g of CO₂! 🌍\n\n'
                    '#EcoJourney #GoGreen',
                  );
                },
                icon: Icon(Icons.share),
                label: Text("Share My Journey"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 40, color: Colors.blue[900]),
          SizedBox(height: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                SizedBox(height: 5),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnvironmentalMessage() {
    String message;
    if (widget.selectedTransport == 'Walking' ||
        widget.selectedTransport == 'Bicycle') {
      message =
          'Great choice! Your zero-emission journey helped protect our environment. 🌱';
    } else if (widget.selectedTransport == 'Train' ||
        widget.selectedTransport == 'Bus') {
      message =
          'Using public transport is a great way to reduce your carbon footprint! 🚆';
    } else {
      message =
          'Consider using eco-friendly transport options for your next journey to reduce CO₂ emissions. 🌍';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        children: [
          Text(
            'Environmental Impact',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue[900],
            ),
          ),
          SizedBox(height: 10),
          Text(
            message,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
