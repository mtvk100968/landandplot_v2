import 'package:flutter/material.dart';

class FavoritesProvider extends ChangeNotifier {
  final List<String> _favoritePropertyIds = [];

  List<String> get favoritePropertyIds => List.unmodifiable(_favoritePropertyIds);

  void toggleFavorite(String propertyId) {
    if (_favoritePropertyIds.contains(propertyId)) {
      _favoritePropertyIds.remove(propertyId);
    } else {
      _favoritePropertyIds.add(propertyId);
    }
    notifyListeners(); // Notify listeners about the change
  }

  bool isFavorite(String propertyId) {
    return _favoritePropertyIds.contains(propertyId);
  }
}