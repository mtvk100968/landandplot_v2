// // filter_bottom_sheet.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  Map<String, dynamic>? _place;
  pt.PropertyType? _type;
  DevSubtype? _devSubtype;
  fc.FilterConfig? _config;
  late NumberFormat _indianFormat;

  @override
  void initState() {
    super.initState();

    // Initialize your Indian number formatter
    _indianFormat = NumberFormat.decimalPattern('en_IN');

    // … all of your existing initState code …
    _place = widget.initialPlace;
    _type = widget.initialType;
    _config = _type == null ? null : fc.kFilterMap[_type!];
    _devSubtype = widget.initialDevSubtype as DevSubtype?; // 🆕
    _recalcConfig();

    if (_config != null) {
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

  /// Recomputes `_config` based on current `_type` and `_devSubtype`.
  void _recalcConfig() {
    if (_type == pt.PropertyType.development) {
      _config = _devSubtype == DevSubtype.plot
          ? fc.developmentPlotConfig
          : _devSubtype == DevSubtype.land
              ? fc.developmentLandConfig
              : fc.kFilterMap[pt.PropertyType.development];
    } else if (_type != null) {
      _config = fc.kFilterMap[_type!]!;
    } else {
      _config = null;
    }
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

    // clamp our ranges to the current config’s bounds
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
                child: Text('Filters', style: TextStyle(fontSize: 20)),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
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
                  isExpanded: true,
                  hint: const Text('Select property type'),
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
                      _devSubtype = null;
                      _config = fc.kFilterMap[newType]!;
                      _recalcConfig(); // <-- recompute price/area labels & ranges
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

                // 🔹 Dev subtype selector only for Development
                if (_type == pt.PropertyType.development) ...[
                  const SizedBox(height: 12),
                  DropdownButton<DevSubtype>(
                      isExpanded: true,
                      hint: const Text('Select development subtype'),
                      value: _devSubtype,
                      items: DevSubtype.values.map((d) {
                        return DropdownMenuItem(value: d, child: Text(d.label));
                      }).toList(),
                      onChanged: (d) {
                        setState(() {
                          _devSubtype = d;
                          _recalcConfig(); // <-- swap in the plot vs land config
                          _priceRange =
                              RangeValues(_config!.priceMin, _config!.priceMax);
                          _areaRange =
                              RangeValues(_config!.areaMin, _config!.areaMax);
                        });
                      }),
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
//                   Text('Price (${config.priceLabel})'),
// // show the numeric values
//                   Padding(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(clampedPriceRange.start.toStringAsFixed(0)),
//                         Text(clampedPriceRange.end.toStringAsFixed(0)),
//                       ],
//                     ),
//                   ),
//                   RangeSlider(
//                     min: config.priceMin,
//                     max: config.priceMax,
//                     values: clampedPriceRange,
//                     labels: RangeLabels(
//                       clampedPriceRange.start.toStringAsFixed(0),
//                       clampedPriceRange.end.toStringAsFixed(0),
//                     ),
//                     onChanged: (r) => setState(() => _priceRange = r),
//                   ),
//
//                   const SizedBox(height: 8),
//
// // Area Slider
//                   Text('Area (${config.areaLabel})'),
// // show the numeric values
//                   Padding(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(clampedAreaRange.start.toStringAsFixed(0)),
//                         Text(clampedAreaRange.end.toStringAsFixed(0)),
//                       ],
//                     ),
//                   ),
//                   RangeSlider(
//                     min: config.areaMin,
//                     max: config.areaMax,
//                     values: clampedAreaRange,
//                     labels: RangeLabels(
//                       clampedAreaRange.start.toStringAsFixed(0),
//                       clampedAreaRange.end.toStringAsFixed(0),
//                     ),
//                     onChanged: (r) => setState(() => _areaRange = r),
//                   ),

                  // Price Slider
                  Text('Price (${config.priceLabel})'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_indianFormat.format(clampedPriceRange.start.round())),
                        Text(_indianFormat.format(clampedPriceRange.end.round())),
                      ],
                    ),
                  ),
                  RangeSlider(
                    min: config.priceMin,
                    max: config.priceMax,
                    values: clampedPriceRange,
                    labels: RangeLabels(
                      _indianFormat.format(clampedPriceRange.start.round()),
                      _indianFormat.format(clampedPriceRange.end.round()),
                    ),
                    onChanged: (r) => setState(() => _priceRange = r),
                  ),

                  const SizedBox(height: 8),

// Area Slider
                  Text('Area (${config.areaLabel})'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_indianFormat.format(clampedAreaRange.start.round())),
                        Text(_indianFormat.format(clampedAreaRange.end.round())),
                      ],
                    ),
                  ),
                  RangeSlider(
                    min: config.areaMin,
                    max: config.areaMax,
                    values: clampedAreaRange,
                    labels: RangeLabels(
                      _indianFormat.format(clampedAreaRange.start.round()),
                      _indianFormat.format(clampedAreaRange.end.round()),
                    ),
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
