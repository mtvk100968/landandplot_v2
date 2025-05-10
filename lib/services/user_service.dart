// lib/services/user_service.dart

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
      final doc = await _usersCollection.doc(userId).get();
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
            SetOptions(merge: true),
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

  /// Add a property to the user's in-talks (interested) properties
  Future<void> addInTalksProperty(String userId, String propertyId) async {
    try {
      await _usersCollection.doc(userId).update({
        'interestedPropertyIds': FieldValue.arrayUnion([propertyId]),
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

  /// Fetch properties this user is selling (i.e., posted by them)
  Future<List<Property>> getSellerProperties(String userId) async {
    final snap =
        await _propertiesCollection.where('userId', isEqualTo: userId).get();
    return snap.docs.map((doc) => Property.fromDocument(doc)).toList();
  }

  /// Fetch properties this user is interested in (in-talks)
  Future<List<Property>> getInTalksProperties(String userId) async {
    final user = await getUserById(userId);
    if (user == null || user.interestedPropertyIds.isEmpty) return [];
    return getPropertiesByIds(user.interestedPropertyIds);
  }

  /// Fetch properties this user has bought
  Future<List<Property>> getBoughtProperties(String userId) async {
    final user = await getUserById(userId);
    if (user == null || user.boughtPropertyIds.isEmpty) return [];
    return getPropertiesByIds(user.boughtPropertyIds);
  }

  /// Fetch multiple Property documents by their IDs
  Future<List<Property>> getPropertiesByIds(List<String> propertyIds) async {
    if (propertyIds.isEmpty) return [];
    List<Property> all = [];
    const batchSize = 10;
    for (var i = 0; i < propertyIds.length; i += batchSize) {
      final end = (i + batchSize < propertyIds.length)
          ? i + batchSize
          : propertyIds.length;
      final batch = propertyIds.sublist(i, end);
      final snap = await _propertiesCollection
          .where(FieldPath.documentId, whereIn: batch)
          .get();
      all.addAll(snap.docs.map((d) => Property.fromDocument(d)));
    }
    return all;
  }

  Future<AppUser?> getUserByPhoneNumber(String phoneNumber) async {
    final snap = await _usersCollection
        .where('phoneNumber', isEqualTo: phoneNumber)
        .get();
    if (snap.docs.isNotEmpty) {
      return AppUser.fromDocument(snap.docs.first.data());
    }
    return null;
  }
}
