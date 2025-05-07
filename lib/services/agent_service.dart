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

  /// Fetch only those in find-buyer stage
  Future<List<Property>> getFindBuyerProperties(String agentId) async {
    final all = await getAllAgentProperties(agentId);
    return all.where((p) => p.stage == 'findingBuyers').toList();
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
