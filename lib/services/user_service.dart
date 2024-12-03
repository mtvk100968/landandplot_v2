// lib/services/user_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionPath = 'users';

  Future<void> saveUser(AppUser user) async {
    await _firestore.collection(collectionPath).doc(user.uid).set(
      user.toMap(),
      SetOptions(merge: true),
    );
  }

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

  // Add property to user's posted properties
  Future<void> addPropertyToUser(String userId, String propertyId) async {
    try {
      DocumentReference userRef =
      _firestore.collection(collectionPath).doc(userId);
      await userRef.update({
        'postedPropertyIds': FieldValue.arrayUnion([propertyId])
      });
    } catch (e) {
      throw Exception('Failed to link property to user');
    }
  }

  Future<void> addFavoriteProperty(String userId, String propertyId) async {
    DocumentReference userRef = _firestore.collection('users').doc(userId);
    await userRef.update({
      'favoritedPropertyIds': FieldValue.arrayUnion([propertyId]),
    });
  }

  Future<void> removeFavoriteProperty(String userId, String propertyId) async {
    DocumentReference userRef = _firestore.collection('users').doc(userId);
    await userRef.update({
      'favoritedPropertyIds': FieldValue.arrayRemove([propertyId]),
    });
  }

  // // Add property to user's favorited properties
  // Future<void> addFavoriteProperty(String userId, String propertyId) async {
  //   try {
  //     DocumentReference userRef =
  //     _firestore.collection(collectionPath).doc(userId);
  //     await userRef.update({
  //       'favoritedPropertyIds': FieldValue.arrayUnion([propertyId])
  //     });
  //   } catch (e) {
  //     throw Exception('Failed to favorite property for user');
  //   }
  // }
  //
  // // Remove property from user's favorited properties
  // Future<void> removeFavoriteProperty(String userId, String propertyId) async {
  //   try {
  //     DocumentReference userRef =
  //     _firestore.collection(collectionPath).doc(userId);
  //     await userRef.update({
  //       'favoritedPropertyIds': FieldValue.arrayRemove([propertyId])
  //     });
  //   } catch (e) {
  //     throw Exception('Failed to remove favorite property for user');
  //   }
  // }

  // Add property to user's in talks properties
  Future<void> addInTalksProperty(String userId, String propertyId) async {
    try {
      DocumentReference userRef =
      _firestore.collection(collectionPath).doc(userId);
      await userRef.update({
        'inTalksPropertyIds': FieldValue.arrayUnion([propertyId])
      });
    } catch (e) {
      throw Exception('Failed to add property to in-talks for user');
    }
  }

  // Add property to user's bought properties
  Future<void> addBoughtProperty(String userId, String propertyId) async {
    try {
      DocumentReference userRef =
      _firestore.collection(collectionPath).doc(userId);
      await userRef.update({
        'boughtPropertyIds': FieldValue.arrayUnion([propertyId])
      });
    } catch (e) {
      throw Exception('Failed to add bought property for user');
    }
  }

  // Future<void> toggleFavorite(String userId, String propertyId) async {
  //   DocumentReference userRef = _firestore.collection('users').doc(userId);
  //
  //   DocumentSnapshot userSnapshot = await userRef.get();
  //   if (userSnapshot.exists) {
  //     List<dynamic> favoritedPropertyIds = List.from(userSnapshot['favoritedPropertyIds'] ?? []);
  //
  //     if (favoritedPropertyIds.contains(propertyId)) {
  //       favoritedPropertyIds.remove(propertyId);
  //     } else {
  //       favoritedPropertyIds.add(propertyId);
  //     }
  //
  //     await userRef.update({'favoritedPropertyIds': favoritedPropertyIds});
  //   }
  // }
  Future<void> toggleFavorite(String userId, String propertyId) async {
    DocumentReference userRef = _firestore.collection('users').doc(userId);

    try {
      DocumentSnapshot userSnapshot = await userRef.get();
      if (userSnapshot.exists) {
        List<dynamic> favoritedPropertyIds =
        List.from(userSnapshot['favoritedPropertyIds'] ?? []);

        if (favoritedPropertyIds.contains(propertyId)) {
          favoritedPropertyIds.remove(propertyId);
        } else {
          favoritedPropertyIds.add(propertyId);
        }

        await userRef.update({'favoritedPropertyIds': favoritedPropertyIds});
      } else {
        // User document doesn't exist; create it
        await userRef.set({
          'favoritedPropertyIds': [propertyId],
          // Add other default fields if necessary
        });
      }
    } catch (e) {
      print('Error in UserService.toggleFavorite: $e');
      // Handle the error appropriately
      throw e; // Re-throw if necessary
    }
  }
}
