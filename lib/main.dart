// lib/main.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;
import 'package:landandplot/screens/buy_land_screen.dart';
import 'package:landandplot/screens/profile_screen.dart';
import 'package:landandplot/screens/favorites_screen.dart';
import 'package:landandplot/utils/keys.dart';
import 'package:provider/provider.dart';

// Import your custom classes
import 'components/bottom_nav_bar.dart';
import 'firebase_options.dart';
import 'models/property_model.dart';
import 'providers/user_provider.dart'; // Import UserProvider

Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Load environment variables from the .env file
    await dotenv.dotenv.load(fileName: ".env");
  } catch (e) {
    print("Error loading .env file: $e");
  }

  try {
    // Initialize Firebase with the default options for the current platform
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print("Error initializing Firebase: $e");
  }

  // Run the Flutter application
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        // Other providers...
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final defaultPropertyList = <Property>[]; // Placeholder property list
    final defaultFavoritedPropertyIds = <String>[]; // Placeholder favorite IDs

    return MaterialApp(
      title: 'Land and Plot',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator while waiting for authentication state
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasData) {
            // User is logged in, show the BottomNavBar
            return BottomNavBar(
              key: bottomNavBarKey,
            );
          }

          // If no user is logged in, show the LoginScreen
          return const BuyLandScreen();
        },
      ),
      routes: {
        '/login': (context) => const BuyLandScreen(),
        '/profile': (context) => ProfileScreen(
          propertyList: defaultPropertyList,
          favoritedPropertyIds: defaultFavoritedPropertyIds,
          onFavoriteToggle: (String propertyId, bool isFavorited) {
            print('Toggled favorite: $propertyId, New State: $isFavorited');
          },
        ),
        '/buyLand': (context) => const BuyLandScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}