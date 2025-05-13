import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/property_model.dart';
import '../models/user_model.dart';
import 'user_service.dart';
import 'property_service.dart';

class AgentService {
  final CollectionReference<Map<String, dynamic>> _propertiesCollection =
      FirebaseFirestore.instance.collection('properties');
  final CollectionReference<Map<String, dynamic>> _usersCollection =
      FirebaseFirestore.instance.collection('users');
  final _ps = PropertyService();
  final _us = UserService();

  /// Fetch properties that the agent has posted (where the property userId equals the agent's id)
  Future<List<Property>> getPostedProperties(String agentId) async {
    try {
      // leverage PropertyService to fetch by userId filter
      return await _ps.getPropertiesByField('userId', agentId);
    } catch (e) {
      print("Error fetching posted properties: $e");
      return [];
    }
  }

  /// Fetch properties assigned to the agent using the agent's assignedPropertyIds
  Future<List<Property>> getAssignedProperties(String agentId) async {
    try {
      final agentUser = await _us.getUserById(agentId);
      if (agentUser == null || agentUser.assignedPropertyIds.isEmpty) {
        return [];
      }
      return await _ps.getPropertiesByIds(agentUser.assignedPropertyIds);
    } catch (e) {
      print("Error fetching assigned properties: $e");
      return [];
    }
  }

  /// Combined: all properties this agent must manage, ordered FCFS
  Future<List<Property>> getAllAgentProperties(String agentId) async {
    final posted = await getPostedProperties(agentId);
    final assigned = await getAssignedProperties(agentId);
    // merge and sort by createdAt timestamp
    final all = [...posted, ...assigned];
    all.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return all;
  }

  /// Fetch all properties in 'findingBuyers' or 'saleInProgress' that
  /// this agent either posted or was assigned (via user.assignedPropertyIds).
  /// Fetch all properties in 'findingBuyers' or 'saleInProgress'
  /// that this agent either posted or was assigned.
  Future<List<Property>> getFindBuyerProperties(String agentId) async {
    // Step 1: load agent record to get assignedPropertyIds
    final agentUser = await _us.getUserById(agentId);
    print('getFindBuyerProperties ▶ agentId = $agentId');
    print('  Assigned IDs on user: ${agentUser?.assignedPropertyIds}');

    final assignedIds = agentUser?.assignedPropertyIds ?? [];

    // Step 2: fetch posted properties
    final posted = await _ps.getPropertiesByField('userId', agentId);
    print('  Fetched ${posted.length} posted properties: '
        '${posted.map((p) => p.id).toList()}');

    // Step 3: filter posted by stage
    final postedFiltered = posted
        .where((p) => p.stage == 'findingBuyers' || p.stage == 'saleInProgress')
        .toList();
    print('  PostedFiltered (${postedFiltered.length}): '
        '${postedFiltered.map((p) => '${p.id}:${p.stage}').toList()}');

    // Step 4: fetch assigned properties by ID
    final assigned = await _ps.getPropertiesByIds(assignedIds);
    print('  Fetched ${assigned.length} assigned properties: '
        '${assigned.map((p) => p.id).toList()}');

    // Step 5: filter assigned by stage
    final assignedFiltered = assigned
        .where((p) => p.stage == 'findingBuyers' || p.stage == 'saleInProgress')
        .toList();
    print('  AssignedFiltered (${assignedFiltered.length}): '
        '${assignedFiltered.map((p) => '${p.id}:${p.stage}').toList()}');

    // Step 6: merge & dedupe
    final map = <String, Property>{};
    for (var p in postedFiltered) {
      map[p.id] = p;
    }
    for (var p in assignedFiltered) {
      map[p.id] = p;
    }

    // Step 7: sort by creation time
    final all = map.values.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    print('  Merged all (${all.length}): ${all.map((p) => p.id).toList()}');

    return all;
  }

  /// Fetch only those in sale-in-progress stage
  Future<List<Property>> getSalesInProgressProperties(String agentId) async {
    final all = await getAllAgentProperties(agentId);
    return all.where((p) => p.stage == 'saleInProgress').toList();
  }

  /// Fetch an AppUser by UID
  Future<AppUser?> getUserById(String uid) async {
    final snap = await _usersCollection.doc(uid).get();
    if (!snap.exists) return null;
    return AppUser.fromDocument(snap.data()!);
  }

  /// Update (or set) an AppUser back to Firestore
  Future<void> updateUser(AppUser user) {
    return _usersCollection.doc(user.uid).update(user.toMap());
  }
}
