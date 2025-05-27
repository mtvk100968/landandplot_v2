class AppUser {
  final String uid;
  final String? name;
  final String? email;
  final String? phoneNumber;
  final String? photoUrl;
  // NEW: userType (admin, agent, or user)
  //an agent can do all the things a user can do - buying and selling, and also be the agent for other's properties - either by posting them or assigning by LANDANDPLOT
  final String userType;

  // Existing lists
  final List<String> postedPropertyIds; //posted by a user/agent
  final List<String> assignedPropertyIds; // for agents only
  final List<String> favoritedPropertyIds; //favorited by a user/agent
  final List<String>
      interestedPropertyIds; // for buyers/sellers - could be a user/agent
  final List<String>
      boughtPropertyIds; //properties you've bought, as a user/agent

  // NEW: agentAreas (for agents to show their areas of operation)
  final List<String> agentAreas;

  AppUser({
    required this.uid,
    this.name,
    this.email,
    this.phoneNumber,
    this.photoUrl,
    // default to 'user' if none is provided
    this.userType = 'user',
    List<String>? postedPropertyIds,
    List<String>? favoritedPropertyIds,
    List<String>? boughtPropertyIds,
    List<String>? interestedPropertyIds,
    List<String>? assignedPropertyIds,
    List<String>? agentAreas,
  })  : postedPropertyIds = postedPropertyIds ?? [],
        favoritedPropertyIds = favoritedPropertyIds ?? [],
        boughtPropertyIds = boughtPropertyIds ?? [],
        interestedPropertyIds = interestedPropertyIds ?? [],
        assignedPropertyIds = assignedPropertyIds ?? [],
        agentAreas = agentAreas ?? [];

  // Convert AppUser object to a Map for Firestore
  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{
      'uid': uid,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'userType': userType,
      if (photoUrl != null) 'photoUrl': photoUrl,
    };

    if (postedPropertyIds.isNotEmpty) {
      data['postedPropertyIds'] = postedPropertyIds;
    }
    if (favoritedPropertyIds.isNotEmpty) {
      data['favoritedPropertyIds'] = favoritedPropertyIds;
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
    // NEW: include agentAreas
    if (agentAreas.isNotEmpty) {
      data['agentAreas'] = agentAreas;
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
      photoUrl: doc['photoUrl'],
      userType: doc['userType'] ?? 'user',
      postedPropertyIds: List<String>.from(doc['postedPropertyIds'] ?? []),
      favoritedPropertyIds:
          List<String>.from(doc['favoritedPropertyIds'] ?? []),
      boughtPropertyIds: List<String>.from(doc['boughtPropertyIds'] ?? []),
      interestedPropertyIds:
          List<String>.from(doc['interestedPropertyIds'] ?? []),
      assignedPropertyIds: List<String>.from(doc['assignedPropertyIds'] ?? []),
      // NEW: load agentAreas
      agentAreas: List<String>.from(doc['agentAreas'] ?? []),
    );
  }

  AppUser copyWith({
    String? name,
    String? email,
    String? phoneNumber,
    String? userType,
    String? photoUrl,
    List<String>? postedPropertyIds,
    List<String>? favoritedPropertyIds,
    List<String>? boughtPropertyIds,
    List<String>? interestedPropertyIds,
    List<String>? assignedPropertyIds,
    List<String>? agentAreas,
  }) {
    return AppUser(
      uid: uid, // never changes
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      userType: userType ?? this.userType,
      postedPropertyIds: postedPropertyIds ?? this.postedPropertyIds,
      favoritedPropertyIds: favoritedPropertyIds ?? this.favoritedPropertyIds,
      boughtPropertyIds: boughtPropertyIds ?? this.boughtPropertyIds,
      interestedPropertyIds:
          interestedPropertyIds ?? this.interestedPropertyIds,
      assignedPropertyIds: assignedPropertyIds ?? this.assignedPropertyIds,
      agentAreas: agentAreas ?? this.agentAreas,
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
