import 'package:flutter/material.dart';
import 'screens/buy_land_screen.dart';
import 'screens/profile_screen.dart';
import './screens/sell_land_screen.dart';
import './screens/alerts_screen.dart';

class Routes {
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      '/buy_land': (context) => const BuyLandScreen(),
      '/profile': (context) => const ProfileScreen(),
      '/sell_land': (context) => const SellLandScreen(),
      '/alerts': (context) => const AlertsScreen(),
    };
  }
}
