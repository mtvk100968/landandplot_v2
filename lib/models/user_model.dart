class AppUser {
  final String uid;
  final String? name;
  final String? email;
  final String? phoneNumber;

  AppUser({
    required this.uid,
    this.name,
    this.email,
    this.phoneNumber,
  });

  // Convert AppUser object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
    };
  }

  // Create AppUser object from a Firestore DocumentSnapshot
  factory AppUser.fromDocument(Map<String, dynamic> doc) {
    return AppUser(
      uid: doc['uid'] ?? '',
      name: doc['name'],
      email: doc['email'],
      phoneNumber: doc['phoneNumber'],
    );
  }
}