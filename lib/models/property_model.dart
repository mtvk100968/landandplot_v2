// lib/models/property_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Property {
  final String id;
  final String userId;
  final String name;
  final String mobileNumber;
  final String propertyType;
  final double landArea;
  final double pricePerUnit;
  final double totalPrice;
  final String surveyNumber;
  final List<String> plotNumbers;
  final String? district; // Kept for backward compatibility
  final String? mandal;
  final String? village; // <--- Added Village Field
  final String? city;
  // final String town;
  final String pincode;
  final double latitude;
  final double longitude;
  final String? state;
  final String roadAccess; // Optional
  final String roadType; // Optional
  final double roadWidth; // Optional
  final String landFacing; // Optional
  final String propertyOwner;
  final List<String> images;
  final List<String> videos;
  final List<String> documents;
  final String? address; // <--- Added Address Field

  // **New Fields**
  final String userType; // 'Owner' or 'Agent'
  final String? ventureName; // Required for 'Plot' or 'Farm Land'

  final Timestamp createdAt;

  Property({
    this.id = '',
    required this.userId,
    required this.name,
    required this.mobileNumber,
    required this.propertyType,
    required this.landArea,
    required this.pricePerUnit,
    required this.totalPrice,
    required this.surveyNumber,
    required this.plotNumbers,
    this.city, // Added
    this.district, // Updated
    this.mandal,
    this.village, // Updated
    this.state,
    // required this.town,
    required this.pincode,
    required this.latitude,
    required this.longitude,
    // Updated
    this.roadAccess = '',
    this.roadType = '',
    this.roadWidth = 0.0,
    this.landFacing = '',
    required this.propertyOwner,
    required this.images,
    required this.videos,
    required this.documents,
    this.address,

    // **Initialize New Fields**
    required this.userType,
    this.ventureName,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'mobileNumber': mobileNumber,
      'propertyType': propertyType,
      'landArea': landArea,
      'pricePerUnit': pricePerUnit,
      'totalPrice': totalPrice,
      'surveyNumber': surveyNumber,
      'plotNumbers': plotNumbers,
      'district': district,
      'mandal': mandal,
      'village': village,
      'city': city,
      // 'town': town,
      'pincode': pincode,
      'latitude': latitude,
      'longitude': longitude,
      'state': state,
      'roadAccess': roadAccess,
      'roadType': roadType,
      'roadWidth': roadWidth,
      'landFacing': landFacing,
      'propertyOwner': propertyOwner,
      'images': images,
      'videos': videos,
      'documents': documents,
      'address': address,

      // **Include New Fields**
      'userType': userType,
      'ventureName': ventureName,

      'createdAt': createdAt,
    };
  }

  factory Property.fromMap(String id, Map<String, dynamic> map) {
    return Property(
      id: id,
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      mobileNumber: map['mobileNumber'] ?? '',
      propertyType: map['propertyType'] ?? '',
      landArea: map['landArea']?.toDouble() ?? 0.0,
      pricePerUnit: map['pricePerUnit']?.toDouble() ?? 0.0,
      totalPrice: map['totalPrice']?.toDouble() ?? 0.0,
      surveyNumber: map['surveyNumber'] ?? '',
      plotNumbers: List<String>.from(map['plotNumbers'] ?? []),
      district: map['district'], // Updated
      mandal: map['mandal'],
      village: map['village'], // Updated
      city: map['city'], // Added
      // town: map['town'] ?? '',
      pincode: map['pincode'] ?? '',
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      state: map['state'] ?? '',
      roadAccess: map['roadAccess'] ?? '',
      roadType: map['roadType'] ?? '',
      roadWidth: map['roadWidth']?.toDouble() ?? 0.0,
      landFacing: map['landFacing'] ?? '',
      propertyOwner: map['propertyOwner'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      videos: List<String>.from(map['videos'] ?? []),
      documents: List<String>.from(map['documents'] ?? []),
      address: map['address'],

      // **Initialize New Fields from Map**
      userType: map['userType'] ?? 'Owner',
      ventureName: map['ventureName'],

      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }

  // Added fromDocument factory constructor
  // factory Property.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
  //   final data = doc.data()!;
  //   return Property.fromMap(doc.id, data);
  // }
// In property_model.dart
  factory Property.fromDocument(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    return Property(
      id: doc.id,
      userId: doc['userId'] ?? '',
      name: doc['name'] ?? '',
      mobileNumber: doc['mobileNumber'] ?? '',
      propertyType: doc['propertyType'] ?? '',
      landArea: doc['landArea']?.toDouble() ?? 0.0,
      pricePerUnit: doc['pricePerUnit']?.toDouble() ?? 0.0,
      totalPrice: doc['totalPrice']?.toDouble() ?? 0.0,
      surveyNumber: doc['surveyNumber'] ?? '',
      plotNumbers: List<String>.from(doc['plotNumbers'] ?? []),
      district: doc['district'],
      mandal: doc['mandal'],
      village: doc['village'],
      city: doc['city'],
      pincode: doc['pincode'] ?? '',
      latitude: doc['latitude']?.toDouble() ?? 0.0,
      longitude: doc['longitude']?.toDouble() ?? 0.0,
      state: doc['state'] ?? '',
      roadAccess: doc['roadAccess'] ?? '',
      roadType: doc['roadType'] ?? '',
      roadWidth: doc['roadWidth']?.toDouble() ?? 0.0,
      landFacing: doc['landFacing'] ?? '',
      propertyOwner: doc['propertyOwner'] ?? '',
      images: List<String>.from(doc['images'] ?? []),
      videos: List<String>.from(doc['videos'] ?? []),
      documents: List<String>.from(doc['documents'] ?? []),
      address: doc['address'],
      userType: doc['userType'] ?? 'Owner',
      ventureName: doc['ventureName'],
      createdAt: doc['createdAt'] ?? Timestamp.now(),
    );
  }
}
