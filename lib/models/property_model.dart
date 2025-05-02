import 'package:cloud_firestore/cloud_firestore.dart';
import './buyer_model.dart';

/// Real estate property, now with multi-agent & sale-stage
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
  final bool? fencing;
  final bool? gate;
  final bool? bore;
  final bool? pipeline;
  final bool? electricity;
  final bool? plantation;

  /// Buyers still in the find-buyer stage
  final List<Buyer> interestedUsers;

  /// Buyers who have visited & entered negotiations or closed
  final List<Buyer> visitedUsers;

  /// The buyer whose offer was accepted
  final Buyer? acceptedBuyer;

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
    this.fencing,
    this.gate,
    this.bore,
    this.pipeline,
    this.electricity,
    this.plantation,
    this.interestedUsers = const [],
    this.visitedUsers = const [],
    this.acceptedBuyer,
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
      'fencing': fencing,
      'gate': gate,
      'bore': bore,
      'pipeline': pipeline,
      'electricity': electricity,
      'plantation': plantation,
      'interestedUsers': interestedUsers.map((e) => e.toMap()).toList(),
      'visitedUsers': visitedUsers.map((e) => e.toMap()).toList(),
      'acceptedBuyer': acceptedBuyer?.toMap(),
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
      landArea: (m['landArea'] as num?)?.toDouble() ?? 0.0,
      pricePerUnit: (m['pricePerUnit'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (m['totalPrice'] as num?)?.toDouble() ?? 0.0,
      surveyNumber: m['surveyNumber'] ?? '',
      plotNumbers: List<String>.from(m['plotNumbers'] ?? []),
      district: m['district'],
      mandal: m['mandal'],
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
      propertyOwner: m['propertyOwner'] ?? '',
      images: List<String>.from(m['images'] ?? []),
      videos: List<String>.from(m['videos'] ?? []),
      documents: List<String>.from(m['documents'] ?? []),
      address: m['address'],
      userType: m['userType'] ?? '',
      ventureName: m['ventureName'],
      createdAt: m['createdAt'] as Timestamp,
      fencing: m['fencing'],
      gate: m['gate'],
      bore: m['bore'],
      pipeline: m['pipeline'],
      electricity: m['electricity'],
      plantation: m['plantation'],
      interestedUsers: (m['interestedUsers'] as List?)
              ?.map((e) => Buyer.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      visitedUsers: (m['visitedUsers'] as List?)
              ?.map((e) => Buyer.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      acceptedBuyer: m['acceptedBuyer'] != null
          ? Buyer.fromMap(m['acceptedBuyer'] as Map<String, dynamic>)
          : null,
      assignedAgentIds: List<String>.from(m['assignedAgentIds'] ?? []),
      winningAgentId: m['winningAgentId'] as String?,
      stage: m['stage'] ?? 'findingAgents',
    );
  }

  factory Property.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    return Property.fromMap(doc.id, doc.data()!);
  }
}
