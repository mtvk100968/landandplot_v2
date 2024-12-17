// lib/models/user_model.dart

class AppUser {
  final String uid;
  final String? name;
  final String? email;
  final String? phoneNumber;
  final String? city;
  final String? state;
  final String? district;
  final String? pincode;
  final String? extraAddress;
  final List<String> postedPropertyIds;
  final List<String> favoritedPropertyIds;
  final List<String> inTalksPropertyIds;
  final List<String> boughtPropertyIds;

  AppUser({
    required this.uid,
    this.name,
    this.email,
    this.phoneNumber,
    this.city,
    this.state,
    this.district,
    this.pincode,
    this.extraAddress,
    List<String>? postedPropertyIds,
    List<String>? favoritedPropertyIds,
    List<String>? inTalksPropertyIds,
    List<String>? boughtPropertyIds,
  })  : postedPropertyIds = postedPropertyIds ?? [],
        favoritedPropertyIds = favoritedPropertyIds ?? [],
        inTalksPropertyIds = inTalksPropertyIds ?? [],
        boughtPropertyIds = boughtPropertyIds ?? [];

  // Factory constructor for an empty user
  factory AppUser.empty() {
    return AppUser(
      uid: '',
      name: null,
      email: null,
      phoneNumber: null,
      city: null,
      state: null,
      district: null,
      pincode: null,
      extraAddress: null,
      postedPropertyIds: [],
      favoritedPropertyIds: [],
      inTalksPropertyIds: [],
      boughtPropertyIds: [],
    );
  }

  // Convert AppUser object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'city': city,
      'state': state,
      'district': district,
      'pincode': pincode,
      'extraAddress': extraAddress,
      'postedPropertyIds': postedPropertyIds,
      'favoritedPropertyIds': favoritedPropertyIds,
      'inTalksPropertyIds': inTalksPropertyIds,
      'boughtPropertyIds': boughtPropertyIds,
    };
  }

  // Create AppUser object from a Firestore DocumentSnapshot
  factory AppUser.fromDocument(Map<String, dynamic> doc) {
    final phoneNumber = doc['phoneNumber'] as String?;
    return AppUser(
      uid: phoneNumber ?? doc['uid'] ?? '', // Use phoneNumber as UID if available
      name: doc['name'],
      email: doc['email'],
      phoneNumber: phoneNumber,
      city: doc['city'],
      state: doc['state'],
      district: doc['district'],
      pincode: doc['pincode'],
      extraAddress: doc['extraAddress'],
      postedPropertyIds: List<String>.from(doc['postedPropertyIds'] ?? []),
      favoritedPropertyIds: List<String>.from(doc['favoritedPropertyIds'] ?? []),
      inTalksPropertyIds: List<String>.from(doc['inTalksPropertyIds'] ?? []),
      boughtPropertyIds: List<String>.from(doc['boughtPropertyIds'] ?? []),
    );
  }
}
