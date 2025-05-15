// lib/services/admin_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/property_model.dart';

class AdminService {
  final _users = FirebaseFirestore.instance.collection('users');
  final _props = FirebaseFirestore.instance.collection('properties');

  /// Fetch all agents
  Future<List<AppUser>> getAgents() async {
    try {
      final snap = await _users.where('userType', isEqualTo: 'agent').get();
      return snap.docs.map((d) => AppUser.fromDocument(d.data())).toList();
    } catch (e) {
      print('Error fetching agents: $e');
      return [];
    }
  }

  /// Fetch a single agent by their UID
  Future<AppUser?> getAgentById(String uid) async {
    try {
      final doc = await _users.doc(uid).get();
      if (!doc.exists || doc.data() == null) return null;
      return AppUser.fromDocument(doc.data()!);
    } catch (e) {
      print('Error fetching agent $uid: $e');
      return null;
    }
  }

  /// Fetch all regular users
  Future<List<AppUser>> getRegularUsers() async {
    try {
      final snap = await _users.where('userType', isEqualTo: 'user').get();
      return snap.docs.map((d) => AppUser.fromDocument(d.data())).toList();
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

  /// Fetch all properties
  Future<List<Property>> getProperties() async {
    try {
      final snap = await _props.get();
      return snap.docs.map((d) => Property.fromDocument(d)).toList();
    } catch (e) {
      print('Error fetching properties: $e');
      return [];
    }
  }

  /// Fetch a single property by ID
  Future<Property?> getPropertyById(String propertyId) async {
    try {
      final doc = await _props.doc(propertyId).get();
      if (!doc.exists || doc.data() == null) return null;
      return Property.fromDocument(doc);
    } catch (e) {
      print('Error fetching property $propertyId: $e');
      return null;
    }
  }

  /// Assign a list of agents to one property (initial assignment)
  Future<void> assignAgentsToProperty(
      String propertyId, List<String> agentIds) async {
    final batch = FirebaseFirestore.instance.batch();
    final propRef = _props.doc(propertyId);

    // 1) Update the property's assignedAgentIds
    batch.update(propRef, {'assignedAgentIds': agentIds});

    // 2) For each agent, add this property to their assignedPropertyIds
    for (var aid in agentIds) {
      final userRef = _users.doc(aid);
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

  /// Update assignment: add & remove agents in one transaction
  Future<void> updateAgentsForProperty(
      String propertyId, List<String> newAgentIds) async {
    final propRef = _props.doc(propertyId);
    final snap = await propRef.get();
    if (!snap.exists) return;

    final oldIds = List<String>.from(snap.get('assignedAgentIds') ?? []);
    final toAdd = newAgentIds.where((id) => !oldIds.contains(id)).toList();
    final toRemove = oldIds.where((id) => !newAgentIds.contains(id)).toList();

    final batch = FirebaseFirestore.instance.batch();

    // 1) Update property's assignedAgentIds
    batch.update(propRef, {'assignedAgentIds': newAgentIds});

    // 2) Add propertyId to newly added agents
    for (var aid in toAdd) {
      final uref = _users.doc(aid);
      batch.set(
        uref,
        {
          'assignedPropertyIds': FieldValue.arrayUnion([propertyId])
        },
        SetOptions(merge: true),
      );
    }

    // 3) Remove propertyId from unassigned agents
    for (var rid in toRemove) {
      final uref = _users.doc(rid);
      batch.update(
        uref,
        {
          'assignedPropertyIds': FieldValue.arrayRemove([propertyId])
        },
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
      final matchQuery = q.isEmpty || p.matches(q);
      final matchAssign = assignedOnly ? p.isAssigned : p.isUnassigned;
      return matchQuery && matchAssign;
    }).toList();
  }

  /// Search agents by query in "Name", "Phone", or "Areas"
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
    return all.where((u) => u.matches(q, field: field)).toList();
  }
}
