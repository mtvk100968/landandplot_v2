import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/property_model.dart';

class PropertyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a property to Firestore
  Future<String> addProperty(Property property) async {
    try {
      DocumentReference docRef =
          await _firestore.collection('properties').add(property.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add property');
    }
  }

  // Fetch a property from Firestore by ID
  Future<Property?> getPropertyById(String propertyId) async {
    DocumentSnapshot<Map<String, dynamic>> doc =
        await _firestore.collection('properties').doc(propertyId).get();
    if (doc.exists) {
      return Property.fromMap(doc.id, doc.data()!);
    }
    return null;
  }

  // Update a property in Firestore
  Future<void> updateProperty(Property property) async {
    await _firestore
        .collection('properties')
        .doc(property.id)
        .update(property.toMap());
  }

  // Delete a property from Firestore
  Future<void> deleteProperty(String propertyId) async {
    await _firestore.collection('properties').doc(propertyId).delete();
  }

  // Fetch all properties from Firestore
  Future<List<Property>> getAllProperties() async {
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await _firestore.collection('properties').get();

    return snapshot.docs
        .map((doc) => Property.fromMap(doc.id, doc.data()))
        .toList();
  }
}
