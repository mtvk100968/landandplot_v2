// lib/models/sell_land_form_data.dart

import 'dart:io';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SellLandFormData {
  // Step 1: Basic Details
  final String name;
  final String mobileNumber;

  // Step 2: Area & Pricing
  final String propertyType;
  final double landArea;
  final double pricePerUnit;
  final double totalPrice;

  // Step 3: Property Identification
  final String? surveyNumber;
  final String? plotNumbers;

  // Step 4: Place Marker
  final LatLng selectedLocation;

  // Step 5: Address Details
  final String pincode;
  final String village;
  final String mandal;
  final String town;
  final String district;
  final String state;

  // Step 6: Other Details
  final bool roadAccess;
  final String roadType;
  final double roadWidth;
  final String landFacing;

  // Step 7: Upload Media
  final List<File> images;
  final List<File> videos;

  // Step 8: Upload Documents
  final List<File> documents;

  // Step 9: Owner Details
  final String propertyOwner;
  final String propertyRegisteredBy;

  SellLandFormData({
    required this.name,
    required this.mobileNumber,
    required this.propertyType,
    required this.landArea,
    required this.pricePerUnit,
    required this.totalPrice,
    this.surveyNumber,
    this.plotNumbers,
    required this.selectedLocation,
    required this.pincode,
    required this.village,
    required this.mandal,
    required this.town,
    required this.district,
    required this.state,
    required this.roadAccess,
    required this.roadType,
    required this.roadWidth,
    required this.landFacing,
    required this.images,
    required this.videos,
    required this.documents,
    required this.propertyOwner,
    required this.propertyRegisteredBy,
  });
}
