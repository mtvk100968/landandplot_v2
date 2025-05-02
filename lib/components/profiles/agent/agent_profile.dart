import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../models/property_model.dart';
import '../../../models/user_model.dart'; // Ensure correct path to your AppUser model
import 'agent_property_card.dart';
import '../../../models/buyer_model.dart';
import '../../../services/agent_service.dart';

class AgentProfile extends StatefulWidget {
  final AppUser appUser;
  final TabController tabController;
  final VoidCallback onSignOut;
  const AgentProfile({
    Key? key,
    required this.appUser,
    required this.tabController,
    required this.onSignOut,
  }) : super(key: key);

  @override
  _AgentProfileState createState() => _AgentProfileState();
}

class _AgentProfileState extends State<AgentProfile> {
  // Lists for dummy data.
  late Future<List<Property>> _findBuyerFuture;
  late Future<List<Property>> _inProgressFuture;
  late AppUser agentUser;

  @override
  void initState() {
    super.initState();
    final svc = AgentService();
    _findBuyerFuture = svc.getFindBuyerProperties(widget.appUser.uid);
    _inProgressFuture = svc.getSalesInProgressProperties(widget.appUser.uid);
    // Dummy agent user.
    agentUser = AppUser(
      uid: 'agent1',
      name: 'Agent Smith',
      email: 'agent.smith@example.com',
      phoneNumber: '1234567890',
      userType: 'agent',
      agentAreas: ['Downtown', 'Uptown', 'Suburbs'],
    );
  }

  // Build the agent details card widget.
  Widget _buildAgentDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      child: Card(
        elevation: 2,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                agentUser.name ?? 'Add your name',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                agentUser.email ?? 'Add your email',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                agentUser.phoneNumber ?? 'Add your phone number',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              if (agentUser.agentAreas.isNotEmpty)
                Wrap(
                  spacing: 6.0,
                  runSpacing: 6.0,
                  children: agentUser.agentAreas.map((area) {
                    return Chip(
                      label: Text(
                        area,
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor: Colors.blue.shade50,
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    );
                  }).toList(),
                )
              else
                Text(
                  'Tap here to add your service areas',
                  style: TextStyle(fontSize: 14, color: Colors.blue.shade700),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPropertyList(List<Property> properties) {
    return ListView.builder(
      itemCount: properties.length,
      itemBuilder: (context, index) {
        return AgentPropertyCard(
          property: properties[index],
          currentAgentId: widget.appUser.uid,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agent Profile'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: widget.onSignOut,
              child: Center(
                child: Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.blueAccent,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.blueAccent.withOpacity(0.8),
                    decorationThickness: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Agent profile details.
          _buildAgentDetails(),
          // TabBar for Posted and Assigned Properties.
          TabBar(
            controller: widget.tabController,
            tabs: const [
              Tab(text: 'Find Buyers'),
              Tab(text: 'Sales In Progress'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: widget.tabController,
              children: [
                FutureBuilder<List<Property>>(
                  future: _findBuyerFuture,
                  builder: (_, snap) {
                    if (snap.connectionState != ConnectionState.done)
                      return const Center(child: CircularProgressIndicator());
                    return _buildPropertyList(snap.data!);
                  },
                ),
                FutureBuilder<List<Property>>(
                  future: _inProgressFuture,
                  builder: (_, snap) {
                    if (snap.connectionState != ConnectionState.done)
                      return const Center(child: CircularProgressIndicator());
                    return _buildPropertyList(snap.data!);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
