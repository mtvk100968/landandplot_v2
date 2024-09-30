// lib/models/property_model.dart

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

class Property {
  final String id;
  final String userId;
  final String name;
  final String mobileNumber;
  final String propertyType; // Agricultural Land, Farm Land, Plot
  final double landArea;
  final double pricePerUnit; // Price/Acre or Price/SqYd
  final double totalPrice;
  final String? surveyNumber; // Applicable for Agri and Farm
  final List<String>? plotNumbers; // Applicable for Plot
  final double latitude;
  final double longitude;
  final String pincode;
  final String village;
  final String mandal;
  final String town;
  final String district;
  final String state;
  final bool roadAccess;
  final String roadType;
  final double roadWidth;
  final String landFacing;
  final List<String> images;
  final List<String> videos;
  final List<String> documents;
  final String propertyOwner;
  final String propertyRegisteredBy;

  Property({
    required this.id,
    required this.userId,
    required this.name,
    required this.mobileNumber,
    required this.propertyType,
    required this.landArea,
    required this.pricePerUnit,
    required this.totalPrice,
    this.surveyNumber,
    this.plotNumbers,
    required this.latitude,
    required this.longitude,
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

  /// Converts the Property instance to a Map for Firestore.
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'mobileNumber': mobileNumber,
      'propertyType': propertyType,
      'landArea': landArea,
      'pricePerUnit': pricePerUnit,
      'totalPrice': totalPrice,
      'surveyNumber': surveyNumber,
      'plotNumbers': plotNumbers,
      'latitude': latitude,
      'longitude': longitude,
      'pincode': pincode,
      'village': village,
      'mandal': mandal,
      'town': town,
      'district': district,
      'state': state,
      'roadAccess': roadAccess,
      'roadType': roadType,
      'roadWidth': roadWidth,
      'landFacing': landFacing,
      'images': images,
      'videos': videos,
      'documents': documents,
      'propertyOwner': propertyOwner,
      'propertyRegisteredBy': propertyRegisteredBy,
    };
  }

  /// Creates a Property instance from a Firestore document.
  factory Property.fromMap(String id, Map<String, dynamic> map) {
    return Property(
      id: id,
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      mobileNumber: map['mobileNumber'] ?? '',
      propertyType: map['propertyType'] ?? 'Plot',
      landArea: (map['landArea'] != null) ? map['landArea'].toDouble() : 0.0,
      pricePerUnit:
          (map['pricePerUnit'] != null) ? map['pricePerUnit'].toDouble() : 0.0,
      totalPrice:
          (map['totalPrice'] != null) ? map['totalPrice'].toDouble() : 0.0,
      surveyNumber: map['surveyNumber'],
      plotNumbers: map['plotNumbers'] != null
          ? List<String>.from(map['plotNumbers'])
          : null,
      latitude: (map['latitude'] != null) ? map['latitude'].toDouble() : 0.0,
      longitude: (map['longitude'] != null) ? map['longitude'].toDouble() : 0.0,
      pincode: map['pincode'] ?? '',
      village: map['village'] ?? '',
      mandal: map['mandal'] ?? '',
      town: map['town'] ?? '',
      district: map['district'] ?? '',
      state: map['state'] ?? '',
      roadAccess: map['roadAccess'] ?? false,
      roadType: map['roadType'] ?? '',
      roadWidth: (map['roadWidth'] != null) ? map['roadWidth'].toDouble() : 0.0,
      landFacing: map['landFacing'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      videos: List<String>.from(map['videos'] ?? []),
      documents: List<String>.from(map['documents'] ?? []),
      propertyOwner: map['propertyOwner'] ?? '',
      propertyRegisteredBy: map['propertyRegisteredBy'] ?? '',
    );
  }
}
