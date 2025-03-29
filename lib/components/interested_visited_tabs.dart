import 'package:flutter/material.dart';

class InterestedVisitedTabs extends StatefulWidget {
  const InterestedVisitedTabs({Key? key}) : super(key: key);

  @override
  _InterestedVisitedTabsState createState() => _InterestedVisitedTabsState();
}

class _InterestedVisitedTabsState extends State<InterestedVisitedTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildInterestedTab() {
    // TODO: Replace with dynamic data from Firestore (e.g. list of interested buyers)
    return Center(child: Text('List of Interested Buyers'));
  }

  Widget _buildVisitedTab() {
    // TODO: Replace with dynamic data for visited buyers including remarks dropdown
    return Center(child: Text('List of Visited Buyers'));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Interested'),
            Tab(text: 'Visited'),
          ],
        ),
        SizedBox(
          height: 200, // Adjust height as needed
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildInterestedTab(),
              _buildVisitedTab(),
            ],
          ),
        ),
      ],
    );
  }
}
