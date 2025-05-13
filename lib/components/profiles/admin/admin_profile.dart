// lib/components/profiles/admin/admin_profile.dart

import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../../../models/property_model.dart';
import '../../../services/admin_service.dart';

class AdminProfile extends StatefulWidget {
  final AppUser appUser;
  final TabController tabController;
  final VoidCallback onSignOut;

  const AdminProfile({
    Key? key,
    required this.appUser,
    required this.tabController,
    required this.onSignOut,
  }) : super(key: key);

  @override
  _AdminProfileState createState() => _AdminProfileState();
}

class _AdminProfileState extends State<AdminProfile> {
  Future<List<dynamic>> _fetchAdminData() async {
    final agents = await AdminService().getAgents();
    final users = await AdminService().getRegularUsers();
    final properties = await AdminService().getProperties();
    return [agents, users, properties];
  }

  void _openAssignDialog(BuildContext ctx, Property prop) async {
    final allAgents = await AdminService().getAgents();
    final selected = Set<String>.from(prop.assignedAgentIds);

    await showDialog(
      context: ctx,
      builder: (dCtx) {
        return StatefulBuilder(
          builder: (ctx2, setStateDialog) {
            return AlertDialog(
              title: Text('Assign agents to ${prop.name}'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView(
                  children: allAgents.map((a) {
                    final isSel = selected.contains(a.uid);
                    return CheckboxListTile(
                      title: Text(a.name ?? a.uid),
                      value: isSel,
                      onChanged: (on) {
                        setStateDialog(() {
                          if (on == true)
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
                  onPressed: () => Navigator.pop(dCtx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await AdminService()
                        .assignAgentsToProperty(prop.id, selected.toList());
                    Navigator.pop(dCtx);
                    setState(() {}); // refresh tabs
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
              onPressed: widget.onSignOut, icon: const Icon(Icons.logout))
        ],
        bottom: TabBar(
          controller: widget.tabController,
          tabs: const [
            Tab(text: 'Agents'),
            Tab(text: 'Users'),
            Tab(text: 'Properties'),
          ],
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _fetchAdminData(),
        builder: (ctx, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final agents = snapshot.data![0] as List<AppUser>;
          final users = snapshot.data![1] as List<AppUser>;
          final properties = snapshot.data![2] as List<Property>;

          return TabBarView(
            controller: widget.tabController,
            children: [
              // Agents Tab
              ListView.builder(
                itemCount: agents.length,
                itemBuilder: (_, i) {
                  final a = agents[i];
                  return ListTile(
                    title: Text(a.name ?? 'Agent'),
                    subtitle: Text(a.phoneNumber ?? ''),
                  );
                },
              ),

              // Users Tab
              ListView.builder(
                itemCount: users.length,
                itemBuilder: (_, i) {
                  final u = users[i];
                  return ListTile(
                    title: Text(u.name ?? 'User'),
                    subtitle: Text(u.phoneNumber ?? ''),
                  );
                },
              ),

              // Properties Tab
              ListView.builder(
                itemCount: properties.length,
                itemBuilder: (_, i) {
                  final p = properties[i];
                  return ListTile(
                    title: Text(p.name.isNotEmpty ? p.name : 'Property'),
                    subtitle: Text(p.address ?? ''),
                    trailing: TextButton(
                      onPressed: () => _openAssignDialog(context, p),
                      child: const Text('Assign'),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
