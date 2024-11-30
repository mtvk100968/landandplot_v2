import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;

// Import your custom classes
import 'firebase_options.dart';
import './components/bottom_nav_bar.dart';
import './utils/keys.dart'; // Import global keys and tab indices

Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase with the default options for the current platform
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print("Error initializing Firebase: $e");
  }

  // Run the Flutter application
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LANDANDPLOT',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true, // Opt into Material 3 design
      ),
      debugShowCheckedModeBanner: false, // Hide the debug banner
      home: BottomNavBar(
        key: bottomNavBarKey, // Assign the global key here
      ), // Use the BottomNavBar as the home
    );
  }
}
