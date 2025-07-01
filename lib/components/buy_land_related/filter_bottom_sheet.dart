// filter_bottom_sheet.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/dev_subtype.dart';
import '../../models/filter_config.dart' as fc;
import '../../models/property_type.dart' as pt;
import 'location_search_bar.dart';

enum _ActiveSlider { none, total, unit }

class FilterBottomSheet extends StatefulWidget {
  final pt.PropertyType? initialType;
  final Map<String, dynamic>? initialPlace;
  final double initialMinArea, initialTotalMinPrice, initialUnitMinPrice;
  final double initialMaxArea, initialTotalMaxPrice, initialUnitMaxPrice;
  final int? initialBeds, initialBaths;
  // final String? initialDevSubtype; // 🆕
  final DevSubtype? initialDevSubtype;

  const FilterBottomSheet({
    Key? key,
    this.initialType,
    this.initialPlace,
    this.initialUnitMinPrice = 0,
    this.initialUnitMaxPrice = 0,
    this.initialTotalMinPrice = 0,
    this.initialTotalMaxPrice = 0,
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
  late RangeValues _unitPriceRange;
  late RangeValues _totalPriceRange;
  late RangeValues _areaRange;
  int? _beds, _baths;
  Map<String, dynamic>? _place;
  pt.PropertyType? _type;
  DevSubtype? _devSubtype;
  fc.FilterConfig? _config;
  late NumberFormat _indianFormat;

  _ActiveSlider _activeSlider = _ActiveSlider.none; // ← start with both active

  @override
  void initState() {
    super.initState();

// Initialize your Indian number formatter
    _indianFormat = NumberFormat.decimalPattern('en_IN');

// … all of your existing initState code …
    _place = widget.initialPlace;
    _type = widget.initialType;
    _config = _type == null ? null : fc.kFilterMap[_type!];
    // _devSubtype = widget.initialDevSubtype as DevSubtype?; // 🆕
    _devSubtype = widget.initialDevSubtype;
    _recalcConfig();

    if (_config != null) {
      _unitPriceRange  = RangeValues(
        widget.initialUnitMinPrice>0 ? widget.initialUnitMinPrice : _config!.unitPriceMin,
        widget.initialUnitMaxPrice>0 ? widget.initialUnitMaxPrice : _config!.unitPriceMax,
      );
      _totalPriceRange = RangeValues(
        widget.initialTotalMinPrice>0 ? widget.initialTotalMinPrice : _config!.totalPriceMin,
        widget.initialTotalMaxPrice>0 ? widget.initialTotalMaxPrice : _config!.totalPriceMax,
      );
      _areaRange       = RangeValues(
        widget.initialMinArea>0 ? widget.initialMinArea : _config!.areaMin,
        widget.initialMaxArea>0 ? widget.initialMaxArea : _config!.areaMax,
      );
    } else {
      _unitPriceRange = const RangeValues(0,0);
      _totalPriceRange= const RangeValues(0,0);
      _areaRange      = const RangeValues(0,0);
    }

    _beds = widget.initialBeds;
    _baths = widget.initialBaths;
  }

  /// Recomputes _config based on current _type and _devSubtype.
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
    print('🖨 Applying filters:');
    print(
        '   • TotalPriceRange = ${_totalPriceRange.start} – ${_totalPriceRange.end}');
    print(
        '   • UnitPriceRange  = ${_unitPriceRange.start} – ${_unitPriceRange.end}');
    print('   • AreaRange       = ${_areaRange.start} – ${_areaRange.end}');

    Navigator.of(context).pop({
      'place': _place,
      'type': _type,
      'devSubtype': _devSubtype, // 🆕
      'unitPrice': _unitPriceRange,
      'totalPrice': _totalPriceRange, // ← add this
      'area': _areaRange,
      'beds': _beds,
      'baths': _baths,
      'unit': config?.unitPriceLabel,
      'useTotal': _activeSlider == _ActiveSlider.total,
    });
  }

  @override
  Widget build(BuildContext context) {
    final config = (_type != null) ? fc.kFilterMap[_type!] : null;

// clamp our ranges to the current config’s bounds
    final clampedUnitPrice = config == null
        ? _unitPriceRange
        : RangeValues(
      _unitPriceRange.start
          .clamp(config.unitPriceMin, config.unitPriceMax),
      _unitPriceRange.end.clamp(config.unitPriceMin, config.unitPriceMax),
    );

    final clampedTotalPrice = config == null
        ? _totalPriceRange
        : RangeValues(
      _totalPriceRange.start
          .clamp(config.totalPriceMin, config.totalPriceMax),
      _totalPriceRange.end
          .clamp(config.totalPriceMin, config.totalPriceMax),
    );

    final clampedArea = config == null
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
                      _totalPriceRange = RangeValues(
                          _config!.totalPriceMin, _config!.totalPriceMax);
                      _unitPriceRange = RangeValues(
                          _config!.unitPriceMin, _config!.unitPriceMax);
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
                  const SizedBox(height: 8),
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
                          _totalPriceRange = RangeValues(
                              _config!.totalPriceMin, _config!.totalPriceMax);
                          _unitPriceRange = RangeValues(
                              _config!.unitPriceMin, _config!.unitPriceMax);
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
                  const SizedBox(height: 8),

                  Text('TotalPrice (${config.totalPriceLabel})'),
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_indianFormat
                            .format(clampedTotalPrice.start.round())),
                        Text(_indianFormat
                            .format(clampedTotalPrice.end.round())),
                      ],
                    ),
                  ),

                  IgnorePointer(
// ignoring: !_useTotalPrice,
                    ignoring: _activeSlider == _ActiveSlider.unit,
                    child: Opacity(
                      opacity: _activeSlider == _ActiveSlider.unit ? 0.5 : 1.0,
                      child: RangeSlider(
                        activeColor: Colors.green,
                        min: config.totalPriceMin,
                        max: config.totalPriceMax,
                        values: clampedTotalPrice,
                        labels: RangeLabels(
                          _indianFormat.format(clampedTotalPrice.start.round()),
                          _indianFormat.format(clampedTotalPrice.end.round()),
                        ),
                        onChanged: (r) => setState(() {
                          _activeSlider = _ActiveSlider.total;
                          _totalPriceRange = r;
                        }),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
// Price Slider
                  Text('Price (${config.unitPriceLabel})'),
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_indianFormat
                            .format(clampedUnitPrice.start.round())),
                        Text(
                            _indianFormat.format(clampedUnitPrice.end.round())),
                      ],
                    ),
                  ),

                  IgnorePointer(
// ignoring: _useTotalPrice,              // disabled when total is active
                    ignoring: _activeSlider == _ActiveSlider.total,
                    child: Opacity(
                      opacity: _activeSlider == _ActiveSlider.total ? 0.5 : 1.0,
                      child: RangeSlider(
                        activeColor: Colors.green,
                        min: config.unitPriceMin,
                        max: config.unitPriceMax,
                        values: clampedUnitPrice,
                        labels: RangeLabels(
                          _indianFormat.format(clampedUnitPrice.start.round()),
                          _indianFormat.format(clampedUnitPrice.end.round()),
                        ),
                        onChanged: (r) => setState(() {
                          _activeSlider = _ActiveSlider.unit;
                          _unitPriceRange = r;
                        }),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
// Area Slider
                  Text('Area (${config.areaLabel})'),
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_indianFormat.format(clampedArea.start.round())),
                        Text(_indianFormat.format(clampedArea.end.round())),
                      ],
                    ),
                  ),
                  RangeSlider(
                    min: config.areaMin,
                    max: config.areaMax,
                    values: clampedArea,
                    labels: RangeLabels(
                      _indianFormat.format(clampedArea.start.round()),
                      _indianFormat.format(clampedArea.end.round()),
                    ),
                    onChanged: (r) => setState(() => _areaRange = r),
                  ),

// Beds/Baths (only if needed)
                  if (config.needsBedsBaths) ...[
                    const SizedBox(height: 8),
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
                    const SizedBox(height: 8),
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