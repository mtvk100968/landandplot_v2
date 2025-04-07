import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/property_model.dart';
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

  @override
  void initState() {
    super.initState();
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
  }

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
          IconButton(
            onPressed: widget.onSignOut,
            icon: const Icon(Icons.logout),
          )
        ],
        bottom: TabBar(
          controller: widget.tabController,
          tabs: const [
            Tab(text: 'Posted Properties'),
            Tab(text: 'Assigned Properties'),
          ],
        ),
      ),
      body: TabBarView(
        controller: widget.tabController,
        children: [
          _buildPropertyList(postedProperties),
          _buildPropertyList(assignedProperties),
        ],
      ),
    );
  }
}
