// filter_provider.dart
import 'package:flutter/material.dart';

enum PropertyType { Plot, FarmLand, AgriLand }

class FilterProvider extends ChangeNotifier {
  // Property Type Filters
  bool isPlotSelected = false;
  bool isFarmLandSelected = false;
  bool isAgriLandSelected = false;
  bool isPlotEnabled = true;
  bool isFarmLandEnabled = true;
  bool isAgriLandEnabled = true;

  // Units
  String pricePerUnitUnit = ''; // 'per sqyd' or 'per acre'
  String landAreaUnit = ''; // 'sqyd' or 'acre'

  // Price and Area Ranges
  double minPricePerUnit = 0.0;
  double maxPricePerUnit = 0.0;
  double minLandArea = 0.0;
  double maxLandArea = 0.0;

  RangeValues selectedPriceRange = const RangeValues(0, 0);
  RangeValues selectedLandAreaRange = const RangeValues(0, 0);

  // Internal method to convert string to PropertyType enum
  PropertyType? _propertyTypeFromString(String typeString) {
    switch (typeString) {
      case 'Plot':
        return PropertyType.Plot;
      case 'Farm Land':
        return PropertyType.FarmLand;
      case 'Agri Land':
        return PropertyType.AgriLand;
      default:
        return null;
    }
  }

  // Internal method to convert PropertyType enum to string
  String _propertyTypeToString(PropertyType type) {
    switch (type) {
      case PropertyType.Plot:
        return 'Plot';
      case PropertyType.FarmLand:
        return 'Farm Land';
      case PropertyType.AgriLand:
        return 'Agri Land';
      default:
        return '';
    }
  }

  // Update Property Type Selection Logic
  void updatePropertyTypeSelection(String propertyType) {
    PropertyType? typeEnum = _propertyTypeFromString(propertyType);
    if (typeEnum == null) return;

    if (typeEnum == PropertyType.AgriLand) {
      isAgriLandSelected = !isAgriLandSelected;

      if (isAgriLandSelected) {
        isPlotSelected = false;
        isFarmLandSelected = false;
        isPlotEnabled = false;
        isFarmLandEnabled = false;

        // Set units and ranges for Agri Land
        pricePerUnitUnit = 'per acre';
        landAreaUnit = 'acre';
        minPricePerUnit = 0; // 0
        maxPricePerUnit = 50000000; // 5C
        minLandArea = 1;
        maxLandArea = 100;

        // Update the selected ranges
        selectedPriceRange = RangeValues(minPricePerUnit, maxPricePerUnit);
        selectedLandAreaRange = RangeValues(minLandArea, maxLandArea);
      } else {
        resetFilters();
      }
    } else {
      if (typeEnum == PropertyType.Plot && isPlotEnabled) {
        isPlotSelected = !isPlotSelected;
      } else if (typeEnum == PropertyType.FarmLand && isFarmLandEnabled) {
        isFarmLandSelected = !isFarmLandSelected;
      }

      if (isPlotSelected || isFarmLandSelected) {
        isAgriLandSelected = false;
        isAgriLandEnabled = false;

        // Set units and ranges for Plot or Farm Land
        pricePerUnitUnit = 'per sqyd';
        landAreaUnit = 'sqyd';
        minPricePerUnit = 0; // 0
        maxPricePerUnit = 500000; // 5L
        minLandArea = 100;
        maxLandArea = 5000;

        // Update the selected ranges
        selectedPriceRange = RangeValues(minPricePerUnit, maxPricePerUnit);
        selectedLandAreaRange = RangeValues(minLandArea, maxLandArea);
      } else {
        resetFilters();
      }
    }

    // Debugging: Print the current selected property types
    print('Updated Property Types Selection: $selectedPropertyTypes');
    notifyListeners();
  }

  void resetFilters() {
    isPlotEnabled = true;
    isFarmLandEnabled = true;
    isAgriLandEnabled = true;
    isPlotSelected = false;
    isFarmLandSelected = false;
    isAgriLandSelected = false;
    pricePerUnitUnit = '';
    landAreaUnit = '';
    minPricePerUnit = 0;
    maxPricePerUnit = 0;
    minLandArea = 0;
    maxLandArea = 0;
    selectedPriceRange = const RangeValues(0, 0);
    selectedLandAreaRange = const RangeValues(0, 0);
    notifyListeners();
  }

  // Format price for display using K, L, C
  String formatPrice(double value) {
    if (value >= 10000000) {
      return '${(value / 10000000).toStringAsFixed(1)}C'; // Crores
    } else if (value >= 100000) {
      return '${(value / 100000).toStringAsFixed(1)}L'; // Lakhs
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K'; // Thousands
    } else {
      return value.toStringAsFixed(0);
    }
  }

  // Update selected price range
  void updatePriceRange(RangeValues values) {
    selectedPriceRange = values;
    notifyListeners();
  }

  // Update selected land area range
  void updateLandAreaRange(RangeValues values) {
    selectedLandAreaRange = values;
    notifyListeners();
  }

  // Get selected property types
  List<String> get selectedPropertyTypes {
    List<String> types = [];
    if (isPlotSelected) types.add('Plot');
    if (isFarmLandSelected) types.add('Farm Land');
    if (isAgriLandSelected) types.add('Agri Land');
    return types;
  }

  // Check if any filters are applied
  bool get hasFiltersApplied {
    return selectedPropertyTypes.isNotEmpty;
  }
}
