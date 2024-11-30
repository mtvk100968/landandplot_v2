import 'package:flutter/material.dart';

class FilterBottomSheet extends StatefulWidget {
  final Map<String, dynamic>? currentFilters;

  const FilterBottomSheet({Key? key, this.currentFilters}) : super(key: key);

  @override
  _FilterBottomSheetState createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  // Property Type Filters
  bool isPlotSelected = false;
  bool isFarmLandSelected = false;
  bool isAgriLandSelected = false;
  bool isPlotEnabled = false;
  bool isFarmLandEnabled = false;
  bool isAgriLandEnabled = false;

  // Units and Ranges
  String pricePerUnitUnit = '';
  String landAreaUnit = '';
  double minPricePerUnit = 0.0;
  double maxPricePerUnit = 0.0;
  double minLandArea = 0.0;
  double maxLandArea = 0.0;

  RangeValues selectedPriceRange = const RangeValues(0, 0);
  RangeValues selectedLandAreaRange = const RangeValues(0, 0);

  List<String> selectedPropertyTypes = [];

  @override
  void initState() {
    super.initState();
    // Initialize with current filters if provided
    if (widget.currentFilters != null) {
      selectedPriceRange = widget.currentFilters!['selectedPriceRange'] ??
          const RangeValues(0, 0);
      selectedLandAreaRange = widget.currentFilters!['selectedLandAreaRange'] ??
          const RangeValues(0, 0);
      pricePerUnitUnit = widget.currentFilters!['pricePerUnitUnit'] ?? '';
      landAreaUnit = widget.currentFilters!['landAreaUnit'] ?? '';
      List<String> propertyTypes = List<String>.from(
          widget.currentFilters!['selectedPropertyTypes'] ?? []);

      isPlotSelected = propertyTypes.contains('Plot');
      isFarmLandSelected = propertyTypes.contains('Farm Land');
      isAgriLandSelected = propertyTypes.contains('Agri Land');

      // Set units and ranges based on selected property types
      if (isAgriLandSelected) {
        pricePerUnitUnit = 'per acre';
        landAreaUnit = 'acre';
        minPricePerUnit = 500000;
        maxPricePerUnit = 5000000000;
        minLandArea = 1;
        maxLandArea = 999;
        selectedPriceRange = RangeValues(minPricePerUnit, maxPricePerUnit);
        selectedLandAreaRange = RangeValues(minLandArea, maxLandArea);
      } else if (isPlotSelected || isFarmLandSelected) {
        pricePerUnitUnit = 'per sqyd';
        landAreaUnit = 'sqyd';
        minPricePerUnit = 0.0; // allow 0 as minimum
        maxPricePerUnit = 5000000;
        minLandArea = 100;
        maxLandArea = 4800;
        selectedPriceRange = RangeValues(minPricePerUnit, maxPricePerUnit);
        selectedLandAreaRange = RangeValues(minLandArea, maxLandArea);
      }
    }
  }

  void updatePropertyTypeSelection(String propertyType) {
    setState(() {
      if (propertyType == 'Agri Land') {
        isAgriLandSelected = !isAgriLandSelected;
        if (isAgriLandSelected) {
          // Deselect other property types
          isPlotSelected = false;
          isFarmLandSelected = false;
          isPlotEnabled = false;
          isFarmLandEnabled = false;
          pricePerUnitUnit = 'per acre';
          landAreaUnit = 'acre';
          minPricePerUnit = 500000;
          maxPricePerUnit = 5000000000;
          minLandArea = 1;
          maxLandArea = 100;
          selectedPriceRange = RangeValues(minPricePerUnit, maxPricePerUnit);
          selectedLandAreaRange = RangeValues(minLandArea, maxLandArea);
        } else {
          resetFilters();
        }
      } else if (propertyType == 'Plot') {
        isPlotSelected = !isPlotSelected;
        if (isPlotSelected) {
          isAgriLandSelected = false;
          isFarmLandSelected = false;
          isFarmLandEnabled = false;
          isAgriLandEnabled = false;
          pricePerUnitUnit = 'per sqyd';
          landAreaUnit = 'sqyd';
          minPricePerUnit = 5000;
          maxPricePerUnit = 2000000;
          minLandArea = 100;
          maxLandArea = 5000;
          selectedPriceRange = RangeValues(minPricePerUnit, maxPricePerUnit);
          selectedLandAreaRange = RangeValues(minLandArea, maxLandArea);
        } else {
          resetFilters();
        }
      } else if (propertyType == 'Farm Land') {
        isFarmLandSelected = !isFarmLandSelected;
        if (isFarmLandSelected) {
          isAgriLandSelected = false;
          isPlotSelected = false;
          isPlotEnabled = false;
          isAgriLandEnabled = false;
          pricePerUnitUnit = 'per sqyd';
          landAreaUnit = 'sqyd';
          minPricePerUnit = 1000;
          maxPricePerUnit = 100000;
          minLandArea = 100;
          maxLandArea = 5000;
          selectedPriceRange =
              RangeValues(minPricePerUnit, maxPricePerUnit);
          selectedLandAreaRange = RangeValues(minLandArea, maxLandArea);
        } else {
          resetFilters();
        }
      }
    });

    // Ensure selected property types are updated
    List<String> selectedPropertyTypes = [];
    if (isPlotSelected) selectedPropertyTypes.add('Plot');
    if (isFarmLandSelected) selectedPropertyTypes.add('Farm Land');
    if (isAgriLandSelected) selectedPropertyTypes.add('Agri Land');

    // Update the filter state when property types are updated
    print('Updated Filters: $selectedPropertyTypes, $selectedPriceRange, $selectedLandAreaRange');
  }

  void resetFilters() {
    setState(() {
      isPlotSelected = false;
      isFarmLandSelected = false;
      isAgriLandSelected = false;
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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height *
          0.7, // Take up 90% of screen height
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Text(
              'Select Property Type',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            CheckboxListTile(
              title: const Text('Plot'),
              value: isPlotSelected,
              onChanged: (bool? value) {
                updatePropertyTypeSelection('Plot');
              },
            ),
            CheckboxListTile(
              title: const Text('Farm Land'),
              value: isFarmLandSelected,
              onChanged: (bool? value) {
                updatePropertyTypeSelection('Farm Land');
              },
            ),
            CheckboxListTile(
              title: const Text('Agri Land'),
              value: isAgriLandSelected,
              onChanged: (bool? value) {
                updatePropertyTypeSelection('Agri Land');
              },
            ),
            if (pricePerUnitUnit.isNotEmpty && landAreaUnit.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'Price per unit ($pricePerUnitUnit)',
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
                      print('Updated price range: $selectedPriceRange');
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Land area ($landAreaUnit)',
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
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                List<String> selectedPropertyTypes = [];
                if (isPlotSelected) selectedPropertyTypes.add('Plot');
                if (isFarmLandSelected) selectedPropertyTypes.add('Farm Land');
                if (isAgriLandSelected) selectedPropertyTypes.add('Agri Land');

                print('Applying Filters: $selectedPropertyTypes, $selectedPriceRange, $selectedLandAreaRange');

                Navigator.pop(context, {
                  'selectedPropertyTypes': selectedPropertyTypes,
                  'selectedPriceRange': selectedPriceRange,
                  'pricePerUnitUnit': pricePerUnitUnit,
                  'selectedLandAreaRange': selectedLandAreaRange,
                  'landAreaUnit': landAreaUnit,
                });
              },
              child: const Text('Apply Filters'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
