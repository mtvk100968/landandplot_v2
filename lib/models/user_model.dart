// lib/models/user_model.dart

class AppUser {
  final String uid;
  final String? name;
  final String? email;
  final String? phoneNumber;
  final List<String> postedPropertyIds;
  final List<String> favoritedPropertyIds;
  final List<String> inTalksPropertyIds;
  final List<String> boughtPropertyIds;

  AppUser({
    required this.uid,
    this.name,
    this.email,
    this.phoneNumber,
    List<String>? postedPropertyIds,
    List<String>? favoritedPropertyIds,
    List<String>? inTalksPropertyIds,
    List<String>? boughtPropertyIds,
  })  : postedPropertyIds = postedPropertyIds ?? [],
        favoritedPropertyIds = favoritedPropertyIds ?? [],
        inTalksPropertyIds = inTalksPropertyIds ?? [],
        boughtPropertyIds = boughtPropertyIds ?? [];

  // Convert AppUser object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'postedPropertyIds': postedPropertyIds,
      'favoritedPropertyIds': favoritedPropertyIds,
      'inTalksPropertyIds': inTalksPropertyIds,
      'boughtPropertyIds': boughtPropertyIds,
    };
  }

  // Create AppUser object from a Firestore DocumentSnapshot
  factory AppUser.fromDocument(Map<String, dynamic> doc) {
    return AppUser(
      uid: doc['uid'] ?? '',
      name: doc['name'],
      email: doc['email'],
      phoneNumber: doc['phoneNumber'],
      postedPropertyIds: List<String>.from(doc['postedPropertyIds'] ?? []),
      favoritedPropertyIds:
          List<String>.from(doc['favoritedPropertyIds'] ?? []),
      inTalksPropertyIds: List<String>.from(doc['inTalksPropertyIds'] ?? []),
      boughtPropertyIds: List<String>.from(doc['boughtPropertyIds'] ?? []),
    );
  }
}
