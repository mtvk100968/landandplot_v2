import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/property_model.dart';
import 'user_service.dart';

class AgentService {
  final CollectionReference<Map<String, dynamic>> _propertiesCollection =
      FirebaseFirestore.instance.collection('properties');

  /// Fetch properties that the agent has posted (where the property userId equals the agent's id)
  Future<List<Property>> getPostedProperties(String agentId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await _propertiesCollection.where('userId', isEqualTo: agentId).get();
      List<Property> properties =
          snapshot.docs.map((doc) => Property.fromDocument(doc)).toList();
      return properties;
    } catch (e) {
      print("Error fetching posted properties: $e");
      return [];
    }
  }

  /// Fetch properties assigned to the agent using the agent's assignedPropertyIds
  Future<List<Property>> getAssignedProperties(String agentId) async {
    try {
      // Get the agent's document to access assignedPropertyIds
      final userService = UserService();
      final agentUser = await userService.getUserById(agentId);
      if (agentUser == null) return [];
      List<String> assignedIds = agentUser.assignedPropertyIds;
      // Use the helper in UserService to fetch properties by their IDs
      List<Property> properties =
          await userService.getPropertiesByIds(assignedIds);
      return properties;
    } catch (e) {
      print("Error fetching assigned properties: $e");
      return [];
    }
  }
}
