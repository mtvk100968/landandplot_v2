// lib/components/profiles/user/user_profile.dart

import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import 'selling/selling_tab.dart';
import 'buying/buying_tab.dart';

class UserProfile extends StatelessWidget {
  final AppUser appUser;
  final TabController tabController;
  final VoidCallback onSignOut;

  const UserProfile({
    Key? key,
    required this.appUser,
    required this.tabController,
    required this.onSignOut,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${appUser.name ?? ''}'),
        actions: [
          IconButton(onPressed: onSignOut, icon: const Icon(Icons.logout)),
        ],
        bottom: TabBar(
          controller: tabController,
          tabs: const [
            Tab(text: 'Selling'),
            Tab(text: 'Buying'),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          SellingTab(userId: appUser.uid),
          BuyingTab(userId: appUser.uid),
        ],
      ),
    );
  }
}
