import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tracker/services/location_service.dart';
import 'package:tracker/services/route_observer.dart';

class LocationSelectionPage extends StatefulWidget {
  const LocationSelectionPage({super.key});

  @override
  LocationSelectionPageState createState() => LocationSelectionPageState();
}

class LocationSelectionPageState extends State<LocationSelectionPage>
    with WidgetsBindingObserver {
  bool _destinationConfirmed = false;
  bool _destinationReached = false;
  int locationUpdateCount = 0;
  LatLng? fromLocation;
  LatLng? toLocation;
  double? distance;
  List<LatLng> routePoints = [];
  // Holds the last location at which the route was fetched.
  LatLng? _lastRouteFetchLocation;
  // Threshold in meters after which the route is recalculated.
  final double _updateThreshold = 10.0;

  // Added variable to store current zoom level.
  double _currentZoom = 10.0;

  // Track initial location setup
  bool _initialLocationSet = false;

  // New loading state variable
  bool _isLoadingLocation = true;

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
    WidgetsBinding.instance.addObserver(this);
    AppState.currentRoute = '/location';
    LocationService.startLocationTracking();
    // Show toast for location fetching
    _showLocationFetchingToast();
    _startLocationUpdates();
    LocationService.startLocationTracking(); // ✅ MUST BE CALLED
  }

  void _showLocationFetchingToast() {
    Fluttertoast.showToast(
      msg: "Please wait while we are fetching your current location",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Get the previous route before assigning a new one
    String previousRoute = ModalRoute.of(context)?.settings.name ?? '/home';
    AppState.currentRoute =
        previousRoute; // Assign previous route instead of keeping /location
    LocationService.stopLocationTracking(); // Stop tracking
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint("📌 App is active again...");
      LocationService.startLocationTracking(); // Start tracking when app is in the foreground
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      debugPrint("📌 App in background, stopping tracking...");
      LocationService.stopLocationTracking(); // Stop tracking when app is in the background
    }
  }

  void _startLocationUpdates() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );

    Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position position) {
        locationUpdateCount++; // <--- increment here
        debugPrint(
          "📍 Updated Location: ${position.latitude}, ${position.longitude}",
        );
        final newLocation = LatLng(position.latitude, position.longitude);

        // Only move the map when first initializing
        if (_isLoadingLocation || !_initialLocationSet) {
          setState(() {
            fromLocation = newLocation;
            _isLoadingLocation = false;
            _initialLocationSet = true;
          });

          // Initial map centering only once when location is first obtained
          _mapController.move(newLocation, _currentZoom);
        } else {
          // Just update the marker position without moving the map
          setState(() {
            fromLocation = newLocation;
          });
        }

        // If destination is set, check if we should re-fetch route.
        if (toLocation != null) {
          if (_lastRouteFetchLocation == null) {
            _lastRouteFetchLocation = newLocation;
            _fetchRoute();
          } else {
            final double movedDistance = Distance().distance(
              _lastRouteFetchLocation!,
              newLocation,
            );
            if (movedDistance > _updateThreshold) {
              _lastRouteFetchLocation = newLocation;
              _fetchRoute();
            }

            // Check if user has reached destination when destination is confirmed
            if (_destinationConfirmed && !_destinationReached) {
              final double distanceToDestination = Distance().distance(
                newLocation,
                toLocation!,
              );

              // Consider destination reached if within 10 meters
              if (distanceToDestination < 10) {
                setState(() {
                  _destinationReached = true;
                });

                Fluttertoast.showToast(
                  msg: "Destination reached! Great job!",
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.CENTER,
                  backgroundColor: Colors.green,
                  textColor: Colors.white,
                );

                // Navigate back with the location update count
                Future.delayed(Duration(seconds: 5), () {
                  Navigator.pop(context, locationUpdateCount);
                });
              }
            }
          }
        }
      },
      onError: (error) {
        debugPrint("❌ Location Stream Error: $error");
        setState(() {
          _isLoadingLocation = false; // Hide loader in case of error
        });
        Fluttertoast.showToast(
          msg: "Error fetching location. Please check permissions.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      },
    );
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
        // Reset the last route fetch location so that new route can be fetched.
        _lastRouteFetchLocation = fromLocation;
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
        // Reset _lastRouteFetchLocation when destination is set.
        _lastRouteFetchLocation = fromLocation;
      }
      _updateDistance();
      _fetchRoute();
    });

    // We actually need to move the map for explicitly selected locations
    _mapController.move(selectedLatLng, _currentZoom);
  }

  // Function to confirm destination and show toast message.
  void _confirmDestination() {
    if (toLocation != null) {
      Fluttertoast.showToast(
        msg: "Happy Journey! Destination has been Set",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      // Don't navigate away - stay on map until destination is reached
      setState(() {
        _destinationConfirmed = true;
      });
    } else {
      Fluttertoast.showToast(
        msg: "Please select a destination on the map first!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          _destinationConfirmed
              ? _destinationReached
                  ? "Destination Reached!"
                  : "Journey in Progress"
              : "Select Your Location",
        ),
        backgroundColor:
            _destinationReached
                ? Colors.green
                : _destinationConfirmed
                ? Colors.blue
                : null,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    _buildSearchBar(_fromController, true),
                    const SizedBox(height: 10),
                    _buildSearchBar(_toController, false),
                    const SizedBox(height: 10),
                    if (distance != null)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Distance: ${distance!.toStringAsFixed(2)} km",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    // Journey status indicator
                    if (_destinationConfirmed)
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              _destinationReached
                                  ? Colors.green[50]
                                  : Colors.blue[50],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color:
                                _destinationReached
                                    ? Colors.green
                                    : Colors.blue,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _destinationReached
                                  ? "Destination Reached!"
                                  : "Journey in Progress - Stay on this screen",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color:
                                    _destinationReached
                                        ? Colors.green[800]
                                        : Colors.blue[800],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (!_destinationReached) const SizedBox(height: 8),
                            if (!_destinationReached)
                              Text(
                                "Continue until you reach your destination",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                                textAlign: TextAlign.center,
                              ),
                          ],
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
                        const LatLng(20.5937, 78.9629), // Default to India
                    initialZoom: _currentZoom,
                    onTap: (tapPosition, point) {
                      // If fromLocation is not set, mark fromLocation; otherwise mark toLocation (destination)
                      if (fromLocation == null) {
                        _setLocation(point, true);
                      } else {
                        _setLocation(point, false);
                      }
                    },
                    // Store the current zoom level when it changes
                    onPositionChanged: (position, hasGesture) {
                      if (hasGesture) {
                        // Update our zoom tracking variable
                        setState(() {
                          _currentZoom = position.zoom;
                        });
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: const ['a', 'b', 'c'],
                    ),
                    if (fromLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: fromLocation!,
                            width: 40,
                            height: 40,
                            child: const Icon(
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
                            point: toLocation!,
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.red,
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
          // Loading overlay
          if (_isLoadingLocation)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 20),
                    Text(
                      "Locating you...",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      // Floating Elevated Button at the bottom center for confirming destination.
      floatingActionButton:
          _destinationReached
              ? FloatingActionButton.extended(
                onPressed: () {
                  Navigator.pop(context, locationUpdateCount);
                },
                label: const Text("Complete Journey"),
                icon: const Icon(Icons.done_all),
                backgroundColor: Colors.green,
              )
              : FloatingActionButton.extended(
                onPressed: () {
                  if (toLocation != null && routePoints.isNotEmpty) {
                    if (!_destinationConfirmed) {
                      Fluttertoast.showToast(
                        msg: "Happy Journey! Destination has been set.",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                      );
                      setState(() {
                        _destinationConfirmed = true;
                      });
                    } else {
                      Fluttertoast.showToast(
                        msg: "Continue your journey to reach the destination.",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                      );
                    }
                  } else {
                    Fluttertoast.showToast(
                      msg: "Please select a destination on the map first!",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                    );
                  }
                },
                label: Text(
                  _destinationConfirmed
                      ? "Continue Journey"
                      : "Confirm Destination",
                ),
                icon: Icon(
                  _destinationConfirmed ? Icons.directions : Icons.check,
                ),
                backgroundColor: _destinationConfirmed ? Colors.blue : null,
              ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildSearchBar(TextEditingController controller, bool isFrom) {
    return Column(
      children: [
        TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: isFrom ? "From Location" : "To Destination",
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.search),
            contentPadding: const EdgeInsets.symmetric(
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
                  onTap: () => _selectLocation(place, isFrom),
                );
              },
            ),
          ),
      ],
    );
  }
}
