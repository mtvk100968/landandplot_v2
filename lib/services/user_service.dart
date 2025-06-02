// lib/services/user_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/property_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

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
      print('UserService.getUserById ERROR: $e');
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
      print('UserService.saveUser ERROR: $e');
      throw Exception('Failed to save user');
    }
  }

  /// Delete a user from Firestore
  Future<void> deleteUser(String userId) async {
    try {
      await _usersCollection.doc(userId).delete();
    } catch (e) {
      print('UserService.deleteUser ERROR: $e');
      throw Exception('Failed to delete user');
    }
  }

  /// Update user information
  Future<void> updateUser(AppUser user) async {
    try {
      await _usersCollection.doc(user.uid).update(user.toMap());
    } catch (e) {
      print('UserService.updateUser ERROR: $e');
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
      print('UserService.addFavoriteProperty ERROR: $e');
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
      print('UserService.removeFavoriteProperty ERROR: $e');
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
      print('UserService.addPropertyToUser ERROR: $e');
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
      print('UserService.addInTalksProperty ERROR: $e');
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
      print('UserService.addBoughtProperty ERROR: $e');
      throw Exception('Failed to add bought property');
    }
  }

  /// Fetch all properties this user has posted by looking at postedPropertyIds
  Future<List<Property>> getSellerProperties(String userId) async {
    try {
      final user = await getUserById(userId);
      if (user == null) {
        print('getSellerProperties: no user found for userId=$userId');
        return [];
      }
      if (user.postedPropertyIds.isEmpty) {
        print(
            'getSellerProperties: postedPropertyIds is empty for userId=$userId');
        return [];
      }
      final props = await getPropertiesByIds(user.postedPropertyIds);
      print(
          'getSellerProperties: retrieved ${props.length} properties for userId=$userId');
      return props;
    } catch (e) {
      print('UserService.getSellerProperties ERROR: $e');
      return [];
    }
  }

  /// Fetch only the properties this user has posted in a given stage
  Future<List<Property>> getSellerPropertiesByStage(
      String userId, String stage) async {
    try {
      final user = await getUserById(userId);
      if (user == null) {
        print('getSellerPropertiesByStage: no user found for userId=$userId');
        return [];
      }
      if (user.postedPropertyIds.isEmpty) {
        print(
            'getSellerPropertiesByStage: postedPropertyIds is empty for userId=$userId');
        return [];
      }

      final allProps = await getPropertiesByIds(user.postedPropertyIds);
      final filtered = allProps.where((p) => p.stage == stage).toList();

      print(
          'getSellerPropertiesByStage: userId=$userId, stage=$stage, totalPosted=${allProps.length}, matched=${filtered.length}');

      return filtered;
    } catch (e) {
      print('UserService.getSellerPropertiesByStage ERROR: $e');
      return [];
    }
  }

  /// Fetch properties this user is interested in (in-talks)
  Future<List<Property>> getInTalksProperties(String userId) async {
    try {
      final user = await getUserById(userId);
      if (user == null || user.interestedPropertyIds.isEmpty) {
        print(
            'getInTalksProperties: no user or no interestedPropertyIds for userId=$userId');
        return [];
      }
      final props = await getPropertiesByIds(user.interestedPropertyIds);
      print(
          'getInTalksProperties: retrieved ${props.length} properties for userId=$userId');
      return props;
    } catch (e) {
      print('UserService.getInTalksProperties ERROR: $e');
      return [];
    }
  }

  /// Fetch properties this user has bought
  Future<List<Property>> getBoughtProperties(String userId) async {
    try {
      final user = await getUserById(userId);
      if (user == null || user.boughtPropertyIds.isEmpty) {
        print(
            'getBoughtProperties: no user or no boughtPropertyIds for userId=$userId');
        return [];
      }
      final props = await getPropertiesByIds(user.boughtPropertyIds);
      print(
          'getBoughtProperties: retrieved ${props.length} properties for userId=$userId');
      return props;
    } catch (e) {
      print('UserService.getBoughtProperties ERROR: $e');
      return [];
    }
  }

  /// Fetch multiple Property documents by their IDs
  Future<List<Property>> getPropertiesByIds(List<String> propertyIds) async {
    try {
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
      print('getPropertiesByIds: retrieved ${all.length} properties by IDs');
      return all;
    } catch (e) {
      print('UserService.getPropertiesByIds ERROR: $e');
      return [];
    }
  }

  /// Fetch a user by their phone number
  Future<AppUser?> getUserByPhoneNumber(String phoneNumber) async {
    try {
      final snap = await _usersCollection
          .where('phoneNumber', isEqualTo: phoneNumber)
          .get();
      if (snap.docs.isNotEmpty) {
        return AppUser.fromDocument(snap.docs.first.data());
      }
      return null;
    } catch (e) {
      print('UserService.getUserByPhoneNumber ERROR: $e');
      return null;
    }
  }

  /// Uploads a new profile image for [uid], updates Firestore, and returns the download URL.
  Future<String> uploadProfileImage({
    required String uid,
    required File file,
  }) async {
    try {
      // 1. Upload file to Firebase Storage under "profile_photos/{uid}.jpg"
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_photos')
          .child('$uid.jpg');

      final uploadTask = storageRef.putFile(file);
      final snapshot = await uploadTask.whenComplete(() {});

      // 2. Get the download URL of the uploaded image
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // 3. Update the user's Firestore document with the new photoUrl
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'photoUrl': downloadUrl});

      return downloadUrl;
    } catch (e) {
      print('UserService.uploadProfileImage ERROR: $e');
      rethrow;
    }
  }
}
