// lib/components/profiles/admin/mini-components/property_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../models/property_model.dart';
import '../../../../models/buyer_model.dart';
import './user_details_screen.dart';
import './agent_details_screen.dart';

class PropertyDetailScreen extends StatelessWidget {
  final String propertyId;
  const PropertyDetailScreen({Key? key, required this.propertyId})
      : super(key: key);

  Future<Property?> _fetchProperty() async {
    final doc = await FirebaseFirestore.instance
        .collection('properties')
        .doc(propertyId)
        .get();
    if (!doc.exists || doc.data() == null) return null;
    return Property.fromMap(doc.id, doc.data()!);
  }

  Widget _buildDocsSection(String title, List<String> urls) {
    if (urls.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ...urls.map((u) => GestureDetector(
              onTap: () {/* TODO: open URL */},
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(u,
                    style:
                        const TextStyle(decoration: TextDecoration.underline)),
              ),
            )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Property Details')),
      body: FutureBuilder<Property?>(
        future: _fetchProperty(),
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done)
            return const Center(child: CircularProgressIndicator());
          final p = snap.data;
          if (p == null) return const Center(child: Text('Property not found'));

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(title: const Text('ID'), subtitle: Text(p.id)),
              ListTile(
                title: const Text('Owner'),
                subtitle: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UserDetailScreen(userId: p.userId),
                    ),
                  ),
                  child: Text(
                    p.propertyOwner,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                ),
              ),
              ListTile(
                  title: const Text('Owner Phone'),
                  subtitle: Text(p.mobileNumber)),
              ListTile(
                  title: const Text('Type'), subtitle: Text(p.propertyType)),
              ListTile(
                  title: const Text('Land Area'),
                  subtitle: Text('${p.landArea}')),
              ListTile(
                  title: const Text('Price per Unit'),
                  subtitle: Text('₹${p.pricePerUnit}')),
              ListTile(
                  title: const Text('Total Price'),
                  subtitle: Text('₹${p.totalPrice}')),
              ListTile(
                  title: const Text('Survey Number'),
                  subtitle: Text(p.surveyNumber)),
              ListTile(
                  title: const Text('Plot Numbers'),
                  subtitle: Text(p.plotNumbers.join(', '))),
              ListTile(
                  title: const Text('Address'),
                  subtitle: Text(p.address ?? '-')),
              ListTile(
                  title: const Text('District'),
                  subtitle: Text(p.district ?? '-')),
              ListTile(
                  title: const Text('Mandal'), subtitle: Text(p.mandal ?? '-')),
              ListTile(
                  title: const Text('Village'),
                  subtitle: Text(p.village ?? '-')),
              ListTile(
                  title: const Text('City'), subtitle: Text(p.city ?? '-')),
              ListTile(title: const Text('Pincode'), subtitle: Text(p.pincode)),
              ListTile(title: const Text('Stage'), subtitle: Text(p.stage)),

              if (p.winningAgentId != null) ...[
                const Divider(),
                ListTile(
                  title: const Text('Winning Agent'),
                  subtitle: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AgentDetailScreen(agentUid: p.winningAgentId!),
                      ),
                    ),
                    child: Text(
                      p.winningAgentId!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                  ),
                ),
              ],

              if (p.assignedAgentIds.isNotEmpty) ...[
                const Divider(),
                const Text('Assigned Agents',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                ...p.assignedAgentIds.map((aid) => GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AgentDetailScreen(agentUid: aid),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(aid,
                            style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.secondary)),
                      ),
                    )),
              ],

              // --- Buyers
              if (p.buyers.isNotEmpty) ...[
                const Divider(),
                const Text('Buyers',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                ...p.buyers.map((Buyer b) => Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${b.name} (${b.phone})',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            Text('Step: ${b.currentStep}'),
                            if (b.lastUpdated != null)
                              Text('Last updated: ${b.lastUpdated!.toLocal()}'),

                            // Notes with toggle
                            if (b.notes.isNotEmpty)
                              ExpansionTile(
                                title: Text('Notes (${b.notes.length})'),
                                children: b.notes
                                    .map((n) => ListTile(title: Text(n)))
                                    .toList(),
                              ),

                            // Documents by step
                            _buildDocsSection(
                                'Interest Documents', b.interestDocs),
                            _buildDocsSection(
                                'Verification Documents', b.docVerifyDocs),
                            _buildDocsSection(
                                'Legal Check Documents', b.legalCheckDocs),
                            _buildDocsSection(
                                'Agreement Documents', b.agreementDocs),
                            _buildDocsSection(
                                'Registration Documents', b.registrationDocs),
                            _buildDocsSection(
                                'Mutation Documents', b.mutationDocs),
                            _buildDocsSection(
                                'Possession Documents', b.possessionDocs),
                          ],
                        ),
                      ),
                    )),
              ],

              // Property-level docs
              _buildDocsSection('Property Documents', p.documents),
            ],
          );
        },
      ),
    );
  }
}
