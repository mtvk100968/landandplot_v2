import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionPath = 'users';

  // Create or update a user in Firestore
  Future<void> saveUser(AppUser user) async {
    await _firestore.collection(collectionPath).doc(user.uid).set(
          user.toMap(),
          SetOptions(merge: true), // Merges with existing data if available
        );
  }

  // Fetch a user from Firestore by UID
  Future<AppUser?> getUserById(String uid) async {
    DocumentSnapshot<Map<String, dynamic>> doc =
        await _firestore.collection(collectionPath).doc(uid).get();
    if (doc.exists) {
      return AppUser.fromDocument(doc.data()!);
    }
    return null;
  }

  // Delete a user from Firestore
  Future<void> deleteUser(String uid) async {
    await _firestore.collection(collectionPath).doc(uid).delete();
  }

  // Update user information
  Future<void> updateUser(AppUser user) async {
    await _firestore
        .collection(collectionPath)
        .doc(user.uid)
        .update(user.toMap());
  }

  Future<void> addPropertyToUser(String userId, String propertyId) async {
    try {
      DocumentReference userRef =
          _firestore.collection(collectionPath).doc(userId);
      await userRef.update({
        'propertyIds': FieldValue.arrayUnion([propertyId])
      });
    } catch (e) {
      throw Exception('Failed to link property to user');
    }
  }
}
