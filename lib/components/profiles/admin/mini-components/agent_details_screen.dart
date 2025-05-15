// lib/components/profiles/admin/mini-components/agent_details_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../models/user_model.dart';
import './property_details_screen.dart';

class AgentDetailScreen extends StatelessWidget {
  final String agentUid;
  const AgentDetailScreen({Key? key, required this.agentUid}) : super(key: key);

  Future<AppUser?> _fetchAgent() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(agentUid)
        .get();
    if (!doc.exists || doc.data() == null) return null;
    return AppUser.fromDocument(doc.data()!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agent Details')),
      body: FutureBuilder<AppUser?>(
        future: _fetchAgent(),
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done)
            return const Center(child: CircularProgressIndicator());
          final agent = snap.data;
          if (agent == null)
            return const Center(child: Text('Agent not found'));

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                  title: const Text('Name'), subtitle: Text(agent.name ?? '-')),
              ListTile(
                  title: const Text('Phone'),
                  subtitle: Text(agent.phoneNumber ?? '-')),
              ListTile(
                  title: const Text('Email'),
                  subtitle: Text(agent.email ?? '-')),
              ListTile(
                  title: const Text('User Type'),
                  subtitle: Text(agent.userType)),

              if (agent.agentAreas.isNotEmpty) ...[
                const Divider(),
                const Text('Areas',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                ...agent.agentAreas.map((area) => ListTile(title: Text(area))),
              ],

              if (agent.postedPropertyIds.isNotEmpty) ...[
                const Divider(),
                const Text('Posted Properties',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                ...agent.postedPropertyIds.map((pid) => ListTile(
                      title: Text(pid),
                      trailing: const Icon(Icons.open_in_new),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                PropertyDetailScreen(propertyId: pid),
                          ),
                        );
                      },
                    )),
              ],

              if (agent.assignedPropertyIds.isNotEmpty) ...[
                const Divider(),
                const Text('Assigned Properties',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                ...agent.assignedPropertyIds.map((pid) => ListTile(
                      title: Text(pid),
                      trailing: const Icon(Icons.open_in_new),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                PropertyDetailScreen(propertyId: pid),
                          ),
                        );
                      },
                    )),
              ],

              // --- Bought Properties
              if (agent.boughtPropertyIds.isNotEmpty) ...[
                const Divider(),
                const Text('Bought Properties',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                ...agent.boughtPropertyIds.map((pid) => ListTile(
                      title: Text(pid),
                      trailing: const Icon(Icons.open_in_new),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                PropertyDetailScreen(propertyId: pid),
                          ),
                        );
                      },
                    )),
              ],
            ],
          );
        },
      ),
    );
  }
}
