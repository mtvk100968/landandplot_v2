import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../models/property_model.dart';
import '../../../models/user_model.dart'; // Ensure correct path to your AppUser model
import '../admin/agent_property_card.dart';
import '../../../models/buyer_model.dart';

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
  // Lists for dummy data.
  List<Property> postedProperties = [];
  List<Property> assignedProperties = [];
  late AppUser agentUser;

  @override
  void initState() {
    super.initState();

    // Dummy Posted Properties

    // Posted Property 1: "Residential One" with multiple scenarios.
    postedProperties = [
      Property(
        id: 'res1',
        userId: 'agent1',
        name: 'Residential One',
        mobileNumber: '1234567890',
        propertyType: 'Residential',
        landArea: 1500,
        pricePerUnit: 50,
        totalPrice: 75000,
        surveyNumber: 'RES-101',
        plotNumbers: ['R1', 'R2'],
        district: 'Central',
        mandal: 'Mandal A',
        village: 'Green Village',
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
        images: ['res1_image1.jpg', 'res1_image2.jpg'],
        videos: ['res1_video.mp4'],
        documents: ['res1_doc.pdf'],
        address: '123 Green Street, Metropolis',
        userType: 'agent',
        ventureName: 'Residential Ventures',
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
          // Case: Buyer with no date (should show "Set Date")
          Buyer(
            name: 'No Date Buyer',
            phone: '1111111111',
            date: null,
            priceOffered: null,
            status: 'pending',
            notes: [],
          ),
          // Case: Buyer with a future date (2 days ahead)
          Buyer(
            name: 'Future Buyer',
            phone: '2222222222',
            date: DateTime.now().add(const Duration(days: 2)),
            priceOffered: null,
            status: 'pending',
            notes: [],
          ),
          // Case: Buyer with today’s date (should show "Today!")
          Buyer(
            name: 'Today Buyer',
            phone: '3333333333',
            date: DateTime.now(),
            priceOffered: null,
            status: 'pending',
            notes: [],
          ),
          // Case: Buyer with a past date (3 days ago, paperwork incomplete -> "Late!")
          Buyer(
            name: 'Past Buyer',
            phone: '4444444444',
            date: DateTime.now().subtract(const Duration(days: 3)),
            priceOffered: null,
            status: 'pending',
            notes: [],
          ),
        ],
        visitedUsers: [
          // Case: Visited Buyer with completed paperwork
          Buyer(
            name: 'Visited Buyer',
            phone: '5555555555',
            date: DateTime.now().subtract(const Duration(days: 1)),
            priceOffered: 500000,
            status: 'accepted',
            notes: ['All paperwork complete'],
            lastUpdated: DateTime.now(),
          ),
        ],
      ),
      // Posted Property 2: "Residential Two" with one interested buyer.
      Property(
        id: 'res2',
        userId: 'agent1',
        name: 'Residential Two',
        mobileNumber: '1234567890',
        propertyType: 'Residential',
        landArea: 2000,
        pricePerUnit: 60,
        totalPrice: 120000,
        surveyNumber: 'RES-202',
        plotNumbers: ['R3'],
        district: 'East District',
        mandal: 'Mandal B',
        village: 'Blue Village',
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
        images: ['res2_image1.jpg'],
        videos: [],
        documents: ['res2_doc.pdf'],
        address: '456 Blue Street, Metro City',
        userType: 'agent',
        ventureName: 'Residential Ventures',
        createdAt: Timestamp.now(),
        status: true,
        fencing: false,
        gate: true,
        bore: true,
        pipeline: false,
        electricity: true,
        plantation: true,
        proposedPrices: [],
        interestedUsers: [
          Buyer(
            name: 'Only Buyer',
            phone: '6666666666',
            date: null,
            priceOffered: null,
            status: 'pending',
            notes: [],
          ),
        ],
        visitedUsers: [],
      ),
    ];

    // Dummy Assigned Properties

    // Assigned Property 1: "Commercial One" with proposedPrices (sale initiated).
    assignedProperties = [
      Property(
        id: 'com1',
        userId: 'agent1',
        name: 'Commercial One',
        mobileNumber: '1234567890',
        propertyType: 'Commercial',
        landArea: 3000,
        pricePerUnit: 75,
        totalPrice: 225000,
        surveyNumber: 'COM-101',
        plotNumbers: ['C1'],
        district: 'West District',
        mandal: 'Mandal C',
        village: 'Red Village',
        city: 'Metro City',
        pincode: '111222',
        latitude: 12.9716,
        longitude: 77.5946,
        state: 'State Z',
        roadAccess: 'Main Road',
        roadType: 'Concrete',
        roadWidth: 25.0,
        landFacing: 'South',
        propertyOwner: 'Owner Three',
        images: ['com1_image1.jpg'],
        videos: ['com1_video.mp4'],
        documents: ['com1_doc.pdf'],
        address: '789 Red Street, Metro City',
        userType: 'agent',
        ventureName: 'Commercial Ventures',
        createdAt: Timestamp.now(),
        status: true,
        fencing: true,
        gate: false,
        bore: false,
        pipeline: true,
        electricity: true,
        plantation: false,
        proposedPrices: [
          {'saleStatus': 'initiated'},
        ],
        interestedUsers: [
          Buyer(
            name: 'Assigned Interested Buyer',
            phone: '7777777777',
            date: DateTime.now().subtract(const Duration(days: 2)),
            priceOffered: 750000,
            status: 'pending',
            notes: [],
          ),
        ],
        visitedUsers: [
          Buyer(
            name: 'Assigned Visited Buyer',
            phone: '8888888888',
            date: DateTime.now().subtract(const Duration(days: 1)),
            priceOffered: 760000,
            status: 'accepted',
            notes: ['Agreement signed'],
            lastUpdated: DateTime.now(),
          ),
        ],
      ),
      // Assigned Property 2: "Commercial Two" with multiple buyers.
      Property(
        id: 'com2',
        userId: 'agent1',
        name: 'Commercial Two',
        mobileNumber: '1234567890',
        propertyType: 'Commercial',
        landArea: 3500,
        pricePerUnit: 80,
        totalPrice: 280000,
        surveyNumber: 'COM-202',
        plotNumbers: ['C2', 'C3'],
        district: 'North District',
        mandal: 'Mandal D',
        village: 'Yellow Village',
        city: 'Capital City',
        pincode: '333444',
        latitude: 13.0827,
        longitude: 80.2707,
        state: 'State W',
        roadAccess: 'Frontage Road',
        roadType: 'Gravel',
        roadWidth: 18.0,
        landFacing: 'West',
        propertyOwner: 'Owner Four',
        images: ['com2_image1.jpg', 'com2_image2.jpg'],
        videos: [],
        documents: ['com2_doc.pdf'],
        address: '101 Yellow Street, Capital City',
        userType: 'agent',
        ventureName: 'Commercial Ventures',
        createdAt: Timestamp.now(),
        status: true,
        fencing: false,
        gate: false,
        bore: true,
        pipeline: false,
        electricity: true,
        plantation: false,
        proposedPrices: [
          {'saleStatus': 'initiated'},
        ],
        interestedUsers: [
          Buyer(
            name: 'Assigned Future Buyer',
            phone: '9999999999',
            date: DateTime.now().add(const Duration(days: 1)),
            priceOffered: null,
            status: 'pending',
            notes: [],
          ),
          Buyer(
            name: 'Assigned No Date Buyer',
            phone: '1010101010',
            date: null,
            priceOffered: null,
            status: 'pending',
            notes: [],
          ),
        ],
        visitedUsers: [
          Buyer(
            name: 'Assigned Visited Buyer 2',
            phone: '1212121212',
            date: DateTime.now().subtract(const Duration(days: 1)),
            priceOffered: 800000,
            status: 'accepted',
            notes: ['Verified details'],
            lastUpdated: DateTime.now(),
          ),
        ],
      ),
    ];

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
          // Agent profile details.
          _buildAgentDetails(),
          // TabBar for Posted and Assigned Properties.
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
