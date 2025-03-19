import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class LocationSelectionPage extends StatefulWidget {
  const LocationSelectionPage({super.key});

  @override
  LocationSelectionPageState createState() => LocationSelectionPageState();
}

class LocationSelectionPageState extends State<LocationSelectionPage> {
  LatLng? fromLocation;
  LatLng? toLocation;
  double? distance;
  List<LatLng> routePoints = [];

  final MapController _mapController = MapController();
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  List<Map<String, dynamic>> fromSuggestions = [];
  List<Map<String, dynamic>> toSuggestions = [];

  final String orsApiKey =
      "5b3ce3597851110001cf624876be9231122f4a5ba3dfa0adad8f4f0b"; // Get from ORS

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );

    setState(() {
      fromLocation = LatLng(position.latitude, position.longitude);
      _fromController.text = "Current Location";
      _mapController.move(fromLocation!, 14.0);
    });
  }

  Future<void> _fetchRoute() async {
    if (fromLocation == null || toLocation == null) return;

    final url = Uri.parse(
      "https://api.openrouteservice.org/v2/directions/driving-car?api_key=$orsApiKey&start=${fromLocation!.longitude},${fromLocation!.latitude}&end=${toLocation!.longitude},${toLocation!.latitude}",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> coordinates =
          data["features"][0]["geometry"]["coordinates"];

      List<LatLng> newRoutePoints =
          coordinates.map((coord) => LatLng(coord[1], coord[0])).toList();

      setState(() {
        routePoints = newRoutePoints;
      });
    } else {
      debugPrint("Error fetching route: ${response.body}");
    }
  }

  void _updateDistance() {
    if (fromLocation != null && toLocation != null) {
      final Distance distanceCalc = Distance();
      setState(() {
        distance = distanceCalc.as(
          LengthUnit.Kilometer,
          fromLocation!,
          toLocation!,
        );
      });
    }
  }

  void _setLocation(LatLng point, bool isFrom) {
    setState(() {
      if (isFrom) {
        fromLocation = point;
        _reverseGeocode(point, _fromController);
      } else {
        toLocation = point;
        _reverseGeocode(point, _toController);
      }
      _updateDistance();
      _fetchRoute();
    });
  }

  Future<void> _reverseGeocode(
    LatLng point,
    TextEditingController controller,
  ) async {
    final url = Uri.parse(
      "https://nominatim.openstreetmap.org/reverse?format=json&lat=${point.latitude}&lon=${point.longitude}",
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        controller.text = data["display_name"];
      });
    } else {
      debugPrint("Error fetching address");
    }
  }

  Future<void> _searchLocation(String query, bool isFrom) async {
    if (query.isEmpty) return;

    final url = Uri.parse(
      "https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=5",
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> results = json.decode(response.body);
      setState(() {
        if (isFrom) {
          fromSuggestions =
              results
                  .map(
                    (place) => {
                      "name": place["display_name"],
                      "lat": double.parse(place["lat"]),
                      "lon": double.parse(place["lon"]),
                    },
                  )
                  .toList();
        } else {
          toSuggestions =
              results
                  .map(
                    (place) => {
                      "name": place["display_name"],
                      "lat": double.parse(place["lat"]),
                      "lon": double.parse(place["lon"]),
                    },
                  )
                  .toList();
        }
      });
    } else {
      debugPrint("Error fetching address");
    }
  }

  void _selectLocation(Map<String, dynamic> place, bool isFrom) {
    LatLng selectedLatLng = LatLng(place["lat"], place["lon"]);

    setState(() {
      if (isFrom) {
        fromLocation = selectedLatLng;
        _fromController.text = place["name"];
        fromSuggestions = [];
      } else {
        toLocation = selectedLatLng;
        _toController.text = place["name"];
        toSuggestions = [];
      }
      _updateDistance();
      _fetchRoute();
    });

    _mapController.move(selectedLatLng, 14.0);
  }

  void _removeMarker(bool isFrom) {
    setState(() {
      if (isFrom) {
        fromLocation = null;
        _fromController.clear();
        fromSuggestions = [];
      } else {
        toLocation = null;
        _toController.clear();
        toSuggestions = [];
      }
      routePoints.clear();
      distance = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset : false,
      appBar: AppBar(title: Text("Select Your Location")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                _buildSearchBar(_fromController, true),
                SizedBox(height: 10),
                _buildSearchBar(_toController, false),
                SizedBox(height: 10),
                if (distance != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Distance: ${distance!.toStringAsFixed(2)} km",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter:
                    fromLocation ??
                    LatLng(20.5937, 78.9629), // Default to India
                initialZoom: 10.0,
                onTap: (tapPosition, point) {
                  if (fromLocation == null) {
                    _setLocation(point, true);
                  } else {
                    _setLocation(point, false);
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                if (fromLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: fromLocation!,
                        width: 40,
                        height: 40,
                        child: Icon(
                          // Moved child to last
                          Icons.location_on,
                          color: Colors.blue,
                          size: 40,
                        ),
                      ),
                    ],
                  ),

                if (toLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: fromLocation!,
                        width: 40,
                        height: 40,
                        child: Icon(
                          // Moved child to last
                          Icons.location_on,
                          color: Colors.blue,
                          size: 40,
                        ),
                      ),
                    ],
                  ),

                if (routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: routePoints,
                        color: Colors.blue,
                        strokeWidth: 4.0,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
      // ADD THIS FLOATING ACTION BUTTON HERE
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _removeMarker(true);
          _removeMarker(false);
        },
        backgroundColor: Colors.red,
        child: Icon(Icons.delete), // Moved child to last
      ),
    );
  }

  Widget _buildSearchBar(TextEditingController controller, bool isFrom) {
    return Column(
      children: [
        TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: isFrom ? "From Location" : "To Destination",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.search),
            contentPadding: EdgeInsets.symmetric(
              vertical: 10.0,
              horizontal: 15.0,
            ),
          ),
          onChanged: (value) => _searchLocation(value, isFrom),
        ),
        if ((isFrom ? fromSuggestions.isNotEmpty : toSuggestions.isNotEmpty))
          Column(
            children: List.generate(
              isFrom ? fromSuggestions.length : toSuggestions.length,
              (index) {
                var place =
                    isFrom ? fromSuggestions[index] : toSuggestions[index];
                return ListTile(
                  title: Text(place["name"]),
                  onTap:
                      () => _selectLocation(
                        place,
                        isFrom,
                      ), // CALL _selectLocation HERE
                );
              },
            ),
          ),
      ],
    );
  }
}
