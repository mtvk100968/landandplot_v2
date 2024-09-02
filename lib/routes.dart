import 'package:flutter/material.dart';
import './screens/home_screen.dart';
import './screens/sign_in_screen.dart';
import './screens/sell_land_screen.dart';

class Routes {
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      '/home': (context) => const HomeScreen(),
      '/sign_in': (context) => const SignInScreen(),
      '/sell_land': (context) => const SellLandScreen(),
    };
  }
}
