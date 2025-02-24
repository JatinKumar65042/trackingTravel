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
import '../controller/auth_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';


void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Initialize AuthController before the app starts
  Get.put(AuthController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp( // ✅ Use GetMaterialApp for GetX navigation
      debugShowCheckedModeBanner: false,
      title: "Flutter Firebase",
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => SplashScreen(child: LogIn())),
        // GetPage(name: '/', page: () => Home()),
        GetPage(name: '/login', page: () => LogIn()),
        GetPage(name: '/signUp', page: () => SignUp()),
        GetPage(name: '/home', page: () => Home()),
        GetPage(name: '/top_places', page: () => TopPlaces()),
        GetPage(name: '/me', page: () => ProfilePage()),
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

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});
//   final String title;
//
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;
//
//   void _incrementCounter() {
//     setState(() {
//       _counter++;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text('You have pushed the button this many times:'),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }
