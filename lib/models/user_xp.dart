import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tracker/services/shared_pref.dart';

class UserXP {
  final int totalPoints;
  final Map<String, int> tripPoints;
  final int level;
  final int pointsToNextLevel;

  UserXP({
    required this.totalPoints,
    required this.tripPoints,
    required this.level,
    required this.pointsToNextLevel,
  });

  // Calculate level based on total points
  static int calculateLevel(int points) {
    // Simple level calculation: level = points / 100 + 1
    return (points / 100).floor() + 1;
  }

  // Calculate points needed for next level
  static int calculatePointsToNextLevel(int points) {
    int currentLevel = calculateLevel(points);
    int pointsForNextLevel = currentLevel * 100;
    return pointsForNextLevel - points;
  }

  // Create UserXP from Firestore document
  factory UserXP.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    Map<String, dynamic> tripPointsData = data['tripPoints'] ?? {};
    Map<String, int> tripPoints = {};

    tripPointsData.forEach((key, value) {
      tripPoints[key] = value as int;
    });

    int totalPoints = data['totalPoints'] ?? 0;

    return UserXP(
      totalPoints: totalPoints,
      tripPoints: tripPoints,
      level: calculateLevel(totalPoints),
      pointsToNextLevel: calculatePointsToNextLevel(totalPoints),
    );
  }

  // Create empty UserXP
  factory UserXP.empty() {
    return UserXP(
      totalPoints: 0,
      tripPoints: {},
      level: 1,
      pointsToNextLevel: 100,
    );
  }

  // Add points for a trip
  static Future<void> addPointsForTrip(
    String transportMode,
    int locationUpdateCount,
  ) async {
    try {
      String? userId = await SharedPreferenceHelper().getUserId();
      if (userId == null) {
        print("❌ User ID is null. Cannot add XP points.");
        return;
      }
      // Only award points for successful location updates sent to Firebase
      // Each update represents approximately 10 meters of travel
      double distanceKm = (locationUpdateCount * 10) / 1000.0;

      // Calculate points based on transport mode and derived distance
      int points = _calculatePointsForTrip(transportMode, distanceKm);

      // Get user XP document
      DocumentReference userXpRef = FirebaseFirestore.instance
          .collection('userXP')
          .doc(userId);

      DocumentSnapshot userXpDoc = await userXpRef.get();

      if (userXpDoc.exists) {
        // Update existing document
        Map<String, dynamic> data = userXpDoc.data() as Map<String, dynamic>;
        int currentPoints = data['totalPoints'] ?? 0;
        Map<String, dynamic> tripPoints = data['tripPoints'] ?? {};

        // Update trip points
        String tripId = DateTime.now().millisecondsSinceEpoch.toString();
        tripPoints[tripId] = points;

        await userXpRef.update({
          'totalPoints': currentPoints + points,
          'tripPoints': tripPoints,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      } else {
        // Create new document
        String tripId = DateTime.now().millisecondsSinceEpoch.toString();
        Map<String, dynamic> tripPoints = {tripId: points};

        await userXpRef.set({
          'totalPoints': points,
          'tripPoints': tripPoints,
          'createdAt': FieldValue.serverTimestamp(),
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }

      print("✅ Added $points XP points for $transportMode trip");
    } catch (e) {
      print("❌ Error adding XP points: $e");
    }
  }

  // Calculate points based on transport mode and distance with enhanced rewards
  static int _calculatePointsForTrip(String transportMode, double distance) {
    // Base points for completing a trip
    int basePoints = 20;

    // Enhanced points based on transport mode (eco-friendly modes get more points)
    Map<String, int> modeMultiplier = {
      'Walking': 4, // Most eco-friendly, highest reward
      'Bicycle': 4, // Most eco-friendly, highest reward
      'Train': 3, // Public transport, good reward
      'Bus': 3, // Public transport, good reward
      'Car': 2, // Less eco-friendly
      '2/3-Wheeler': 2, // Less eco-friendly
      'Flight': 1, // Least eco-friendly
    };

    // Enhanced distance factor with progressive rewards
    int distancePoints = 0;
    if (distance <= 5) {
      distancePoints =
          (distance * 2).floor(); // 2 points per km for short trips
    } else if (distance <= 15) {
      distancePoints =
          10 + ((distance - 5) * 3).floor(); // 3 points per km for medium trips
    } else {
      distancePoints =
          40 + ((distance - 15) * 4).floor(); // 4 points per km for long trips
    }

    // Calculate total points with mode multiplier
    int totalPoints =
        (basePoints + distancePoints) * (modeMultiplier[transportMode] ?? 1);

    // Bonus points for eco-friendly choices
    if (['Walking', 'Bicycle'].contains(transportMode)) {
      totalPoints += 15; // Extra bonus for zero-emission transport
    } else if (['Train', 'Bus'].contains(transportMode)) {
      totalPoints += 10; // Bonus for public transport
    }

    return totalPoints;
  }

  // Get user XP data
  static Future<UserXP> getUserXP() async {
    try {
      String? userId = await SharedPreferenceHelper().getUserId();
      if (userId == null) {
        print("❌ User ID is null. Cannot get XP data.");
        return UserXP.empty();
      }

      DocumentSnapshot doc =
          await FirebaseFirestore.instance
              .collection('userXP')
              .doc(userId)
              .get();

      if (doc.exists) {
        return UserXP.fromFirestore(doc);
      } else {
        return UserXP.empty();
      }
    } catch (e) {
      print("❌ Error getting user XP: $e");
      return UserXP.empty();
    }
  }
}
