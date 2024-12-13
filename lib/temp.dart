// lib/components/filter_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PropertyType { Plot, FarmLand, AgriLand }

class FilterBottomSheet extends StatefulWidget {
  final Map<String, dynamic>? currentFilters;

  const FilterBottomSheet({Key? key, this.currentFilters}) : super(key: key);

  @override
  _FilterBottomSheetState createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  // Property Type Filter - Only one can be selected
  PropertyType? selectedPropertyType;

  // Units and Ranges
  String pricePerUnitUnit = '';
  String landAreaUnit = '';
  double minPricePerUnit = 0.0;
  double maxPricePerUnit = 0.0;
  double minLandArea = 0.0;
  double maxLandArea = 0.0;

  RangeValues selectedPriceRange = const RangeValues(0, 0);
  RangeValues selectedLandAreaRange = const RangeValues(0, 0);

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFilters();
  }

  Future<void> _loadFilters() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      // Load selected property type
      List<String> propertyTypes =
          prefs.getStringList('selectedPropertyTypes') ?? [];

      if (propertyTypes.isNotEmpty) {
        String typeString = propertyTypes.first;
        switch (typeString) {
          case 'Plot':
            selectedPropertyType = PropertyType.Plot;
            break;
          case 'Farm Land':
            selectedPropertyType = PropertyType.FarmLand;
            break;
          case 'Agri Land':
            selectedPropertyType = PropertyType.AgriLand;
            break;
          default:
            selectedPropertyType = null;
        }

        // Set units and ranges based on selected property type
        if (selectedPropertyType == PropertyType.AgriLand) {
          pricePerUnitUnit = 'per acre';
          landAreaUnit = 'acre';
          minPricePerUnit = 500000;
          maxPricePerUnit = 50000000;
          minLandArea = 1;
          maxLandArea = 100;
          selectedPriceRange = RangeValues(minPricePerUnit, maxPricePerUnit);
          selectedLandAreaRange = RangeValues(minLandArea, maxLandArea);
        } else if (selectedPropertyType == PropertyType.Plot ||
            selectedPropertyType == PropertyType.FarmLand) {
          pricePerUnitUnit = 'per sqyd';
          landAreaUnit = 'sqyd';
          minPricePerUnit = 5000;
          maxPricePerUnit = 500000;
          minLandArea = 100;
          maxLandArea = 5000;
          selectedPriceRange = RangeValues(minPricePerUnit, maxPricePerUnit);
          selectedLandAreaRange = RangeValues(minLandArea, maxLandArea);
        } else {
          // If no valid property type is selected, reset filters
          resetFilters();
        }
      } else {
        // If no property type is selected, reset filters
        resetFilters();
      }
    });
  }

  Future<void> _saveFilters() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> propertyTypes = selectedPropertyType != null
        ? [selectedPropertyType.toString().split('.').last.replaceAll('_', ' ')]
        : [];

    await prefs.setStringList('selectedPropertyTypes', propertyTypes);
    await prefs.setDouble('minPricePerUnit', selectedPriceRange.start);
    await prefs.setDouble('maxPricePerUnit', selectedPriceRange.end);
    await prefs.setDouble('minLandArea', selectedLandAreaRange.start);
    await prefs.setDouble('maxLandArea', selectedLandAreaRange.end);
    await prefs.setString('pricePerUnitUnit', pricePerUnitUnit);
    await prefs.setString('landAreaUnit', landAreaUnit);
  }

  void togglePropertyType(PropertyType type) {
    setState(() {
      if (selectedPropertyType == type) {
        // If the same type is tapped again, deselect it
        selectedPropertyType = null;
        resetFilters();
      } else {
        // Select the new type
        selectedPropertyType = type;

        // Set units and ranges based on selected property type
        if (selectedPropertyType == PropertyType.AgriLand) {
          pricePerUnitUnit = 'per acre';
          landAreaUnit = 'acre';
          minPricePerUnit = 500000;
          maxPricePerUnit = 50000000;
          minLandArea = 1;
          maxLandArea = 100;
          selectedPriceRange = RangeValues(minPricePerUnit, maxPricePerUnit);
          selectedLandAreaRange = RangeValues(minLandArea, maxLandArea);
        } else if (selectedPropertyType == PropertyType.Plot ||
            selectedPropertyType == PropertyType.FarmLand) {
          pricePerUnitUnit = 'per sqyd';
          landAreaUnit = 'sqyd';
          minPricePerUnit = 5000;
          maxPricePerUnit = 500000;
          minLandArea = 100;
          maxLandArea = 5000;
          selectedPriceRange = RangeValues(minPricePerUnit, maxPricePerUnit);
          selectedLandAreaRange = RangeValues(minLandArea, maxLandArea);
        }
      }
    });
  }

  void resetFilters() {
    setState(() {
      selectedPropertyType = null;
      pricePerUnitUnit = '';
      landAreaUnit = '';
      minPricePerUnit = 0.0;
      maxPricePerUnit = 0.0;
      minLandArea = 0.0;
      maxLandArea = 0.0;
      selectedPriceRange = const RangeValues(0, 0);
      selectedLandAreaRange = const RangeValues(0, 0);
    });
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

  void applyFilters() async {
    setState(() {
      isLoading = true;
    });

    // Simulate a delay for applying filters
    await Future.delayed(const Duration(seconds: 1));

    await _saveFilters();

    setState(() {
      isLoading = false;
    });

    // Show a SnackBar as visual feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Filters Applied')),
    );

    // Collect selected property types as a list
    List<String> selectedPropertyTypesList = selectedPropertyType != null
        ? [selectedPropertyType.toString().split('.').last.replaceAll('_', ' ')]
        : [];

    // Pass the selected filters back to BuyLandScreen
    Navigator.pop(context, {
      'selectedPropertyTypes': selectedPropertyTypesList,
      'selectedPriceRange': selectedPriceRange,
      'pricePerUnitUnit': pricePerUnitUnit,
      'selectedLandAreaRange': selectedLandAreaRange,
      'landAreaUnit': landAreaUnit,
    });
  }

  void showUnitsExplanation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Units Explanation'),
        content: const Text('C = Crores, L = Lakhs, K = Thousands'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget buildPropertyTypeRadio(
      PropertyType type, IconData icon, String label) {
    return RadioListTile<PropertyType>(
      secondary: Icon(icon, semanticLabel: '$label icon'),
      title: Text(label, style: const TextStyle(fontSize: 16)),
      value: type,
      groupValue: selectedPropertyType,
      onChanged: (PropertyType? value) {
        togglePropertyType(type);
      },
      controlAffinity: ListTileControlAffinity.leading,
      subtitle: Text(
        'Select if you are interested in $label properties',
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Adaptive height based on screen size
    double screenHeight = MediaQuery.of(context).size.height;
    double containerHeight = screenHeight * 0.7;
    if (screenHeight < 600) {
      containerHeight = screenHeight * 0.9;
    }

    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.light(
          primary: Colors.green,
          onPrimary: Colors.white,
          secondary: Colors.greenAccent,
        ),
      ),
      child: Container(
        height: containerHeight,
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header with title and info icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter Properties',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: showUnitsExplanation,
                    tooltip: 'Units Explanation',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Property Type Selection
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Select Property Type',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              buildPropertyTypeRadio(
                  PropertyType.Plot, Icons.landscape, 'Plot'),
              buildPropertyTypeRadio(
                  PropertyType.FarmLand, Icons.agriculture, 'Farm Land'),
              buildPropertyTypeRadio(
                  PropertyType.AgriLand, Icons.grass, 'Agri Land'),
              const SizedBox(height: 16),
              // Price Range Selection
              if (pricePerUnitUnit.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Price per unit ($pricePerUnitUnit): ${formatPrice(selectedPriceRange.start)} - ${formatPrice(selectedPriceRange.end)}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    RangeSlider(
                      values: selectedPriceRange,
                      min: minPricePerUnit,
                      max: maxPricePerUnit,
                      divisions: 10,
                      labels: RangeLabels(
                        formatPrice(selectedPriceRange.start),
                        formatPrice(selectedPriceRange.end),
                      ),
                      onChanged: (RangeValues values) {
                        setState(() {
                          selectedPriceRange = values;
                        });
                      },
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              // Land Area Range Selection
              if (landAreaUnit.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Land area ($landAreaUnit): ${selectedLandAreaRange.start.toStringAsFixed(1)} - ${selectedLandAreaRange.end.toStringAsFixed(1)}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    RangeSlider(
                      values: selectedLandAreaRange,
                      min: minLandArea,
                      max: maxLandArea,
                      divisions: 10,
                      labels: RangeLabels(
                        selectedLandAreaRange.start.toStringAsFixed(1),
                        selectedLandAreaRange.end.toStringAsFixed(1),
                      ),
                      onChanged: (RangeValues values) {
                        setState(() {
                          selectedLandAreaRange = values;
                        });
                      },
                    ),
                  ],
                ),
              const SizedBox(height: 24),
              // Action Buttons: Reset and Apply
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: resetFilters,
                    child: const Text('Reset Filters'),
                  ),
                  ElevatedButton(
                    onPressed: isLoading ? null : applyFilters,
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Apply Filters'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
