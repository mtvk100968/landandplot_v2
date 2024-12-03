import 'package:flutter/material.dart';
import '../models/user_model.dart';

class UserProvider extends ChangeNotifier {
  AppUser _user = AppUser.empty(); // Initialize with an empty user

  // Getter to access the user
  AppUser get user => _user;

  // Method to set or update the user
  void setUser(AppUser user) {
    _user = user;
    notifyListeners(); // Notify listeners to rebuild widgets that depend on user data
  }

  // Method to toggle favorite property
  void toggleFavorite(String propertyId) {
    if (_user.uid.isEmpty) {
      // Handle the case where the user is not logged in
      print('User is not logged in.');
      return;
    }

    if (_user.favoritedPropertyIds.contains(propertyId)) {
      _user.favoritedPropertyIds.remove(propertyId);
    } else {
      _user.favoritedPropertyIds.add(propertyId);
    }
    notifyListeners(); // Notify listeners to update UI
  }

// Additional methods can be added here as needed
}