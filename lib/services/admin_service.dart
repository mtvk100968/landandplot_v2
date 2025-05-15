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

  /// Assign a list of agents to one property, and update each user’s assignedPropertyIds
  Future<void> assignAgentsToProperty(
    String propertyId,
    List<String> agentIds,
  ) async {
    final batch = FirebaseFirestore.instance.batch();
    final propRef = _propertiesCollection.doc(propertyId);

    // 1) Update the property’s assignedAgentIds
    batch.update(propRef, {'assignedAgentIds': agentIds});

    // 2) For each agent, add this propertyId to their assignedPropertyIds
    for (var aid in agentIds) {
      final userRef = _usersCollection.doc(aid);
      batch.set(
        userRef,
        {
          'assignedPropertyIds': FieldValue.arrayUnion([propertyId])
        },
        SetOptions(merge: true),
      );
    }

    await batch.commit();
  }

  /// Search properties by name + assignment state
  Future<List<Property>> searchProperties({
    String query = '',
    bool assignedOnly = true,
  }) async {
    final all = await getProperties();
    final q = query.toLowerCase();
    return all.where((p) {
      final matchesQuery = q.isEmpty || p.matches(q);
      final matchesAssign = assignedOnly ? p.isAssigned : p.isUnassigned;
      return matchesQuery && matchesAssign;
    }).toList();
  }

  /// Search agents by query in a given field: "Name", "Phone" or "Areas"
  Future<List<AppUser>> searchAgents({
    String query = '',
    String field = 'Name',
  }) async {
    final all = await getAgents();
    final q = query.trim();
    if (q.isEmpty) return all;
    return all.where((a) => a.matches(q, field: field)).toList();
  }

  /// Search regular users by query in "Name" or "Phone"
  Future<List<AppUser>> searchUsers({
    String query = '',
    String field = 'Name',
  }) async {
    final all = await getRegularUsers();
    final q = query.trim();
    if (q.isEmpty) return all;
    // ignore 'Areas' here
    return all.where((u) => u.matches(q, field: field)).toList();
  }
}
