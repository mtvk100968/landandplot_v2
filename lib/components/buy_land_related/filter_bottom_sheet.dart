// filter_bottom_sheet.dart
import 'package:flutter/material.dart';
import '../../models/filter_config.dart' as fc;
import 'location_search_bar.dart';

class FilterBottomSheet extends StatefulWidget {
  final fc.PropertyType? initialType;
  final Map<String, dynamic>? initialPlace;
  final double initialMinPrice, initialMaxPrice;
  final double initialMinArea, initialMaxArea;
  final int? initialBeds, initialBaths;

  const FilterBottomSheet({
    Key? key,
    this.initialType,
    this.initialPlace,
    this.initialMinPrice = 0,
    this.initialMaxPrice = 0,
    this.initialMinArea = 0,
    this.initialMaxArea = 0,
    this.initialBeds,
    this.initialBaths,
  }) : super(key: key);

  @override
  _FilterBottomSheetState createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late RangeValues _priceRange;
  late RangeValues _areaRange;
  int? _beds, _baths;
  fc.PropertyType? _type;
  fc.FilterConfig? _config; // 🆕
  Map<String, dynamic>? _place;

  @override
  void initState() {
    super.initState();
    _place = widget.initialPlace;
    _type = widget.initialType;
    _config = _type == null ? null : fc.kFilterMap[_type!];

    if (_config != null) {
      // If parent never gave us a real value, default to the full span:
      final p0 = widget.initialMinPrice != 0
          ? widget.initialMinPrice
          : _config!.priceMin;
      final p1 = widget.initialMaxPrice != 0
          ? widget.initialMaxPrice
          : _config!.priceMax;
      final a0 =
          widget.initialMinArea != 0 ? widget.initialMinArea : _config!.areaMin;
      final a1 =
          widget.initialMaxArea != 0 ? widget.initialMaxArea : _config!.areaMax;

      _priceRange = RangeValues(p0, p1);
      _areaRange = RangeValues(a0, a1);
    } else {
      _priceRange = const RangeValues(0, 0);
      _areaRange = const RangeValues(0, 0);
    }

    _beds = widget.initialBeds;
    _baths = widget.initialBaths;
  }

  void _apply() {
    // recompute the config here
    final config = (_type != null) ? fc.kFilterMap[_type!] : null;

    Navigator.of(context).pop({
      'place': _place,
      'type': _type,
      'price': _priceRange,
      'area': _areaRange,
      'beds': _beds,
      'baths': _baths,
      'unit': config?.priceLabel, // safe-null here
    });
  }

  @override
  Widget build(BuildContext context) {
    final config = (_type != null) ? fc.kFilterMap[_type!] : null;

    // If we have a config, clamp the ranges so sliders never start out-of-bounds
    final clampedPriceRange = config == null
        ? _priceRange
        : RangeValues(
            _priceRange.start.clamp(config.priceMin, config.priceMax),
            _priceRange.end.clamp(config.priceMin, config.priceMax),
          );

    final clampedAreaRange = config == null
        ? _areaRange
        : RangeValues(
            _areaRange.start.clamp(config.areaMin, config.areaMax),
            _areaRange.end.clamp(config.areaMin, config.areaMax),
          );

    return Container(
      height: MediaQuery.of(context).size.height * 0.60, // 👈 Adjust height as needed
      width: double.infinity, // full width
      color: Colors.white, // solid rectangle look
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.zero,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1️⃣ Property Type Dropdown
              DropdownButton<fc.PropertyType>(
                hint: const Text('Select property type'),
                isExpanded: true,
                value: _type,
                items: fc.PropertyType.values.map((t) {
                  return DropdownMenuItem(
                    value: t,
                    child: Text(t.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (newType) {
                  if (newType == null) return;
                  setState(() {
                    final c = fc.kFilterMap[newType]!;
                    _type = newType;
                    // reset ranges to full span of the newly selected type
                    _priceRange = RangeValues(c.priceMin, c.priceMax);
                    _areaRange = RangeValues(c.areaMin, c.areaMax);
                    _beds = null;
                    _baths = null;
                  });
                },
              ),
              const SizedBox(height: 8),

              // 🔹 Location picker
              SizedBox(
                width: double.infinity,
                child: LocationSearchBar(
                  initialPlace: widget.initialPlace,
                  onPlaceSelected: (p) => setState(() => _place = p),
                ),
              ),
              const SizedBox(height: 8),

              // 2️⃣ If a type is chosen, show its sliders and chips
              if (config != null) ...[
                const SizedBox(height: 16),

                // Price Slider
                Text('Price (${config.priceLabel})'),
                RangeSlider(
                  min: config.priceMin,
                  max: config.priceMax,
                  values: clampedPriceRange,
                  onChanged: (r) => setState(() => _priceRange = r),
                ),

                const SizedBox(height: 8),

                // Area Slider
                Text('Area (${config.areaLabel})'),
                RangeSlider(
                  min: config.areaMin,
                  max: config.areaMax,
                  values: clampedAreaRange,
                  onChanged: (r) => setState(() => _areaRange = r),
                ),

                // Beds/Baths (only if needed)
                if (config.needsBedsBaths) ...[
                  const SizedBox(height: 16),
                  const Text('Bedrooms'),
                  Wrap(
                    spacing: 8,
                    children: List.generate(5, (i) {
                      final v = i + 1;
                      return ChoiceChip(
                        label: Text(v == 5 ? '4+' : '$v'),
                        selected: _beds == v,
                        onSelected: (_) => setState(() => _beds = v),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  const Text('Bathrooms'),
                  Wrap(
                    spacing: 8,
                    children: List.generate(5, (i) {
                      final v = i + 1;
                      return ChoiceChip(
                        label: Text(v == 5 ? '4+' : '$v'),
                        selected: _baths == v,
                        onSelected: (_) => setState(() => _baths = v),
                      );
                    }),
                  ),
                ],
              ],

              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // recompute config…
                    final cfg = _type != null ? fc.kFilterMap[_type!] : null;
                    Navigator.of(context).pop({
                      'place': _place,
                      'type': _type,
                      'price': _priceRange,
                      'area': _areaRange,
                      'beds': _beds,
                      'baths': _baths,
                      'unit': cfg?.priceLabel,
                    });
                  },
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
