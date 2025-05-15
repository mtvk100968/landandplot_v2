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
              onTap: () {
                // TODO: open URL or preview
              },
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
          final property = snap.data;
          if (property == null)
            return const Center(child: Text('Property not found'));

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(title: const Text('ID'), subtitle: Text(property.id)),
              ListTile(
                title: const Text('Owner'),
                subtitle: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UserDetailScreen(userId: property.userId),
                    ),
                  ),
                  child: Text(
                    property.propertyOwner,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                ),
              ),
              ListTile(
                  title: const Text('Type'),
                  subtitle: Text(property.propertyType)),
              ListTile(
                  title: const Text('Address'),
                  subtitle: Text(property.address ?? '-')),
              ListTile(
                  title: const Text('Stage'), subtitle: Text(property.stage)),
              if (property.assignedAgentIds.isNotEmpty) ...[
                const Divider(),
                const Text('Assigned Agents',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                ...property.assignedAgentIds.map((aid) => GestureDetector(
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
              if (property.buyers.isNotEmpty) ...[
                const Divider(),
                const Text('Buyers',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                ...property.buyers.map((Buyer b) => Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${b.name} (${b.phone})',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            Text('Status: ${b.status}'),
                            if (b.date != null) Text('Visit: ${b.date}'),
                            if (b.priceOffered != null)
                              Text('Offered: ₹${b.priceOffered}'),
                            if (b.notes.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              const Text('Notes:'),
                              ...b.notes.map((n) => Text('- $n')),
                            ],
                            _buildDocsSection('Interest Docs', b.interestDocs),
                            _buildDocsSection(
                                'Verification Docs', b.docVerifyDocs),
                            _buildDocsSection(
                                'Legal Check Docs', b.legalCheckDocs),
                            _buildDocsSection(
                                'Agreement Docs', b.agreementDocs),
                            _buildDocsSection(
                                'Registration Docs', b.registrationDocs),
                            _buildDocsSection('Mutation Docs', b.mutationDocs),
                            _buildDocsSection(
                                'Possession Docs', b.possessionDocs),
                          ],
                        ),
                      ),
                    )),
              ],
              _buildDocsSection('Property Documents', property.documents),
            ],
          );
        },
      ),
    );
  }
}
