import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/property_model.dart';

class AdminService {
  final CollectionReference<Map<String, dynamic>> _usersCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference<Map<String, dynamic>> _propertiesCollection =
      FirebaseFirestore.instance.collection('properties');

  /// Fetch all agents
  Future<List<AppUser>> getAgents() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await _usersCollection.where('userType', isEqualTo: 'agent').get();
      return snapshot.docs
          .map((doc) => AppUser.fromDocument(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching agents: $e');
      return [];
    }
  }

  /// Fetch all regular users
  Future<List<AppUser>> getRegularUsers() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await _usersCollection.where('userType', isEqualTo: 'user').get();
      return snapshot.docs
          .map((doc) => AppUser.fromDocument(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

  /// Fetch all properties
  Future<List<Property>> getProperties() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await _propertiesCollection.get();
      return snapshot.docs.map((doc) => Property.fromDocument(doc)).toList();
    } catch (e) {
      print('Error fetching properties: $e');
      return [];
    }
  }
}
