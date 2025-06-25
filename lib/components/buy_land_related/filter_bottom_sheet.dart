// // filter_bottom_sheet.dart
// lib/components/buy_land_related/filter_bottom_sheet.dart

import 'package:flutter/material.dart';
import '../../models/dev_subtype.dart';
import '../../models/filter_config.dart' as fc;
import '../../models/property_type.dart' as pt;
import 'location_search_bar.dart';

class FilterBottomSheet extends StatefulWidget {
  final pt.PropertyType? initialType;
  final Map<String, dynamic>? initialPlace;
  final double initialMinPrice, initialMaxPrice;
  final double initialMinArea, initialMaxArea;
  final int? initialBeds, initialBaths;
  final String? initialDevSubtype; // 🆕

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
    this.initialDevSubtype, // 🆕
  }) : super(key: key);

  @override
  _FilterBottomSheetState createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late RangeValues _priceRange;
  late RangeValues _areaRange;
  int? _beds, _baths;
  // ft.PropertyType? _type;
  fc.FilterConfig? _config;
  Map<String, dynamic>? _place;
  // String? _devSubtype; // 🆕
  pt.PropertyType?  _type;
  DevSubtype?    _devSubtype;

  @override
  void initState() {
    super.initState();
    _place = widget.initialPlace;
    _type = widget.initialType;
    _config = _type == null ? null : fc.kFilterMap[_type!];
    _devSubtype = widget.initialDevSubtype as DevSubtype?; // 🆕

    if (_config != null) {
      final p0 = widget.initialMinPrice != 0
          ? widget.initialMinPrice
          : _config!.priceMin;
      final p1 = widget.initialMaxPrice != 0
          ? widget.initialMaxPrice
          : _config!.priceMax;
      final a0 = widget.initialMinArea != 0
          ? widget.initialMinArea
          : _config!.areaMin;
      final a1 = widget.initialMaxArea != 0
          ? widget.initialMaxArea
          : _config!.areaMax;

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
    final config = (_type != null) ? fc.kFilterMap[_type!] : null;

    Navigator.of(context).pop({
      'place': _place,
      'type': _type,
      'devSubtype': _devSubtype, // 🆕
      'price': _priceRange,
      'area': _areaRange,
      'beds': _beds,
      'baths': _baths,
      'unit': config?.priceLabel,
    });
  }

  @override
  Widget build(BuildContext context) {
    final config = (_type != null) ? fc.kFilterMap[_type!] : null;

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ─── header ───────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Expanded(
                  child: Text('Filters', style: TextStyle(fontSize: 20))),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(null),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // ─── body ─────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1️⃣ Property Type Dropdown
                DropdownButton<pt.PropertyType>(
                  hint: const Text('Select property type'),
                  isExpanded: true,
                  value: _type,
                  items: pt.PropertyType.values.map((t) {
                    return DropdownMenuItem(
                      value: t,
                      child: Text(t.label),
                    );
                  }).toList(),
                  onChanged: (newType) {
                    if (newType == null) return;
                    setState(() {
                      _type = newType;
                      _config = fc.kFilterMap[newType]!;
                      // reset subtype when type changes
                      _devSubtype = null;
                      // reset ranges
                      _priceRange =
                          RangeValues(_config!.priceMin, _config!.priceMax);
                      _areaRange =
                          RangeValues(_config!.areaMin, _config!.areaMax);
                      _beds = null;
                      _baths = null;
                    });
                  },
                ),
                const SizedBox(height: 8),

                if (_type == pt.PropertyType.development) ...[
                  SizedBox(height: 12),
                  DropdownButton<DevSubtype>(
                    items: DevSubtype.values.map((d) {
                      return DropdownMenuItem(value: d, child: Text(d.label));
                    }).toList(),
                    value: _devSubtype,
                    hint: Text('Select sub-type'),
                    onChanged: (d) => setState(() {
                      _devSubtype = d;
                    }),
                  ),
                ],


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
              ],
            ),
          ),
        ),

        const Divider(height: 1),

        // ─── footer ───────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.black,
                ),
                onPressed: () => Navigator.of(context).pop(null),
              ),
              const Spacer(),
              ElevatedButton(
                child: const Text('Apply'),
                onPressed: _apply,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
