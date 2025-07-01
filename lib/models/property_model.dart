//
import 'package:cloud_firestore/cloud_firestore.dart';
import './buyer_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Real estate property, now with unified buyers list & sale-stage
class Property {
  final String id;
  final String userId;
  final String name;
  final String mobileNumber;
  final String propertyType;
  final String? subtype;         // ← NEW
  final String? reraNo; // NEW: optional RERA number
  final String landAreaUnitRaw;
  final String? bedrooms;
  final String? bathrooms;
  final double? carpetArea;
  final double? constructedArea;
  final double? plotArea;
  final double landArea;
  final double pricePerUnit;
  final double totalPrice;
  final String surveyNumber;
  final List<String> plotNumbers;
  final String? district;
  // final String? mandal;
  final String? taluqMandal;
  final String? village;
  final String? city;
  final String pincode;
  final double latitude;
  final double longitude;
  final String? state;
  final String propertyOwner;
  final List<String> images;
  final List<String> videos;
  final List<String> documents;
  final String? address;
  final String userType;
  final String? ventureName;
  final Timestamp createdAt;
  final String? ownerBuilderShare;
  final bool? fencing;
  final bool? gate;
  final bool? bore;
  final bool? pipeline;
  final bool? electricity;
  final bool? plantation;
  final List<String> amenities;
  // final List<String> agri_amenities;

  // New fields for zoning and roads
  final String? zone; // new
  final String? roadType;
  final double? roadWidth;
  final String? lengthFacing; // new
  final String? nala; // new
  final String roadAccess;
  final String landFacing;

  /// All buyers in various statuses: 'visitPending', 'negotiating', 'accepted', 'rejected'
  final List<Buyer> buyers;

  /// Agents currently working to find a buyer
  final List<String> assignedAgentIds;

  /// Agent who successfully closed the sale
  final String? winningAgentId;

  /// 'findingAgents', 'findingBuyers', 'saleInProgress', or 'sold'
  final String stage;

  Property({
    this.id = '',
    required this.userId,
    required this.name,
    required this.mobileNumber,
    required this.propertyType,
    this.subtype,                // ← NEW
    required this.landAreaUnitRaw,
    this.reraNo,
    this.bedrooms,
    this.bathrooms,
    this.carpetArea,
    this.constructedArea,
    this.plotArea,
    required this.landArea,
    required this.pricePerUnit,
    required this.totalPrice,
    required this.surveyNumber,
    required this.plotNumbers,
    this.city,
    this.district,
    // this.mandal,
    this.village,
    this.state,
    this.taluqMandal,
    required this.pincode,
    required this.latitude,
    required this.longitude,
    this.roadAccess = '',
    this.roadType = '',
    this.roadWidth = 0.0,
    this.landFacing = '',
    required this.zone,
    required this.propertyOwner,
    required this.lengthFacing,
    required this.nala,
    required this.images,
    required this.videos,
    required this.documents,
    this.address,
    required this.userType,
    this.ventureName,
    required this.createdAt,
    required this.amenities,
    // required this.agri_amenities,
    this.ownerBuilderShare,
    this.fencing,
    this.gate,
    this.bore,
    this.pipeline,
    this.electricity,
    this.plantation,
    this.buyers = const [],
    List<String>? assignedAgentIds,
    this.winningAgentId,
    this.stage = 'findingAgents',
  }) : assignedAgentIds = assignedAgentIds ?? [];

