import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/property_model.dart';

class UserService {
  // Reference to the 'users' collection
  final CollectionReference<Map<String, dynamic>> _usersCollection =
      FirebaseFirestore.instance.collection('users');

  // Reference to the 'properties' collection
  final CollectionReference<Map<String, dynamic>> _propertiesCollection =
      FirebaseFirestore.instance.collection('properties');

  /// Fetch a user by their UID
  Future<AppUser?> getUserById(String userId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc =
          await _usersCollection.doc(userId).get();
      if (doc.exists && doc.data() != null) {
        return AppUser.fromDocument(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error fetching user by ID: $e');
      return null;
    }
  }

  /// Listen to real-time updates of a user by their UID
  Stream<AppUser?> getUserStream(String userId) {
    return _usersCollection.doc(userId).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return AppUser.fromDocument(doc.data()!);
      }
      return null;
    });
  }

  /// Create or update a user in Firestore
  Future<void> saveUser(AppUser user) async {
    try {
      await _usersCollection.doc(user.uid).set(
            user.toMap(),
            SetOptions(merge: true), // Merges with existing data if available
          );
    } catch (e) {
      print('Error saving user: $e');
      throw Exception('Failed to save user');
    }
  }

  /// Delete a user from Firestore
  Future<void> deleteUser(String userId) async {
    try {
      await _usersCollection.doc(userId).delete();
    } catch (e) {
      print('Error deleting user: $e');
      throw Exception('Failed to delete user');
    }
  }

  /// Update user information
  Future<void> updateUser(AppUser user) async {
    try {
      await _usersCollection.doc(user.uid).update(user.toMap());
    } catch (e) {
      print('Error updating user: $e');
      throw Exception('Failed to update user');
    }
  }

  /// Add a property to the user's favorites
  Future<void> addFavoriteProperty(String userId, String propertyId) async {
    try {
      await _usersCollection.doc(userId).set({
        'favoritedPropertyIds': FieldValue.arrayUnion([propertyId]),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error adding favorite property: $e');
      throw Exception('Failed to add favorite property');
    }
  }

  /// Remove a property from the user's favorites
  Future<void> removeFavoriteProperty(String userId, String propertyId) async {
    try {
      await _usersCollection.doc(userId).set({
        'favoritedPropertyIds': FieldValue.arrayRemove([propertyId]),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error removing favorite property: $e');
      throw Exception('Failed to remove favorite property');
    }
  }

  /// Add a property to the user's posted properties
  Future<void> addPropertyToUser(String userId, String propertyId) async {
    try {
      await _usersCollection.doc(userId).update({
        'postedPropertyIds': FieldValue.arrayUnion([propertyId]),
      });
    } catch (e) {
      print('Error adding property to user: $e');
      throw Exception('Failed to add property to user');
    }
  }

  /// Add a property to the user's in-talks properties
  Future<void> addInTalksProperty(String userId, String propertyId) async {
    try {
      await _usersCollection.doc(userId).update({
        'inTalksPropertyIds': FieldValue.arrayUnion([propertyId]),
      });
    } catch (e) {
      print('Error adding in-talks property: $e');
      throw Exception('Failed to add in-talks property');
    }
  }

  /// Add a property to the user's bought properties
  Future<void> addBoughtProperty(String userId, String propertyId) async {
    try {
      await _usersCollection.doc(userId).update({
        'boughtPropertyIds': FieldValue.arrayUnion([propertyId]),
      });
    } catch (e) {
      print('Error adding bought property: $e');
      throw Exception('Failed to add bought property');
    }
  }

  /// Fetch multiple Property documents by their IDs
  Future<List<Property>> getPropertiesByIds(List<String> propertyIds) async {
    if (propertyIds.isEmpty) {
      return [];
    }

    List<Property> allProperties = [];

    try {
      // Firestore's `whereIn` has a limit of 10 items per query.
      // Split the propertyIds into batches of 10.
      List<List<String>> batches = [];
      int batchSize = 10;
      for (var i = 0; i < propertyIds.length; i += batchSize) {
        int end = (i + batchSize < propertyIds.length)
            ? i + batchSize
            : propertyIds.length;
        batches.add(propertyIds.sublist(i, end));
      }

      // Iterate over each batch and fetch properties
      for (var batch in batches) {
        QuerySnapshot<Map<String, dynamic>> snapshot =
            await _propertiesCollection
                .where(FieldPath.documentId, whereIn: batch)
                .get();

        List<Property> properties = snapshot.docs.map((doc) {
          return Property.fromDocument(doc);
        }).toList();

        allProperties.addAll(properties);
      }

      return allProperties;
    } catch (e) {
      print('Error fetching properties by IDs: $e');
      return [];
    }
  }

  Future<AppUser?> getUserByPhoneNumber(String phoneNumber) async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await _usersCollection
        .where('phoneNumber', isEqualTo: phoneNumber)
        .get();
    if (snapshot.docs.isNotEmpty) {
      return AppUser.fromDocument(snapshot.docs.first.data());
    }
    return null;
  }
}
