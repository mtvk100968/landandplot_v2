import 'package:flutter/material.dart';

class AgentProfile extends StatelessWidget {
  final TabController tabController;
  final VoidCallback onSignOut;

  const AgentProfile({
    Key? key,
    required this.tabController,
    required this.onSignOut,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agent Profile'),
        actions: [
          IconButton(onPressed: onSignOut, icon: const Icon(Icons.logout))
        ],
        bottom: TabBar(
          controller: tabController,
          tabs: const [
            Tab(text: 'Posted Properties'),
            Tab(text: 'Assigned Properties'),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          Center(child: Text('List of properties you have posted')),
          Center(child: Text('List of properties assigned to you')),
        ],
      ),
    );
  }
}