  /// Serialize to Firestore
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'userId': userId,
      'name': name,
      'mobileNumber': mobileNumber,
      'propertyType': propertyType,
      'subtype': subtype,         // ← NEW
      'landAreaUnitRaw': landAreaUnitRaw,         // ← NEW
      'reraNo': reraNo,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'carpetArea': carpetArea,
      'constructedArea': constructedArea,
      'plotArea': plotArea,
      'landArea': landArea,
      'pricePerUnit': pricePerUnit,
      'totalPrice': totalPrice,
      'surveyNumber': surveyNumber,
      'plotNumbers': plotNumbers,
      'district': district,
      'taluqMandal': taluqMandal,
      'village': village,
      'city': city,
      'pincode': pincode,
      'latitude': latitude,
      'longitude': longitude,
      'state': state,
      'roadAccess': roadAccess,
      'roadType': roadType,
      'roadWidth': roadWidth,
      'landFacing': landFacing,
      'zone': zone,
      'lengthFacing': lengthFacing,
      'nala': nala,
      'propertyOwner': propertyOwner,
      'images': images,
      'videos': videos,
      'documents': documents,
      'address': address,
      'userType': userType,
      'ventureName': ventureName,
      'createdAt': createdAt,
      'ownerBuilderShare': ownerBuilderShare,
      'amenities': amenities,
      // 'agri_amenities': agri_amenities,
      'fencing': fencing,
      'gate': gate,
      'bore': bore,
      'pipeline': pipeline,
      'electricity': electricity,
      'plantation': plantation,
      'buyers': buyers.map((b) => b.toMap()).toList(),
      'assignedAgentIds': assignedAgentIds,
      'winningAgentId': winningAgentId,
      'stage': stage,
    };
    return map;
  }

  /// Deserialize from Firestore map
  factory Property.fromMap(String id, Map<String, dynamic> m) {
    return Property(
      id: id,
      userId: m['userId'] ?? '',
      name: m['name'] ?? '',
      mobileNumber: m['mobileNumber'] ?? '',
      propertyType: m['propertyType'] ?? '',
      subtype: m['subtype'] as String?,  // ← NEW
      landAreaUnitRaw: m['landAreaUnitRaw'] as String? ?? 'sqyd',
      reraNo: m['reraNo'] ?? '',
      bedrooms: m['bedrooms'],
      bathrooms: m['bathrooms'],
      carpetArea:      (m['carpetArea']      as num?)?.toDouble(),
      constructedArea: (m['constructedArea'] as num?)?.toDouble(),
      plotArea:        (m['plotArea']        as num?)?.toDouble(),
      landArea:        (m['landArea']        as num?)!.toDouble(),
      pricePerUnit: (m['pricePerUnit'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (m['totalPrice'] as num?)?.toDouble() ?? 0.0,
      surveyNumber: m['surveyNumber'] ?? '',
      plotNumbers: List<String>.from(m['plotNumbers'] ?? []),
      district: m['district'],
      taluqMandal: m['taluqMandal'],
      village: m['village'],
      city: m['city'],
      pincode: m['pincode'] ?? '',
      latitude: (m['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (m['longitude'] as num?)?.toDouble() ?? 0.0,
      state: m['state'],
      roadAccess: m['roadAccess'] ?? '',
      roadType: m['roadType'] ?? '',
      roadWidth: (m['roadWidth'] as num?)?.toDouble() ?? 0.0,
      landFacing: m['landFacing'] ?? '',
      zone: m['zone'] ?? '',
      lengthFacing: m['lengthFacing'] ?? '',
      nala: m['nala'] ?? '',
      propertyOwner: m['propertyOwner'] ?? '',
      images: List<String>.from(m['images'] ?? []),
      videos: List<String>.from(m['videos'] ?? []),
      documents: List<String>.from(m['documents'] ?? []),
      address: m['address'],
      userType: m['userType'] ?? '',
      ventureName: m['ventureName'],
      createdAt: m['createdAt'] as Timestamp,
      amenities: List<String>.from(m['amenities'] ?? []),
      // agri_amenities: List<String>.from(m['agri_amenities'] ?? []),
      fencing: m['fencing'],
      gate: m['gate'],
      bore: m['bore'],
      pipeline: m['pipeline'],
      electricity: m['electricity'],
      plantation: m['plantation'],
      buyers: (m['buyers'] as List?)
          ?.map((e) => Buyer.fromMap(e as Map<String, dynamic>))
          .toList() ??
          [],
      assignedAgentIds: List<String>.from(m['assignedAgentIds'] ?? []),
      winningAgentId: m['winningAgentId'] as String?,
      stage: m['stage'] ?? 'findingAgents',
    );
  }

  factory Property.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    return Property.fromMap(doc.id, doc.data()!);
  }

  /// shorthand for your own fromMap()
  /// shorthand for your own fromMap()
  factory Property.fromFirestore(String id, Map<String, dynamic> data) =>
      Property.fromMap(id, data);

  @override
  LatLng get location => LatLng(latitude, longitude);

  /// true if at least one agent is assigned
  bool get isAssigned => assignedAgentIds.isNotEmpty;

  /// true if no agents are yet assigned
  bool get isUnassigned => assignedAgentIds.isEmpty;

  /// cluster_manager also now wants a geohash for spatial indexing
  /// you can return any consistent string per point (e.g. a lat_lng key).
  @override
  String get geohash =>
      '${latitude.toStringAsFixed(6)}_${longitude.toStringAsFixed(6)}';

  /// simple name-based search (you can expand to other fields later)
  bool matches(String query) =>
      name.toLowerCase().contains(query.toLowerCase());

  String get fullAddress {
    if (address != null && address!.isNotEmpty) {
      return address!;
    }
    final parts = [
      village,
      taluqMandal,
      city,
      state,
      pincode,
    ];
    return parts.where((p) => p != null && p.isNotEmpty).join(', ');
  }
}

/// Helpers to expose the same keys your filter code expects.
extension PropertyFiltering on Property {
  /// Used by your client‐side filter to compare against the
  /// Firestore propertyType field.
  String get propertyTypeKey => propertyType;

  /// Used by your client‐side filter to compare against the
  /// Firestore subtype field.
  String? get subtypeKey => subtype;
}
