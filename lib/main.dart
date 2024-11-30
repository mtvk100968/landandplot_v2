import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import './providers/favorites_provider.dart'; // Adjust the import path if needed
import './firebase_options.dart'; // Import Firebase options
import './components/bottom_nav_bar.dart'; // Import your BottomNavBar widget

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
    return ChangeNotifierProvider(
      create: (_) => FavoritesProvider(), // Provide the FavoritesProvider
      child: MaterialApp(
        title: 'LANDANDPLOT',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
          useMaterial3: true, // Opt into Material 3 design
        ),
        debugShowCheckedModeBanner: false, // Hide the debug banner
        home: BottomNavBar(), // Use the BottomNavBar as the home
      ),
    );
  }
}