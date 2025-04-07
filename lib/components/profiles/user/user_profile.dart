import 'package:flutter/material.dart';

class UserProfile extends StatelessWidget {
  final TabController tabController;
  final VoidCallback onSignOut;

  const UserProfile({
    Key? key,
    required this.tabController,
    required this.onSignOut,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
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
          Center(child: Text('List of your properties')),
          Center(child: Text('List of properties you are interested in')),
        ],
      ),
    );
  }
}
