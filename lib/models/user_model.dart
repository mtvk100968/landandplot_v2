class AppUser {
  final String uid;
  final String? name;
  final String? email;
  final String? phoneNumber;
  final String? photoUrl;
  final String userType; // admin | agent | user
  final bool profileComplete; // ← NEW

  final List<String> postedPropertyIds;
  final List<String> assignedPropertyIds;
  final List<String> favoritedPropertyIds;
  final List<String> interestedPropertyIds;
  final List<String> boughtPropertyIds;
  final List<String> agentAreas;
  final List<String> fcmTokens;
  final List<String> searchedAreas;

  AppUser({
    required this.uid,
    this.name,
    this.email,
    this.phoneNumber,
    this.photoUrl,
    this.userType = 'user',
    this.profileComplete = false, // ← default
    List<String>? postedPropertyIds,
    List<String>? favoritedPropertyIds,
    List<String>? boughtPropertyIds,
    List<String>? interestedPropertyIds,
    List<String>? assignedPropertyIds,
    List<String>? agentAreas,
    this.fcmTokens = const [],
    this.searchedAreas = const [],
  })  : postedPropertyIds = postedPropertyIds ?? [],
        favoritedPropertyIds = favoritedPropertyIds ?? [],
        boughtPropertyIds = boughtPropertyIds ?? [],
        interestedPropertyIds = interestedPropertyIds ?? [],
        assignedPropertyIds = assignedPropertyIds ?? [],
        agentAreas = agentAreas ?? [];

  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{
      'uid': uid,
      'userType': userType,
      'profileComplete': profileComplete, // ← include
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (postedPropertyIds.isNotEmpty) 'postedPropertyIds': postedPropertyIds,
      if (favoritedPropertyIds.isNotEmpty)
        'favoritedPropertyIds': favoritedPropertyIds,
      if (boughtPropertyIds.isNotEmpty) 'boughtPropertyIds': boughtPropertyIds,
      if (interestedPropertyIds.isNotEmpty)
        'interestedPropertyIds': interestedPropertyIds,
      if (assignedPropertyIds.isNotEmpty)
        'assignedPropertyIds': assignedPropertyIds,
      if (agentAreas.isNotEmpty) 'agentAreas': agentAreas,
      if (fcmTokens.isNotEmpty) 'fcmTokens': fcmTokens,
      if (searchedAreas.isNotEmpty) 'searchedAreas': searchedAreas,
    };
    return data;
  }

  factory AppUser.fromDocument(Map<String, dynamic> doc) {
    return AppUser(
      uid: doc['uid'] ?? '',
      name: doc['name'],
      email: doc['email'],
      phoneNumber: doc['phoneNumber'],
      photoUrl: doc['photoUrl'],
      userType: doc['userType'] ?? 'user',
      profileComplete: doc['profileComplete'] ?? false, // ← read
      postedPropertyIds: List<String>.from(doc['postedPropertyIds'] ?? []),
      favoritedPropertyIds:
          List<String>.from(doc['favoritedPropertyIds'] ?? []),
      boughtPropertyIds: List<String>.from(doc['boughtPropertyIds'] ?? []),
      interestedPropertyIds:
          List<String>.from(doc['interestedPropertyIds'] ?? []),
      assignedPropertyIds: List<String>.from(doc['assignedPropertyIds'] ?? []),
      agentAreas: List<String>.from(doc['agentAreas'] ?? []),
      fcmTokens: List<String>.from(doc['fcmTokens'] ?? []),
      searchedAreas: List<String>.from(doc['searchedAreas'] ?? []),
    );
  }

  AppUser copyWith({
    String? name,
    String? email,
    String? phoneNumber,
    String? userType,
    String? photoUrl,
    bool? profileComplete, // ← NEW
    List<String>? postedPropertyIds,
    List<String>? favoritedPropertyIds,
    List<String>? boughtPropertyIds,
    List<String>? interestedPropertyIds,
    List<String>? assignedPropertyIds,
    List<String>? agentAreas,
    List<String>? fcmTokens,
    List<String>? searchedAreas,
  }) {
    return AppUser(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      userType: userType ?? this.userType,
      profileComplete: profileComplete ?? this.profileComplete,
      postedPropertyIds: postedPropertyIds ?? this.postedPropertyIds,
      favoritedPropertyIds: favoritedPropertyIds ?? this.favoritedPropertyIds,
      boughtPropertyIds: boughtPropertyIds ?? this.boughtPropertyIds,
      interestedPropertyIds:
          interestedPropertyIds ?? this.interestedPropertyIds,
      assignedPropertyIds: assignedPropertyIds ?? this.assignedPropertyIds,
      agentAreas: agentAreas ?? this.agentAreas,
      fcmTokens: fcmTokens ?? this.fcmTokens,
      searchedAreas: searchedAreas ?? this.searchedAreas,
    );
  }

  /// search helper for agents/users
  bool matches(String query, {required String field}) {
    final q = query.toLowerCase();
    switch (field) {
      case 'Name':
        return (name ?? '').toLowerCase().contains(q);
      case 'Phone':
        return (phoneNumber ?? '').contains(q);
      case 'Areas':
        // for agents only; users tab will simply not call with field='Areas'
        return agentAreas.any((a) => a.toLowerCase().contains(q));
      default:
        return false;
    }
  }
}
