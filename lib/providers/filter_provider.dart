// // filter_provider.dart

// lib/providers/filter_provider.dart
import 'package:flutter/material.dart';

enum PropertyType {
  plot('Plot'),
  agriLand('Agri Land'),
  farmLand('Farm Land'),
  apartment('Apartment'),
  villa('Villa'),
  house('House'),
  commercial('Commercial'),
  development('Development'),
  developmentPlot('Development_Plot', firestoreKey: 'development_plot'),
  developmentLand('Development_Land', firestoreKey: 'development_land');

  /// Display label
  final String label;

  /// Key used in Firestore (defaults to [label])
  final String firestoreKey;

  const PropertyType(
    this.label, {
    String? firestoreKey,
  }) : firestoreKey = firestoreKey ?? label;

  /// Lookup by display label (case-insensitive)
  static PropertyType fromLabel(String dbValue) {
    return PropertyType.values.firstWhere(
      (e) => e.label.toLowerCase() == dbValue.toLowerCase(),
      orElse: () => PropertyType.plot,
    );
  }
}

class FilterProvider extends ChangeNotifier {
  // ─── Selection Flags ────────────────────────────────────────────
  bool isPlotSelected = false;
  bool isFarmLandSelected = false;
  bool isAgriLandSelected = false;
  bool isApartmentSelected = false;
  bool isVillaSelected = false;
  bool isHouseSelected = false;
  bool isCommercialSelected = false;

  /// Master toggle for “Development”
  bool isDevelopmentSelected = false;

  /// If user drills into Development, holds either developmentPlot or developmentLand.
  /// If null (but isDevelopmentSelected==true) → treat as “both.”
  PropertyType? developmentSubtype;

  // ─── Numeric Ranges State ───────────────────────────────────────
  String pricePerUnitUnit = '';
  String landAreaUnit = '';
  double minPricePerUnit = 0, maxPricePerUnit = 0;
  double minLandArea = 0, maxLandArea = 0;
  RangeValues selectedPriceRange = const RangeValues(0, 0);
  RangeValues selectedLandAreaRange = const RangeValues(0, 0);

  /// Bulk‐set (e.g. from persisted filters)
  void setSelections({
    required List<String> types,
    String? subtype,
    required RangeValues priceRange,
    required RangeValues areaRange,
  }) {
    isPlotSelected = types.contains('Plot');
    isFarmLandSelected = types.contains('Farm Land');
    isAgriLandSelected = types.contains('Agri Land');
    isApartmentSelected = types.contains('Apartment');
    isVillaSelected = types.contains('Villa');
    isHouseSelected = types.contains('House');
    isCommercialSelected = types.contains('Commercial');
    isDevelopmentSelected = types.contains('Development');

    // turn the incoming Firebase key into our enum, or null if it’s unrecognized
    if (subtype != null) {
      final matches =
          PropertyType.values.where((e) => e.firestoreKey == subtype).toList();
      developmentSubtype = matches.isNotEmpty ? matches.first : null;
    } else {
      developmentSubtype = null;
    }

    selectedPriceRange = priceRange;
    selectedLandAreaRange = areaRange;
    pricePerUnitUnit = '';
    landAreaUnit = '';

    notifyListeners();
  }

  /// Called when user taps one of the filter buttons
  void updatePropertyTypeSelection(PropertyType type) {
    switch (type) {
      // ─────────────── Agri Land ───────────────
      case PropertyType.agriLand:
        isAgriLandSelected = !isAgriLandSelected;
        if (isAgriLandSelected) {
          // disable conflicting land‐types
          isPlotSelected = isFarmLandSelected = false;
          // apply ranges
          _applyRanges(
            unit: 'per acre',
            areaUnit: 'acre',
            priceRange: const RangeValues(0, 50000000),
            areaRange: const RangeValues(1, 100),
          );
        } else {
          _resetRanges();
        }
        break;

      // ─────────────── Plot & Farm ───────────────
      case PropertyType.plot:
      case PropertyType.farmLand:
        if (type == PropertyType.plot) {
          isPlotSelected = !isPlotSelected;
        } else {
          isFarmLandSelected = !isFarmLandSelected;
        }
        if (isPlotSelected || isFarmLandSelected) {
          isAgriLandSelected = false;
          _applyRanges(
            unit: 'per sqyd',
            areaUnit: 'sqyd',
            priceRange: const RangeValues(0, 500000),
            areaRange: const RangeValues(100, 5000),
          );
        } else {
          _resetRanges();
        }
        break;

      // ─────────────── Development Umbrella ───────────────
      case PropertyType.development:
        isDevelopmentSelected = !isDevelopmentSelected;
        if (!isDevelopmentSelected) developmentSubtype = null;
        break;

      // ─────────────── Development Subtypes ───────────────
      case PropertyType.developmentPlot:
      case PropertyType.developmentLand:
        isDevelopmentSelected = true;
        developmentSubtype = type;
        break;

      // ─────────────── Simple Toggles ───────────────
      case PropertyType.house:
        isHouseSelected = !isHouseSelected;
        break;
      case PropertyType.villa:
        isVillaSelected = !isVillaSelected;
        break;
      case PropertyType.apartment:
        isApartmentSelected = !isApartmentSelected;
        break;
      case PropertyType.commercial:
        isCommercialSelected = !isCommercialSelected;
        break;

      default:
        break;
    }

    notifyListeners();
  }

  /// Applies numeric ranges and units
  void _applyRanges({
    required String unit,
    required String areaUnit,
    required RangeValues priceRange,
    required RangeValues areaRange,
  }) {
    pricePerUnitUnit = unit;
    landAreaUnit = areaUnit;
    minPricePerUnit = priceRange.start;
    maxPricePerUnit = priceRange.end;
    minLandArea = areaRange.start;
    maxLandArea = areaRange.end;
    selectedPriceRange = priceRange;
    selectedLandAreaRange = areaRange;
  }

  /// Clears all numeric ranges
  void _resetRanges() {
    pricePerUnitUnit = '';
    landAreaUnit = '';
    minPricePerUnit = maxPricePerUnit = 0;
    minLandArea = maxLandArea = 0;
    selectedPriceRange = const RangeValues(0, 0);
    selectedLandAreaRange = const RangeValues(0, 0);
  }

  /// Firestore `whereIn: [...]` array of keys
  List<String> get selectedPropertyTypes {
    final types = <String>[];

    if (isPlotSelected) types.add(PropertyType.plot.firestoreKey);
    if (isFarmLandSelected) types.add(PropertyType.farmLand.firestoreKey);
    if (isAgriLandSelected) types.add(PropertyType.agriLand.firestoreKey);
    if (isApartmentSelected) types.add(PropertyType.apartment.firestoreKey);
    if (isVillaSelected) types.add(PropertyType.villa.firestoreKey);
    if (isHouseSelected) types.add(PropertyType.house.firestoreKey);
    if (isCommercialSelected) {
      types.add(PropertyType.commercial.firestoreKey);
    }

    if (isDevelopmentSelected) {
      if (developmentSubtype == null) {
        // both subtypes
        types.add(PropertyType.developmentPlot.firestoreKey);
        types.add(PropertyType.developmentLand.firestoreKey);
      } else {
        types.add(developmentSubtype!.firestoreKey);
      }
    }

    return types;
  }

  bool get hasFiltersApplied => selectedPropertyTypes.isNotEmpty;

  /// Formats numbers with K / L / C suffixes
  String formatPrice(double v) {
    if (v >= 10000000) return '${(v / 10000000).toStringAsFixed(1)}C';
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}
