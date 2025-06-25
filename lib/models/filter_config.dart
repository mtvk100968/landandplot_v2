// lib/models/filter_config.dart

import 'package:landandplot/models/property_type.dart';

class FilterConfig {
  /// Label to show next to the price slider, e.g. "₹ per sqft"
  final String priceLabel;

  /// Label to show next to the area slider, e.g. "sqyd"
  final String areaLabel;

  /// Minimum and maximum values for the price slider
  final double priceMin;
  final double priceMax;

  /// Minimum and maximum values for the area slider
  final double areaMin;
  final double areaMax;

  /// Whether to show bedrooms & bathrooms chips
  final bool needsBedsBaths;

  const FilterConfig({
    required this.priceLabel,
    required this.areaLabel,
    required this.priceMin,
    required this.priceMax,
    required this.areaMin,
    required this.areaMax,
    this.needsBedsBaths = false,
  });
}

/// Configuration for each property type
const Map<PropertyType, FilterConfig> kFilterMap = {
  PropertyType.plot: FilterConfig(
    priceLabel: '₹ per sqyd',
    areaLabel: 'sqyd',
    priceMin: 0,
    priceMax: 500000,
    areaMin: 100,
    areaMax: 5000,
  ),
  PropertyType.farmLand: FilterConfig(
    priceLabel: '₹ per sqyd',
    areaLabel: 'sqyd',
    priceMin: 0,
    priceMax: 500000,
    areaMin: 100,
    areaMax: 5000,
  ),
  PropertyType.agriLand: FilterConfig(
    priceLabel: '₹ per acre',
    areaLabel: 'acre',
    priceMin: 0,
    priceMax: 50000000,
    areaMin: 1,
    areaMax: 100,
  ),
  PropertyType.apartment: FilterConfig(
    priceLabel: '₹ per sqft',
    areaLabel: 'sqft',
    priceMin: 0,
    priceMax: 20000,
    areaMin: 300,
    areaMax: 5000,
    needsBedsBaths: true,
  ),
  PropertyType.house: FilterConfig(
    priceLabel: '₹ per sqft',
    areaLabel: 'sqft',
    priceMin: 0,
    priceMax: 20000,
    areaMin: 400,
    areaMax: 8000,
    needsBedsBaths: true,
  ),
  PropertyType.villa: FilterConfig(
    priceLabel: '₹ per sqft',
    areaLabel: 'sqft',
    priceMin: 0,
    priceMax: 20000,
    areaMin: 500,
    areaMax: 10000,
    needsBedsBaths: true,
  ),
  PropertyType.development: FilterConfig(
    priceLabel: '₹ per sqft',
    areaLabel: 'sqft',
    priceMin: 0,
    priceMax: 20000,
    areaMin: 500,
    areaMax: 10000,
    needsBedsBaths: true,
  ),
  PropertyType.commercialSpace: FilterConfig(
    priceLabel: '₹ per sqft',
    areaLabel: 'sqft',
    priceMin: 0,
    priceMax: 20000,
    areaMin: 500,
    areaMax: 20000,
  ),
};
