// lib/components/profiles/admin/mini-components/property_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../models/property_model.dart';
import '../../../../models/buyer_model.dart';
import '../../../../models/user_model.dart';
import '../../../../services/admin_service.dart';
import './user_details_screen.dart';
import './agent_details_screen.dart';

class PropertyDetailScreen extends StatefulWidget {
  final String propertyId;
  const PropertyDetailScreen({Key? key, required this.propertyId})
      : super(key: key);

  @override
  _PropertyDetailScreenState createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  final _svc = AdminService();
  late Future<Property?> _propFut;
  Map<String, Future<AppUser?>> _agentFutures = {};

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _propFut = _svc.getPropertyById(widget.propertyId).then((p) {
      // cache one Future per agent UID
      _agentFutures = {
        for (var aid in p?.assignedAgentIds ?? []) aid: _svc.getAgentById(aid),
      };
      return p;
    });
    setState(() {});
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openAgentPicker(List<String> current) async {
    final allAgents = await _svc.getAgents();
    final avail = allAgents.where((a) => !current.contains(a.uid)).toList();
    final selected = <String>{};

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setD) {
          return AlertDialog(
            title: Text(current.isEmpty ? 'Assign Agents' : 'Add More Agents'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView(
                children: avail.map((a) {
                  final isSel = selected.contains(a.uid);
                  return CheckboxListTile(
                    title: Text(a.name ?? a.uid),
                    subtitle: Text(a.phoneNumber ?? ''),
                    value: isSel,
                    onChanged: (v) {
                      setD(() {
                        if (v == true)
                          selected.add(a.uid);
                        else
                          selected.remove(a.uid);
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx2),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final picks = selected.toList();
                  if (current.isEmpty) {
                    await _svc.assignAgentsToProperty(widget.propertyId, picks);
                  } else {
                    final merged = [...current, ...picks];
                    await _svc.updateAgentsForProperty(
                        widget.propertyId, merged);
                  }
                  Navigator.pop(ctx2);
                  _reload();
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDocs(String title, List<String> urls) {
    if (urls.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ...urls.map((u) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: GestureDetector(
                onTap: () => _openUrl(u),
                child: Text(
                  u,
                  style: const TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.blue,
                  ),
                ),
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
        future: _propFut,
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final p = snap.data;
          if (p == null) {
            return const Center(child: Text('Property not found'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Core fields
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
                      color: Theme.of(context).colorScheme.secondary,
                    ),
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

              // Winning Agent
              if (p.winningAgentId != null) ...[
                const Divider(),
                const Text('Winning Agent',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                FutureBuilder<AppUser?>(
                  future: _svc.getAgentById(p.winningAgentId!),
                  builder: (c2, s2) {
                    final ag = s2.connectionState == ConnectionState.done
                        ? s2.data
                        : null;
                    final name = ag?.name ?? p.winningAgentId!;
                    final phone = ag?.phoneNumber ?? '';
                    return ListTile(
                      title: Text(name),
                      subtitle: Text(phone),
                      onTap: () => Navigator.push(
                        c2,
                        MaterialPageRoute(
                          builder: (_) =>
                              AgentDetailScreen(agentUid: p.winningAgentId!),
                        ),
                      ),
                    );
                  },
                ),
              ],

              // Assigned Agents
              const Divider(),
              const Text('Assigned Agents',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              if (p.assignedAgentIds.isEmpty)
                ElevatedButton(
                  onPressed: () => _openAgentPicker([]),
                  child: const Text('Assign Agents'),
                )
              else ...[
                for (var aid in p.assignedAgentIds)
                  FutureBuilder<AppUser?>(
                    future: _agentFutures[aid],
                    builder: (c2, s2) {
                      if (s2.connectionState == ConnectionState.waiting) {
                        return const ListTile(title: Text('Loading…'));
                      }
                      if (s2.hasError || s2.data == null) {
                        return ListTile(
                          title: const Text('[Unknown Agent]'),
                          subtitle: Text(aid),
                        );
                      }
                      final ag = s2.data!;
                      return ListTile(
                        title: Text(ag.name!),
                        subtitle: Text(ag.phoneNumber ?? ''),
                        onTap: () => Navigator.push(
                          c2,
                          MaterialPageRoute(
                            builder: (_) => AgentDetailScreen(agentUid: aid),
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => _openAgentPicker(p.assignedAgentIds),
                  child: const Text('Add More Agents'),
                ),
              ],

              // Buyers
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
                            if (b.notes.isNotEmpty)
                              ExpansionTile(
                                title: Text('Notes (${b.notes.length})'),
                                children: b.notes
                                    .map((n) => ListTile(title: Text(n)))
                                    .toList(),
                              ),
                            _buildDocs('Interest Documents', b.interestDocs),
                            _buildDocs(
                                'Verification Documents', b.docVerifyDocs),
                            _buildDocs(
                                'Legal Check Documents', b.legalCheckDocs),
                            _buildDocs('Agreement Documents', b.agreementDocs),
                            _buildDocs(
                                'Registration Documents', b.registrationDocs),
                            _buildDocs('Mutation Documents', b.mutationDocs),
                            _buildDocs(
                                'Possession Documents', b.possessionDocs),
                          ],
                        ),
                      ),
                    )),
              ],

              // Property-level docs
              _buildDocs('Property Documents', p.documents),
            ],
          );
        },
      ),
    );
  }
}
