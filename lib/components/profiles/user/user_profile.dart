// lib/components/profiles/user/user_profile.dart

import 'package:flutter/material.dart';
import '../../../models/user_model.dart'; // << import AppUser

class UserProfile extends StatelessWidget {
  final AppUser appUser; // << new
  final TabController tabController;
  final VoidCallback onSignOut;

  const UserProfile({
    Key? key,
    required this.appUser, // << new
    required this.tabController,
    required this.onSignOut,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${appUser.name ?? ''}'), // example use
        actions: [
          IconButton(onPressed: onSignOut, icon: const Icon(Icons.logout))
        ],
        bottom: TabBar(
          controller: tabController,
          tabs: const [
            Tab(text: 'Your Properties'),
            Tab(text: 'Interested Properties'),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          Center(child: Text('${appUser.name}\'s Properties')),
          Center(child: Text('${appUser.name}\'s Interested List')),
        ],
      ),
    );
  }
}
