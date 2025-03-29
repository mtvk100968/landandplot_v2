class AppUser {
  final String uid;
  final String? name;
  final String? email;
  final String? phoneNumber;

  // NEW: userType (admin, agent, or user)
  final String userType;

  // Existing lists
  final List<String> postedPropertyIds;
  final List<String> favoritedPropertyIds;
  final List<String> inTalksPropertyIds;
  final List<String> boughtPropertyIds;

  // NEW: additional lists
  final List<String> interestedPropertyIds; // for buyers/sellers
  final List<String> assignedPropertyIds; // for agents

  AppUser({
    required this.uid,
    this.name,
    this.email,
    this.phoneNumber,
    // default to 'user' if none is provided
    this.userType = 'user',
    List<String>? postedPropertyIds,
    List<String>? favoritedPropertyIds,
    List<String>? inTalksPropertyIds,
    List<String>? boughtPropertyIds,
    List<String>? interestedPropertyIds,
    List<String>? assignedPropertyIds,
  })  : postedPropertyIds = postedPropertyIds ?? [],
        favoritedPropertyIds = favoritedPropertyIds ?? [],
        inTalksPropertyIds = inTalksPropertyIds ?? [],
        boughtPropertyIds = boughtPropertyIds ?? [],
        interestedPropertyIds = interestedPropertyIds ?? [],
        assignedPropertyIds = assignedPropertyIds ?? [];

  // Convert AppUser object to a Map for Firestore
  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{
      'uid': uid,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'userType': userType,
    };
    if (postedPropertyIds.isNotEmpty) {
      data['postedPropertyIds'] = postedPropertyIds;
    }
    if (favoritedPropertyIds.isNotEmpty) {
      data['favoritedPropertyIds'] = favoritedPropertyIds;
    }
    if (inTalksPropertyIds.isNotEmpty) {
      data['inTalksPropertyIds'] = inTalksPropertyIds;
    }
    if (boughtPropertyIds.isNotEmpty) {
      data['boughtPropertyIds'] = boughtPropertyIds;
    }
    if (interestedPropertyIds.isNotEmpty) {
      data['interestedPropertyIds'] = interestedPropertyIds;
    }
    if (assignedPropertyIds.isNotEmpty) {
      data['assignedPropertyIds'] = assignedPropertyIds;
    }
    return data;
  }

  // Create AppUser object from a Firestore DocumentSnapshot
  factory AppUser.fromDocument(Map<String, dynamic> doc) {
    return AppUser(
      uid: doc['uid'] ?? '',
      name: doc['name'],
      email: doc['email'],
      phoneNumber: doc['phoneNumber'],
      userType: doc['userType'] ?? 'user',
      postedPropertyIds: List<String>.from(doc['postedPropertyIds'] ?? []),
      favoritedPropertyIds:
          List<String>.from(doc['favoritedPropertyIds'] ?? []),
      inTalksPropertyIds: List<String>.from(doc['inTalksPropertyIds'] ?? []),
      boughtPropertyIds: List<String>.from(doc['boughtPropertyIds'] ?? []),
      interestedPropertyIds:
          List<String>.from(doc['interestedPropertyIds'] ?? []),
      assignedPropertyIds: List<String>.from(doc['assignedPropertyIds'] ?? []),
    );
  }
}
