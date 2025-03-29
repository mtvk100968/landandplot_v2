import 'package:flutter/material.dart';
import '../services/admin_service.dart';
import '../models/user_model.dart';
import '../models/property_model.dart';

class AdminProfile extends StatelessWidget {
  final TabController tabController;
  final VoidCallback onSignOut;

  const AdminProfile({
    Key? key,
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
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
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          List<AppUser> agents = snapshot.data![0];
          List<AppUser> users = snapshot.data![1];
          List<Property> properties = snapshot.data![2];

          return TabBarView(
            controller: tabController,
            children: [
              // Agents Tab
              ListView.builder(
                itemCount: agents.length,
                itemBuilder: (context, index) {
                  final agent = agents[index];
                  return ListTile(
                    title: Text(agent.name ?? 'Agent'),
                    subtitle: Text(agent.phoneNumber ?? ''),
                  );
                },
              ),
              // Users Tab
              ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return ListTile(
                    title: Text(user.name ?? 'User'),
                    subtitle: Text(user.phoneNumber ?? ''),
                  );
                },
              ),
              // Properties Tab
              ListView.builder(
                itemCount: properties.length,
                itemBuilder: (context, index) {
                  final property = properties[index];
                  return ListTile(
                    // The Property model uses "name" instead of "title"
                    title: Text(
                      property.name.isEmpty ? 'Property' : property.name,
                    ),
                    subtitle: Text(property.address ?? ''),
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
