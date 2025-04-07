import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/property_model.dart';
import '../../../models/user_model.dart'; // Ensure correct path to your AppUser model
import '../admin/agent_property_card.dart';

class AgentProfile extends StatefulWidget {
  final TabController tabController;
  final VoidCallback onSignOut;
  const AgentProfile({
    Key? key,
    required this.tabController,
    required this.onSignOut,
  }) : super(key: key);

  @override
  _AgentProfileState createState() => _AgentProfileState();
}

class _AgentProfileState extends State<AgentProfile> {
  // Dummy data for demonstration.
  // In a real-world scenario, fetch these properties from Firestore.
  List<Property> postedProperties = [];
  List<Property> assignedProperties = [];
  late AppUser agentUser;

  @override
  void initState() {
    super.initState();
    // TODO: Replace these dummy lists with Firestore fetching code.
    // Example: FirebaseFirestore.instance.collection('properties').where(...).get()
    postedProperties = [
      Property(
        id: '1',
        userId: 'agent1',
        name: 'Property 1',
        mobileNumber: '1234567890',
        propertyType: 'Residential',
        landArea: 1000,
        pricePerUnit: 50,
        totalPrice: 50000,
        surveyNumber: 'SN1',
        plotNumbers: ['P1'],
        pincode: '123456',
        latitude: 0.0,
        longitude: 0.0,
        propertyOwner: 'Owner 1',
        images: [],
        videos: [],
        documents: [],
        userType: 'agent',
        createdAt: Timestamp.now(),
        proposedPrices: [], // No sale initiated
      ),
    ];

    assignedProperties = [
      Property(
        id: '2',
        userId: 'agent1',
        name: 'Property 2',
        mobileNumber: '1234567890',
        propertyType: 'Commercial',
        landArea: 2000,
        pricePerUnit: 75,
        totalPrice: 150000,
        surveyNumber: 'SN2',
        plotNumbers: ['P2'],
        pincode: '654321',
        latitude: 0.0,
        longitude: 0.0,
        propertyOwner: 'Owner 2',
        images: [],
        videos: [],
        documents: [],
        userType: 'agent',
        createdAt: Timestamp.now(),
        proposedPrices: [
          {'saleStatus': 'initiated'},
        ], // Sale initiated – will show timeline
      ),
    ];

    // TODO: Replace this dummy user with a Firestore fetch.
    // Example: FirebaseFirestore.instance.collection('users').doc('agent1').get()
    agentUser = AppUser(
      uid: 'agent1',
      name: 'Agent Smith',
      email: 'agent.smith@example.com',
      phoneNumber: '1234567890',
      userType: 'agent',
      agentAreas: [
        'Downtown',
        'Uptown',
        'Suburbs',
      ], // new field
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
          width: double.infinity, // 👈 ensures full width
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

  // Build list of properties using a ListView.
  Widget _buildPropertyList(List<Property> properties) {
    return ListView.builder(
      itemCount: properties.length,
      itemBuilder: (context, index) {
        return AgentPropertyCard(property: properties[index]);
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
                    color: Colors
                        .blueAccent, // ✅ Visible and clean on white AppBar
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
          // Agent profile card placed above the tabs.
          _buildAgentDetails(),
          // TabBar section now moved to the body (below the agent details).
          TabBar(
            controller: widget.tabController,
            tabs: const [
              Tab(text: 'Posted Properties'),
              Tab(text: 'Assigned Properties'),
            ],
          ),
          // Expanded TabBarView for property lists.
          Expanded(
            child: TabBarView(
              controller: widget.tabController,
              children: [
                _buildPropertyList(postedProperties),
                _buildPropertyList(assignedProperties),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
