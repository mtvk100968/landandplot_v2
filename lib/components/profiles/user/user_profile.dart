// lib/components/profiles/user/user_profile.dart
import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import 'common/user_detail_card.dart';
import 'selling/selling_tab.dart';

class UserProfile extends StatefulWidget {
  final AppUser initialUser;
  const UserProfile({Key? key, required this.initialUser}) : super(key: key);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late AppUser _user;

  @override
  void initState() {
    super.initState();
    _user = widget.initialUser;
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Selling'),
            Tab(text: 'Buying'),
          ],
        ),
      ),
      body: Column(
        children: [
          UserDetailCard(user: _user),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                SellingTab(user: _user),
                // TODO: BuyingTab(),
                Center(child: Text('Buying tab coming soon')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
