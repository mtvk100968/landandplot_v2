import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/filter_provider.dart';

class FilterBottomSheet extends StatelessWidget {
  const FilterBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FilterProvider(),
      child: Consumer<FilterProvider>(
        builder: (context, filterProvider, child) {
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
                    value: filterProvider.isPlotSelected,
                    onChanged: filterProvider.isPlotEnabled
                        ? (bool? value) {
                            filterProvider.updatePropertyTypeSelection('Plot');
                          }
                        : null,
                  ),
                  CheckboxListTile(
                    title: const Text('Farm Land'),
                    value: filterProvider.isFarmLandSelected,
                    onChanged: filterProvider.isFarmLandEnabled
                        ? (bool? value) {
                            filterProvider
                                .updatePropertyTypeSelection('Farm Land');
                          }
                        : null,
                  ),
                  CheckboxListTile(
                    title: const Text('Agri Land'),
                    value: filterProvider.isAgriLandSelected,
                    onChanged: filterProvider.isAgriLandEnabled
                        ? (bool? value) {
                            filterProvider
                                .updatePropertyTypeSelection('Agri Land');
                          }
                        : null,
                  ),
                  if (filterProvider.pricePerUnitUnit.isNotEmpty &&
                      filterProvider.landAreaUnit.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          'Price Per Unit (${filterProvider.pricePerUnitUnit})',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        RangeSlider(
                          values: filterProvider.selectedPriceRange,
                          min: filterProvider.minPricePerUnit,
                          max: filterProvider.maxPricePerUnit,
                          divisions: 10,
                          labels: RangeLabels(
                            filterProvider.formatPrice(
                                filterProvider.selectedPriceRange.start),
                            filterProvider.formatPrice(
                                filterProvider.selectedPriceRange.end),
                          ),
                          onChanged: (RangeValues values) {
                            filterProvider.updatePriceRange(values);
                          },
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Land Area (${filterProvider.landAreaUnit})',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        RangeSlider(
                          values: filterProvider.selectedLandAreaRange,
                          min: filterProvider.minLandArea,
                          max: filterProvider.maxLandArea,
                          divisions: 10,
                          labels: RangeLabels(
                            filterProvider.selectedLandAreaRange.start
                                .toStringAsFixed(1),
                            filterProvider.selectedLandAreaRange.end
                                .toStringAsFixed(1),
                          ),
                          onChanged: (RangeValues values) {
                            filterProvider.updateLandAreaRange(values);
                          },
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    child: const Text('Apply Filters'),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
