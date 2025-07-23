import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/user_model.dart';
import '../models/property_model.dart';
import '../models/buyer_model.dart';

class UserService {
  final CollectionReference<Map<String, dynamic>> _usersCollection =
      FirebaseFirestore.instance.collection('users');

  final CollectionReference<Map<String, dynamic>> _propertiesCollection =
      FirebaseFirestore.instance.collection('properties');

  // -------- USERS --------

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

  Stream<AppUser?> getUserStream(String userId) {
    return _usersCollection.doc(userId).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return AppUser.fromDocument(doc.data()!);
      }
      return null;
    });
  }

  /// Create or merge-update a user.
  /// Does NOT overwrite existing non-empty fields with null/empty.
  Future<void> saveUser(AppUser user) async {
    final ref = _usersCollection.doc(user.uid);
    final snap = await ref.get();

    if (snap.exists && snap.data() != null) {
      final current = AppUser.fromDocument(snap.data()!);

      final map = <String, dynamic>{
        if (user.name != null && user.name!.trim().isNotEmpty)
          'name': user.name,
        if (user.email != null && user.email!.trim().isNotEmpty)
          'email': user.email,
        if (user.phoneNumber != null && user.phoneNumber!.trim().isNotEmpty)
          'phoneNumber': user.phoneNumber,
        // never downgrade role
        'userType': user.userType.isNotEmpty ? user.userType : current.userType,
        // profileComplete only flips to true; never force false if current is true
        'profileComplete':
            current.profileComplete || user.profileComplete ? true : false,
        if (user.photoUrl != null && user.photoUrl!.isNotEmpty)
          'photoUrl': user.photoUrl,
        if (user.postedPropertyIds.isNotEmpty)
          'postedPropertyIds': user.postedPropertyIds,
        if (user.favoritedPropertyIds.isNotEmpty)
          'favoritedPropertyIds': user.favoritedPropertyIds,
        if (user.boughtPropertyIds.isNotEmpty)
          'boughtPropertyIds': user.boughtPropertyIds,
        if (user.interestedPropertyIds.isNotEmpty)
          'interestedPropertyIds': user.interestedPropertyIds,
        if (user.assignedPropertyIds.isNotEmpty)
          'assignedPropertyIds': user.assignedPropertyIds,
        if (user.agentAreas.isNotEmpty) 'agentAreas': user.agentAreas,
        if (user.fcmTokens.isNotEmpty) 'fcmTokens': user.fcmTokens,
        if (user.searchedAreas.isNotEmpty) 'searchedAreas': user.searchedAreas,
      };

      await ref.set(map, SetOptions(merge: true));
    } else {
      await ref.set(user.toMap());
    }
  }

  /// Merge-safe update using full model (skips null/empty inside toMap anyway)
  Future<void> updateUser(AppUser user) async {
    try {
      await _usersCollection.doc(user.uid).set(
            user.toMap(),
            SetOptions(merge: true),
          );
    } catch (e) {
      print('UserService.updateUser ERROR: $e');
      throw Exception('Failed to update user');
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _usersCollection.doc(userId).delete();
    } catch (e) {
      print('UserService.deleteUser ERROR: $e');
      throw Exception('Failed to delete user');
    }
  }

  Future<AppUser?> getUserByPhoneNumber(String phoneNumber) async {
    try {
      final snap = await _usersCollection
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1)
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

  Future<String> uploadProfileImage({
    required String uid,
    required File file,
  }) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_photos')
          .child('$uid.jpg');

      final snapshot = await storageRef.putFile(file).whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      await _usersCollection.doc(uid).set(
        {'photoUrl': downloadUrl},
        SetOptions(merge: true),
      );

      return downloadUrl;
    } catch (e) {
      print('UserService.uploadProfileImage ERROR: $e');
      rethrow;
    }
  }

  // -------- FAVORITES / PROPERTY LISTS --------

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

  // -------- PROPERTY FETCH HELPERS --------

  Future<List<Property>> getSellerProperties(String userId) async {
    try {
      final user = await getUserById(userId);
      if (user == null || user.postedPropertyIds.isEmpty) return [];
      return getPropertiesByIds(user.postedPropertyIds);
    } catch (e) {
      print('UserService.getSellerProperties ERROR: $e');
      return [];
    }
  }

  Future<List<Property>> getSellerPropertiesByStage(
      String userId, String stage) async {
    try {
      final user = await getUserById(userId);
      if (user == null || user.postedPropertyIds.isEmpty) return [];
      final allProps = await getPropertiesByIds(user.postedPropertyIds);
      return allProps.where((p) => p.stage == stage).toList();
    } catch (e) {
      print('UserService.getSellerPropertiesByStage ERROR: $e');
      return [];
    }
  }

  Future<List<Property>> getInTalksProperties(String userId) async {
    try {
      final user = await getUserById(userId);
      if (user == null || user.interestedPropertyIds.isEmpty) return [];
      return getPropertiesByIds(user.interestedPropertyIds);
    } catch (e) {
      print('UserService.getInTalksProperties ERROR: $e');
      return [];
    }
  }

  Future<List<Property>> getBoughtProperties2(String userId) async {
    try {
      final user = await getUserById(userId);
      if (user == null || user.boughtPropertyIds.isEmpty) return [];
      return getPropertiesByIds(user.boughtPropertyIds);
    } catch (e) {
      print('UserService.getBoughtProperties ERROR: $e');
      return [];
    }
  }

  Future<List<Property>> getPropertiesByIds(List<String> propertyIds) async {
    try {
      if (propertyIds.isEmpty) return [];
      final List<Property> all = [];
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
    } catch (e) {
      print('UserService.getPropertiesByIds ERROR: $e');
      return [];
    }
  }

  Future<List<Property>> getInterestedProperties(String userId) async {
    final user = await getUserById(userId);
    if (user == null || user.interestedPropertyIds.isEmpty) return [];
    return getPropertiesByIds(user.interestedPropertyIds);
  }

  Future<List<Property>> getBoughtProperties(String userId) async {
    final user = await getUserById(userId);
    if (user == null || user.boughtPropertyIds.isEmpty) return [];
    return getPropertiesByIds(user.boughtPropertyIds);
  }

  Future<List<Property>> getVisitedProperties(String userId) async {
    final user = await getUserById(userId);
    if (user == null) return [];
    final combinedIds = {
      ...user.interestedPropertyIds,
      ...user.boughtPropertyIds,
    }.toList();
    if (combinedIds.isEmpty) return [];
    final props = await getPropertiesByIds(combinedIds);
    return props.where((p) {
      final buyer = p.buyers.firstWhere(
        (b) => b.phone == userId,
        orElse: () => Buyer(name: '', phone: '', status: '', currentStep: ''),
      );
      return buyer.status != 'visitPending' && buyer.status != 'bought';
    }).toList();
  }

  Future<List<Property>> getAcceptedProperties(String userId) async {
    final user = await getUserById(userId);
    if (user == null || user.interestedPropertyIds.isEmpty) return [];
    final props = await getPropertiesByIds(user.interestedPropertyIds);
    return props.where((p) {
      final buyer = p.buyers.firstWhere(
        (b) => b.phone == userId && b.status == 'accepted',
        orElse: () => Buyer(name: '', phone: '', status: '', currentStep: ''),
      );
      return buyer.status == 'accepted' && p.stage == 'saleInProgress';
    }).toList();
  }

  Future<List<Property>> getRejectedProperties(String userId) async {
    final user = await getUserById(userId);
    if (user == null || user.interestedPropertyIds.isEmpty) return [];
    final props = await getPropertiesByIds(user.interestedPropertyIds);
    return props.where((p) {
      final buyer = p.buyers.firstWhere(
        (b) => b.phone == userId && b.status == 'rejected',
        orElse: () => Buyer(name: '', phone: '', status: '', currentStep: ''),
      );
      return buyer.status == 'rejected';
    }).toList();
  }

  Future<List<Property>> getBuyerProperties(String userId) async {
    final userDoc = await _usersCollection.doc(userId).get();
    if (!userDoc.exists || userDoc.data() == null) return [];
    final user = AppUser.fromDocument(userDoc.data()!);

    final idsSet = <String>{
      ...user.interestedPropertyIds,
      ...user.boughtPropertyIds,
    };
    if (idsSet.isEmpty) return [];

    final allIds = idsSet.toList();
    List<Property> result = [];
    const batchSize = 10;
    for (var i = 0; i < allIds.length; i += batchSize) {
      final end =
          (i + batchSize < allIds.length) ? i + batchSize : allIds.length;
      final batchIds = allIds.sublist(i, end);
      final snap = await _propertiesCollection
          .where(FieldPath.documentId, whereIn: batchIds)
          .get();
      result.addAll(snap.docs.map((d) => Property.fromDocument(d)));
    }
    return result;
  }
}
