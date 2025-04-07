import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/property_model.dart';
import '../../../models/user_model.dart'; // Ensure correct path to your AppUser model
import '../admin/agent_property_card.dart';
import '../../../models/buyer_model.dart'; // Import your Buyer model

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

    // Dummy posted property with all fields filled.
    postedProperties = [
      Property(
        id: '1',
        userId: 'agent1',
        name: 'Sunny Apartments',
        mobileNumber: '1234567890',
        propertyType: 'Residential',
        landArea: 1500,
        pricePerUnit: 45,
        totalPrice: 67500,
        surveyNumber: 'SN-101',
        plotNumbers: ['P1', 'P2'],
        district: 'Central',
        mandal: 'Mandal A',
        village: 'Sunny Village',
        city: 'Metropolis',
        pincode: '123456',
        latitude: 12.9716,
        longitude: 77.5946,
        state: 'State X',
        roadAccess: 'Main Road',
        roadType: 'Paved',
        roadWidth: 20.0,
        landFacing: 'North',
        propertyOwner: 'Owner One',
        images: ['image1.jpg', 'image2.jpg'],
        videos: ['video1.mp4'],
        documents: ['doc1.pdf'],
        address: '123 Sunny Street, Metropolis',
        userType: 'agent',
        ventureName: 'Sunny Ventures',
        createdAt: Timestamp.now(),
        status: true,
        fencing: true,
        gate: true,
        bore: false,
        pipeline: true,
        electricity: true,
        plantation: false,
        proposedPrices: [],
        interestedUsers: [
          Buyer(
            name: 'John Doe',
            phone: '9876543210',
            date: DateTime.now().subtract(const Duration(days: 1)),
            priceOffered: 65000,
            status: 'pending',
            notes: ['First visit'],
          ),
        ],
        visitedUsers: [],
      ),
    ];

    // Dummy assigned property with a sale initiated and both buyers lists filled.
    assignedProperties = [
      Property(
        id: '2',
        userId: 'agent1',
        name: 'Grand Commercial Plaza',
        mobileNumber: '1234567890',
        propertyType: 'Commercial',
        landArea: 3000,
        pricePerUnit: 75,
        totalPrice: 225000,
        surveyNumber: 'SN-202',
        plotNumbers: ['P3'],
        district: 'West District',
        mandal: 'Mandal B',
        village: 'Plaza Village',
        city: 'Metro City',
        pincode: '654321',
        latitude: 13.0827,
        longitude: 80.2707,
        state: 'State Y',
        roadAccess: 'Side Road',
        roadType: 'Asphalt',
        roadWidth: 15.0,
        landFacing: 'East',
        propertyOwner: 'Owner Two',
        images: ['commercial1.jpg'],
        videos: ['commercial_video.mp4'],
        documents: ['commercial_doc.pdf'],
        address: '456 Grand Ave, Metro City',
        userType: 'agent',
        ventureName: 'Grand Ventures',
        createdAt: Timestamp.now(),
        status: true,
        fencing: true,
        gate: false,
        bore: true,
        pipeline: true,
        electricity: true,
        plantation: false,
        proposedPrices: [
          {'saleStatus': 'initiated'},
        ],
        interestedUsers: [
          Buyer(
            name: 'Alice Smith',
            phone: '5551234567',
            date: DateTime.now().subtract(const Duration(days: 2)),
            priceOffered: 220000,
            status: 'pending',
            notes: [],
          ),
        ],
        visitedUsers: [
          Buyer(
            name: 'Bob Johnson',
            phone: '5559876543',
            date: DateTime.now().subtract(const Duration(days: 1)),
            priceOffered: 225000,
            status: 'accepted',
            notes: ['Negotiated discount', 'Final offer accepted'],
          ),
        ],
      ),
    ];

    // Dummy agent user (replace with Firestore fetch in production)
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
