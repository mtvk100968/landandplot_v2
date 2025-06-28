// // lib/models/filter_config.dart

import 'package:landandplot/models/property_type.dart';

/// Special configs for the two sub-types of “Development”
const FilterConfig developmentPlotConfig = FilterConfig(
  unitPriceLabel:      '₹ per sqft',
  unitPriceMin: 10000,
  unitPriceMax: 200000,
  totalPriceLabel: '₹ total property price',
  totalPriceMin: 1000000,
  totalPriceMax: 2000000000,
  areaLabel: 'yards',
  areaMin: 500,
  areaMax: 5000,
  needsBedsBaths: false,
);

const FilterConfig developmentLandConfig = FilterConfig(
  unitPriceLabel:      '₹ per sqft',
  unitPriceMin: 250000,
  unitPriceMax: 500000000,
  totalPriceLabel:  '₹ total property price',
  totalPriceMin: 300000,
  totalPriceMax: 2000000000,
  areaLabel: 'acres',
  areaMin: 1,
  areaMax: 5000,
  needsBedsBaths: false,
);

class FilterConfig {
  // universal
  // 2️⃣ total-price slider
  final String  totalPriceLabel;
  final double  totalPriceMin;
  final double  totalPriceMax;

  // 1️⃣ unit-price slider
  final String  unitPriceLabel;
  final double  unitPriceMin;
  final double  unitPriceMax;

  // 3️⃣ area slider
  final String  areaLabel;
  final double  areaMin;
  final double  areaMax;

  // final String priceLabel;
  final bool needsBedsBaths;

  // plot, farm house
  final double? priceMin;
  final double? priceMax;

  // apartment-only
  final String? totalAptAreaLabel;
  final String? totalAptPriceLabel;

  final double? carpetAreaMin;
  final double? carpetAreaMax;

  // house/villa-only
  final String? constructedAreaLabel;
  final String? plotAreaLabel;
  final double? constructedAreaMin;
  final double? constructedAreaMax;
  final double? plotAreaMin;
  final double? plotAreaMax;

  const FilterConfig({
    // unit-price
    required this.unitPriceLabel,
    required this.unitPriceMin,
    required this.unitPriceMax,

    required this.totalPriceLabel,
    required this.areaLabel,
    required this.totalPriceMin,
    required this.totalPriceMax,
    required this.areaMin,
    required this.areaMax,

    this.needsBedsBaths = false,

    // apartment
    this.totalAptAreaLabel,
    this.totalAptPriceLabel,
    this.priceMin,
    this.priceMax,
    this.carpetAreaMin,
    this.carpetAreaMax,

    // house / villa
    this.constructedAreaLabel,
    this.plotAreaLabel,
    this.constructedAreaMin,
    this.constructedAreaMax,
    this.plotAreaMin,
    this.plotAreaMax,
  });
}

/// Configuration for each property type
const Map<PropertyType, FilterConfig> kFilterMap = {
  PropertyType.plot: FilterConfig(
    unitPriceLabel: '₹ price per sqyd',
    totalPriceLabel: 'Property price',
    areaLabel: 'yards',
    unitPriceMin: 2500,
    unitPriceMax: 250000,
    totalPriceMin: 100000,
    totalPriceMax: 100000000,
    areaMin: 100,
    areaMax: 5000,
    needsBedsBaths: false,
  ),

  PropertyType.agriLand: FilterConfig(
    unitPriceLabel: '₹ price per acre',
    totalPriceLabel: 'Property price',
    areaLabel: 'acres',
    unitPriceMin: 100000,
    unitPriceMax: 2000000000,
    totalPriceMin: 100000,
    totalPriceMax: 5000000000,
    areaMin: 1,
    areaMax: 300,
    needsBedsBaths: false,
  ),

  PropertyType.farmLand: FilterConfig(
    unitPriceLabel: '₹ price per sqyd',
    totalPriceLabel: 'Property price',
    areaLabel: 'yards',
    unitPriceMin: 2500,
    unitPriceMax: 200000,
    totalPriceMin: 100000,
    totalPriceMax: 50000000,
    areaMin: 100,
    areaMax: 5000,
    needsBedsBaths: false,
  ),

  PropertyType.apartment: FilterConfig(
    unitPriceLabel:      '₹ per sqft',
    totalPriceLabel: 'Property price',
    areaLabel: 'sqft',
    totalPriceMin: 1000000,
    totalPriceMax: 200000000,
    unitPriceMin: 2500,
    unitPriceMax: 500000,
    areaMin: 300,
    areaMax: 5000,
    needsBedsBaths: true,
    carpetAreaMin: 300,
    carpetAreaMax: 5000,
  ),

  PropertyType.house: FilterConfig(
    unitPriceLabel:      '₹ per sqft',
    totalPriceLabel: '₹ total price',
    areaLabel: 'sqft',
    totalPriceMin: 2000000,
    totalPriceMax: 200000000,
    unitPriceMin: 2500,
    unitPriceMax: 500000,
    areaMin: 100,
    areaMax: 5000,
    needsBedsBaths: true,
    constructedAreaLabel: 'sqft',
    plotAreaLabel: 'yards',
    constructedAreaMin: 100,
    constructedAreaMax: 10000,
    plotAreaMin: 100,
    plotAreaMax: 5000,
  ),

  PropertyType.villa: FilterConfig(
    unitPriceLabel:      '₹ per sqft',
    totalPriceLabel: '₹ total price',
    areaLabel: 'sqft',
    unitPriceMin: 2500,
    unitPriceMax: 500000,
    totalPriceMin: 2000000,
    totalPriceMax: 200000000,
    areaMin: 100,
    areaMax: 5000,
    needsBedsBaths: true,
    constructedAreaLabel: 'sqft',
    constructedAreaMin: 100,
    constructedAreaMax: 10000,
    plotAreaMin: 100,
    plotAreaMax: 5000,
  ),

  /// For “development” itself, we’ll show a generic placeholder.
  /// You’ll swap to one of the two special configs at runtime in your sheet.
  PropertyType.development: FilterConfig(
    unitPriceLabel:      '₹ per sqft',
    totalPriceLabel: '₹ total price for sqyd /acres',
    areaLabel: 'yards / acres',
    unitPriceMin: 2500,
    unitPriceMax: 500000,
    totalPriceMin: 2000000,
    totalPriceMax: 200000000,
    areaMin: 1,
    areaMax: 5000,
    needsBedsBaths: false,
  ),

  PropertyType.commercialSpace: FilterConfig(
    // 1. unit-price per sqft
    unitPriceLabel:      '₹ per sqft',
    unitPriceMin:        2000,
    unitPriceMax:        200000,

    // 2. total-price for the whole property
    totalPriceLabel: '₹ total price',
    totalPriceMin:   500000,
    totalPriceMax:   50000000,

    // 3. plot area in sqft
    areaLabel:       'sqft',
    areaMin:         100,
    areaMax:         10000,

    // no beds/baths filter for comm-space
    needsBedsBaths:  false,
  ),
};