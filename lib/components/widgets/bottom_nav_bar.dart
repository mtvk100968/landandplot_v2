import 'package:flutter/material.dart';
import '../../screens/buy_land_screen.dart';
import '../../screens/sell_land_screen.dart';
import '../../screens/alerts_screen.dart';
import '../../screens/profile_screen.dart';
import '../../screens/favorites_screen.dart';

// Public class
class BottomNavBar extends StatefulWidget {
  // Use super parameter for the key
  const BottomNavBar({super.key});

  @override
  BottomNavBarState createState() =>
      BottomNavBarState(); // Make this class public
}

// Public class for state
class BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = [
    const BuyLandScreen(), // Buy Land screen
    const FavoritesScreen(), // Favorites screen
    const SellLandScreen(), // Sell Land screen
    const AlertsScreen(), // Alerts screen
    const ProfileScreen(), // Profile Screen
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.search_outlined,
              color: _selectedIndex == 0 ? Colors.black : Colors.grey,
            ),
            label: 'Buy Land',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.favorite_border,
              color: _selectedIndex == 1 ? Colors.black : Colors.grey,
            ),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.place_outlined,
              color: _selectedIndex == 2 ? Colors.black : Colors.grey,
            ),
            label: 'Sell Land',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.notifications_active_outlined,
              color: _selectedIndex == 3 ? Colors.black : Colors.grey,
            ),
            label: 'Alerts',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.account_circle_outlined,
              color: _selectedIndex == 4 ? Colors.black : Colors.grey,
            ),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black, // Color when selected
        unselectedItemColor: Colors.grey, // Outline color when not selected
        onTap: _onItemTapped,
      ),
    );
  }
}
