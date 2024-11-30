import 'package:flutter/material.dart';

class FavoritesProvider extends ChangeNotifier {
  List<String> _favoritePropertyIds = [];

  List<String> get favoritePropertyIds => _favoritePropertyIds;

  void setFavorites(List<String> favorites) {
    _favoritePropertyIds = favorites;
    notifyListeners();
  }

  void toggleFavorite(String propertyId) {
    if (_favoritePropertyIds.contains(propertyId)) {
      _favoritePropertyIds.remove(propertyId);
    } else {
      _favoritePropertyIds.add(propertyId);
    }
    notifyListeners();
  }
}