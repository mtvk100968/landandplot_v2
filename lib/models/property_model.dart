import 'package:cloud_firestore/cloud_firestore.dart';
import './buyer_model.dart';

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
  final String? district;
  final String? mandal;
  final String? village;
  final String? city;
  final String pincode;
  final double latitude;
  final double longitude;
  final String? state;
  final String roadAccess;
  final String roadType;
  final double roadWidth;
  final String landFacing;
  final String propertyOwner;
  final List<String> images;
  final List<String> videos;
  final List<String> documents;
  final String? address;
  final String userType;
  final String? ventureName;
  final Timestamp createdAt;
  final bool? status;
  final bool? fencing;
  final bool? gate;
  final bool? bore;
  final bool? pipeline;
  final bool? electricity;
  final bool? plantation;
  final List<Buyer> interestedUsers;
  final List<Buyer> visitedUsers;

  // **Added proposedPrices field**
  final List<Map<String, dynamic>> proposedPrices;

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
    this.city,
    this.district,
    this.mandal,
    this.village,
    this.state,
    required this.pincode,
    required this.latitude,
    required this.longitude,
    this.roadAccess = '',
    this.roadType = '',
    this.roadWidth = 0.0,
    this.landFacing = '',
    required this.propertyOwner,
    required this.images,
    required this.videos,
    required this.documents,
    this.address,
    required this.userType,
    this.ventureName,
    required this.createdAt,
    this.status,
    this.fencing,
    this.gate,
    this.bore,
    this.pipeline,
    this.electricity,
    this.plantation,
    this.proposedPrices = const [], // Initialize as an empty list
    this.interestedUsers = const [],
    this.visitedUsers = const [],
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
      'userType': userType,
      'ventureName': ventureName,
      'createdAt': createdAt,
      'status': status,
      'fencing': fencing,
      'gate': gate,
      'bore': bore,
      'pipeline': pipeline,
      'electricity': electricity,
      'plantation': plantation,
      // **Include proposedPrices field in Firestore**
      'proposedPrices': proposedPrices,
      'interestedUsers': interestedUsers.map((e) => e.toMap()).toList(),
      'visitedUsers': visitedUsers.map((e) => e.toMap()).toList(),
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
      district: map['district'],
      mandal: map['mandal'],
      village: map['village'],
      city: map['city'],
      pincode: map['pincode'] ?? '',
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      state: map['state'],
      roadAccess: map['roadAccess'] ?? '',
      roadType: map['roadType'] ?? '',
      roadWidth: map['roadWidth']?.toDouble() ?? 0.0,
      landFacing: map['landFacing'] ?? '',
      propertyOwner: map['propertyOwner'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      videos: List<String>.from(map['videos'] ?? []),
      documents: List<String>.from(map['documents'] ?? []),
      address: map['address'],
      userType: map['userType'] ?? 'Owner',
      ventureName: map['ventureName'],
      createdAt: map['createdAt'] ?? Timestamp.now(),
      status: map['status'],
      fencing: map['fencing'],
      gate: map['gate'],
      bore: map['bore'],
      pipeline: map['pipeline'],
      electricity: map['electricity'],
      plantation: map['plantation'],
      // **Parse proposedPrices**
      proposedPrices: List<Map<String, dynamic>>.from(
        map['proposedPrices'] ?? [],
      ),
      interestedUsers: map['interestedUsers'] != null
          ? List<Map<String, dynamic>>.from(map['interestedUsers'])
              .map((e) => Buyer.fromMap(e))
              .toList()
          : [],
      visitedUsers: map['visitedUsers'] != null
          ? List<Map<String, dynamic>>.from(map['visitedUsers'])
              .map((e) => Buyer.fromMap(e))
              .toList()
          : [],
    );
  }

  factory Property.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Property.fromMap(doc.id, data);
  }
}
