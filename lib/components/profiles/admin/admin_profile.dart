// lib/components/profiles/admin/admin_profile.dart

import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import './mini-components/properties_tab.dart';
import './mini-components/agents_tab.dart';
import './mini-components/users_tab.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: widget.onSignOut,
          ),
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
      body: TabBarView(
        controller: widget.tabController,
        children: const [
          AgentsTab(),
          UsersTab(),
          PropertiesTab(),
        ],
      ),
    );
  }
}
