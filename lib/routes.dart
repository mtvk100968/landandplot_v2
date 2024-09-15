import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/buy_land_screen.dart';
import 'screens/profile_screen.dart';
import './screens/sell_land_screen.dart';
import './screens/alerts_screen.dart';
import './screens/favorites_screen.dart';

class Routes {
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      '/buy_land': (context) => const BuyLandScreen(),
      '/profile': (context) =>
          _buildScreen(context, const ProfileScreen(), '/profile'),
      '/sell_land': (context) =>
          _buildScreen(context, const SellLandScreen(), '/sell_land'),
      '/alerts': (context) =>
          _buildScreen(context, const AlertsScreen(), '/alerts'),
      '/favorites': (context) =>
          _buildScreen(context, const FavoritesScreen(), '/favorites'),
    };
  }

  static Widget _buildScreen(
      BuildContext context, Widget screen, String routeName) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Redirect to ProfileScreen (which is your AuthScreen) and pass the intended route
      return const ProfileScreen(); // The ProfileScreen acts as the AuthScreen
    } else {
      return screen; // Return the requested screen if user is authenticated
    }
  }
}
