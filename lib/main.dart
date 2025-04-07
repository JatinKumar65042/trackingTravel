import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tracker/pages/homepage.dart';
import 'package:tracker/pages/profile.dart';
import 'package:tracker/pages/survey/survey.dart';
import 'package:tracker/pages/survey/survey2.dart';
import 'package:tracker/pages/survey/survey3.dart';
import 'package:tracker/pages/survey/survey4.dart';
import 'package:tracker/pages/survey/survey5.dart';
import 'package:tracker/pages/top_places.dart';
import 'package:tracker/pages/login.dart';
import 'package:tracker/pages/signup.dart';
import 'package:tracker/pages/splashscreen.dart';
import 'package:tracker/services/location_service.dart';
import 'package:tracker/services/notification_service.dart';
import 'package:tracker/services/shared_pref.dart';
import 'package:tracker/tracking/location.dart';
import '../controller/auth_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tracker/services/route_observer.dart';

final RouteObserverService routeObserver = RouteObserverService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService.init();
  // Initialize AuthController before the app starts
  Get.put(AuthController());
  bool isLoggedIn = await checkSession();
  print("Loggin Check");
  print(isLoggedIn);
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

Future<bool> checkSession() async {
  String? userId = await SharedPreferenceHelper().getUserId();
  print("UserId: $userId");
  return userId != null && userId.isNotEmpty;
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // ✅ Use GetMaterialApp for GetX navigation
      debugShowCheckedModeBanner: false,
      title: "Flutter Firebase",
      theme: ThemeData(primarySwatch: Colors.pink),
      navigatorObservers: [routeObserver],
      initialRoute: '/',
      home: SplashScreen(child: isLoggedIn ? Home() : LogIn()),
      getPages: [
        // GetPage(name: '/', page: () => Home()),
        GetPage(name: '/login', page: () => LogIn()),
        GetPage(name: '/signUp', page: () => SignUp()),
        GetPage(name: '/home', page: () => Home()),
        GetPage(name: '/top_places', page: () => TopPlaces()),
        GetPage(name: '/me', page: () => ProfilePage()),
        GetPage(name: '/location', page: () => LocationSelectionPage()),
        // Uncomment or add these if needed
        // GetPage(name: '/maps', page: () => MapsPage()),
        GetPage(name: '/survey', page: () => Survey()),
        GetPage(name: '/survey2', page: () => Survey2()),
        GetPage(name: '/survey3', page: () => Survey3()),
        GetPage(name: '/survey4', page: () => Survey4()),
        GetPage(name: '/survey5', page: () => Survey5()),
      ],
    );
  }
}
