// // lib/models/filter_config.dart

import 'package:landandplot/models/property_type.dart';

/// Special configs for the two sub-types of “Development”
const FilterConfig developmentPlotConfig = FilterConfig(
  priceLabel: '₹ total property price',
  areaLabel: 'yards',
  priceMin: 0,
  priceMax: 2000000000,
  areaMin: 0,
  areaMax: 5000,
  needsBedsBaths: false,
);

const FilterConfig developmentLandConfig = FilterConfig(
  priceLabel: '₹ total property price',
  areaLabel: 'acres',
  priceMin: 0,
  priceMax: 2000000000,
  areaMin: 0,
  areaMax: 5000,
  needsBedsBaths: false,
);

class FilterConfig {
  // universal
  final String priceLabel;
  final String areaLabel;
  final double priceMin;
  final double priceMax;
  final double areaMin;
  final double areaMax;
  final bool needsBedsBaths;

  // apartment-only
  final String? totalApartmentAreaLabel;
  final String? totalPriceLabel;
  final double? pricePerSqft;
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
    required this.priceLabel,
    required this.areaLabel,
    required this.priceMin,
    required this.priceMax,
    required this.areaMin,
    required this.areaMax,
    this.needsBedsBaths = false,

    // apartment
    this.totalApartmentAreaLabel,
    this.totalPriceLabel,
    this.pricePerSqft,
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
    priceLabel: '₹ price per sqyd',
    areaLabel: 'yards',
    priceMin: 2500,
    priceMax: 200000,
    areaMin: 100,
    areaMax: 5000,
    needsBedsBaths: false,
  ),

  PropertyType.agriLand: FilterConfig(
    priceLabel: '₹ price per acre',
    areaLabel: 'acres',
    priceMin: 100000,
    priceMax: 50000000,
    areaMin: 1,
    areaMax: 200,
    needsBedsBaths: false,
  ),

  PropertyType.farmLand: FilterConfig(
    priceLabel: '₹ price per sqyd',
    areaLabel: 'yards',
    priceMin: 2500,
    priceMax: 100000,
    areaMin: 100,
    areaMax: 5000,
    needsBedsBaths: false,
  ),

  PropertyType.apartment: FilterConfig(
    priceLabel: '₹ price per sqft',
    areaLabel: 'sqft',
    priceMin: 2000000,
    priceMax: 200000000,
    areaMin: 300,
    areaMax: 5000,
    needsBedsBaths: true,
    totalApartmentAreaLabel: 'yards',
    totalPriceLabel: '₹',          // used if you want totalPrice = pricePerSqft * carpetArea
    pricePerSqft: 50000,
    carpetAreaMin: 300,
    carpetAreaMax: 5000,
  ),

  PropertyType.house: FilterConfig(
    priceLabel: '₹ total price',
    areaLabel: 'sqft',
    priceMin: 2000000,
    priceMax: 200000000,
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
    priceLabel: '₹ total price',
    areaLabel: 'sqft',
    priceMin: 2000000,
    priceMax: 200000000,
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

  /// For “development” itself, we’ll show a generic placeholder.
  /// You’ll swap to one of the two special configs at runtime in your sheet.
  PropertyType.development: FilterConfig(
    priceLabel: '₹ total price for sqyd /acres',
    areaLabel: 'yards / acres',
    priceMin: 1000000,
    priceMax: 2000000000,
    areaMin: 1,
    areaMax: 5000,
    needsBedsBaths: false,
  ),

  PropertyType.commercialSpace: FilterConfig(
    priceLabel: '₹ per sqft',
    areaLabel: 'sqft',
    priceMin: 2000,
    priceMax: 200000,
    areaMin: 100,
    areaMax: 20000,
    needsBedsBaths: false,
  ),
};