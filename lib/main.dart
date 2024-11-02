import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;

// Import your custom classes
import 'firebase_options.dart';
import './components/bottom_nav_bar.dart';
import './providers/auth_provider.dart';
import './providers/property_provider.dart';
import './services/property_service.dart';
import './utils/keys.dart'; // Ensure this file contains the definition for `bottomNavBarKey`

Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from the .env file
  // await dotenv.load(fileName: ".env");

  // Initialize Firebase with the default options for the current platform
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Run the Flutter application
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // Initialize all necessary providers at the top level
      providers: [
        // Authentication Provider
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        // Property Provider
        ChangeNotifierProvider<PropertyProvider>(
          create: (_) => PropertyProvider(),
        ),
        // Property Service Provider
        Provider<PropertyService>(
          create: (_) => PropertyService(),
        ),
        // Add other providers here if needed
      ],
      child: MaterialApp(
        title: 'LANDANDPLOT',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
          useMaterial3: true, // Opt into Material 3 design
        ),
        debugShowCheckedModeBanner: false, // Hide the debug banner
        home: const BottomNavBar(), // Use the BottomNavBar as the home
      ),
    );
  }
}
