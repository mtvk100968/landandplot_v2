// lib/components/profiles/admin/admin_profile.dart

import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../../../models/property_model.dart';
import '../../../services/admin_service.dart';

class AdminProfile extends StatelessWidget {
  final AppUser appUser;
  final TabController tabController;
  final VoidCallback onSignOut;

  const AdminProfile({
    Key? key,
    required this.appUser,
    required this.tabController,
    required this.onSignOut,
  }) : super(key: key);

  Future<List<dynamic>> _fetchAdminData() async {
    var agents = await AdminService().getAgents();
    var users = await AdminService().getRegularUsers();
    var properties = await AdminService().getProperties();
    return [agents, users, properties];
  }

  @override
  Widget build(BuildContext context) {
    // You can now use appUser anywhere in this build method
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        actions: [
          IconButton(onPressed: onSignOut, icon: const Icon(Icons.logout))
        ],
        bottom: TabBar(
          controller: tabController,
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
            controller: tabController,
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
